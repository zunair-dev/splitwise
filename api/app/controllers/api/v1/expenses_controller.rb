module Api
  module V1
    class ExpensesController < BaseController
      rescue_from ExpenseLedger::Writer::InvalidInput, with: :render_ledger_error

      def index
        group = accessible_groups.find(params[:group_id])
        expenses = group.expenses.active_records.includes(expense_payers: :user, expense_shares: :user).order(expense_date: :desc, created_at: :desc)
        render json: { expenses: expenses.map { |expense| expense_payload(expense) } }
      end

      def create
        group = accessible_groups.find(params[:group_id])
        expense = ExpenseLedger::Writer.new(expense: group.expenses.build, actor: current_user, attributes: expense_params.to_h).call
        render json: { expense: expense_payload(reload_expense(expense)) }, status: :created
      end

      def show
        render json: { expense: expense_payload(find_expense) }
      end

      def update
        expense = find_expense
        ExpenseLedger::Writer.new(expense:, actor: current_user, attributes: expense_params.to_h).call
        render json: { expense: expense_payload(reload_expense(expense)) }
      end

      def destroy
        expense = find_expense
        expense.discard!
        render json: { expense: expense_payload(expense) }
      end

      def restore
        expense = find_expense
        expense.restore!
        render json: { expense: expense_payload(expense) }
      end

      private

      def accessible_groups
        group_ids = current_user.group_memberships.active_records.accepted.select(:group_id)
        Group.where(id: group_ids)
      end

      def find_expense
        Expense.includes(expense_payers: :user, expense_shares: :user).where(group_id: accessible_groups.select(:id)).find(params[:id])
      end

      def reload_expense(expense)
        Expense.includes(expense_payers: :user, expense_shares: :user).find(expense.id)
      end

      def expense_params
        params.require(:expense).permit(
          :description, :notes, :amount_minor, :currency_code, :expense_date, :split_method,
          participant_user_ids: [], payers: [ :user_id, :amount_minor ],
          shares: [ :user_id, :amount_minor, :percentage_basis_points, :share_units ]
        )
      end

      def expense_payload(expense)
        {
          id: expense.id,
          group_id: expense.group_id,
          created_by_id: expense.created_by_id,
          description: expense.description,
          notes: expense.notes,
          amount_minor: expense.amount_minor,
          currency_code: expense.currency_code,
          expense_date: expense.expense_date.iso8601,
          split_method: expense.split_method,
          deleted_at: expense.deleted_at&.iso8601,
          payers: expense.expense_payers.map { |payer| { user_id: payer.user_id, name: payer.user.name, amount_minor: payer.amount_minor } },
          shares: expense.expense_shares.map { |share| { user_id: share.user_id, name: share.user.name, amount_minor: share.amount_minor, percentage_basis_points: share.percentage_basis_points, share_units: share.share_units } },
          created_at: expense.created_at.iso8601,
          updated_at: expense.updated_at.iso8601
        }
      end

      def render_ledger_error(error)
        render json: { error: { code: "invalid_expense", message: error.message } }, status: :unprocessable_entity
      end
    end
  end
end
