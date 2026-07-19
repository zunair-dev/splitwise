module ExpenseLedger
  class Writer
    class InvalidInput < StandardError; end

    def initialize(expense:, actor:, attributes:)
      @expense = expense
      @actor = actor
      @attributes = attributes.deep_symbolize_keys
    end

    def call
      Expense.transaction do
        expense.assign_attributes(expense_attributes)
        expense.created_by ||= actor
        expense.save!
        replace_payers!
        replace_shares!
        expense
      end
    rescue ArgumentError, KeyError, TypeError => error
      raise InvalidInput, error.message
    end

    private

    attr_reader :expense, :actor, :attributes

    def expense_attributes
      attributes.slice(:description, :notes, :amount_minor, :currency_code, :expense_date, :split_method)
    end

    def amount_minor = Integer(attributes.fetch(:amount_minor))

    def member_ids
      @member_ids ||= expense.group.group_memberships.active_records.accepted.pluck(:user_id).to_set
    end

    def validate_members!(user_ids)
      unknown_ids = user_ids.to_set - member_ids
      raise InvalidInput, "all payers and participants must be active group members" if unknown_ids.any?
    end

    def replace_payers!
      payers = Array(attributes.fetch(:payers)).map { |payer| payer.deep_symbolize_keys }
      raise InvalidInput, "at least one payer is required" if payers.empty?
      payer_amounts = payers.to_h { |payer| [ Integer(payer.fetch(:user_id)), Integer(payer.fetch(:amount_minor)) ] }
      raise InvalidInput, "payers must be unique" unless payer_amounts.length == payers.length
      raise InvalidInput, "payer amounts must be positive" if payer_amounts.values.any? { |amount| !amount.positive? }
      raise InvalidInput, "payer total must equal expense amount" unless payer_amounts.values.sum == amount_minor
      validate_members!(payer_amounts.keys)

      expense.expense_payers.delete_all
      payer_amounts.each { |user_id, amount| expense.expense_payers.create!(user_id:, amount_minor: amount) }
    end

    def replace_shares!
      rows = share_rows
      raise InvalidInput, "share total must equal expense amount" unless rows.sum { |row| row.fetch(:amount_minor) } == amount_minor
      validate_members!(rows.map { |row| row.fetch(:user_id) })

      expense.expense_shares.delete_all
      rows.each { |row| expense.expense_shares.create!(row) }
    end

    def share_rows
      case attributes.fetch(:split_method).to_s
      when "equal"
        user_ids = Array(attributes.fetch(:participant_user_ids)).map { |id| Integer(id) }.uniq
        allocate(user_ids.to_h { |id| [ id, 1 ] })
      when "exact"
        unique_share_rows(:amount_minor)
      when "percentage"
        rows = unique_share_rows(:percentage_basis_points)
        raise InvalidInput, "percentages must total 10000 basis points" unless rows.sum { |row| row.fetch(:percentage_basis_points) } == 10_000
        allocated = SplitAllocator.call(total_minor: amount_minor, weights: rows.to_h { |row| [ row.fetch(:user_id), row.fetch(:percentage_basis_points) ] })
        rows.map { |row| row.merge(amount_minor: allocated.fetch(row.fetch(:user_id))) }
      when "shares"
        rows = unique_share_rows(:share_units)
        allocated = SplitAllocator.call(total_minor: amount_minor, weights: rows.to_h { |row| [ row.fetch(:user_id), row.fetch(:share_units) ] })
        rows.map { |row| row.merge(amount_minor: allocated.fetch(row.fetch(:user_id))) }
      else
        raise InvalidInput, "unsupported split method"
      end
    end

    def unique_share_rows(value_key)
      source = Array(attributes.fetch(:shares)).map(&:deep_symbolize_keys)
      rows = source.map { |row| { user_id: Integer(row.fetch(:user_id)), value_key => Integer(row.fetch(value_key)) } }
      raise InvalidInput, "at least one participant is required" if rows.empty?
      raise InvalidInput, "participants must be unique" unless rows.map { |row| row.fetch(:user_id) }.uniq.length == rows.length
      raise InvalidInput, "split values must be positive" if rows.any? { |row| !row.fetch(value_key).positive? }
      rows
    end

    def allocate(weights)
      SplitAllocator.call(total_minor: amount_minor, weights:).map { |user_id, amount| { user_id:, amount_minor: amount } }
    end
  end
end
