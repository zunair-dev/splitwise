require "test_helper"

class ExpenseLedger::WriterTest < ActiveSupport::TestCase
  setup do
    @group = groups(:trip)
    @alice = users(:alice)
    @bob = users(:bob)
  end

  test "allocates equal split remainder deterministically" do
    expense = write(split_method: "equal", amount_minor: 101, participant_user_ids: [ @bob.id, @alice.id ])

    assert_equal({ @alice.id => 51, @bob.id => 50 }, share_amounts(expense))
  end

  test "stores exact splits" do
    expense = write(split_method: "exact", amount_minor: 100, shares: [
      { user_id: @alice.id, amount_minor: 25 },
      { user_id: @bob.id, amount_minor: 75 }
    ])

    assert_equal({ @alice.id => 25, @bob.id => 75 }, share_amounts(expense))
  end

  test "allocates percentage splits from basis points" do
    expense = write(split_method: "percentage", amount_minor: 101, shares: [
      { user_id: @alice.id, percentage_basis_points: 5_000 },
      { user_id: @bob.id, percentage_basis_points: 5_000 }
    ])

    assert_equal({ @alice.id => 51, @bob.id => 50 }, share_amounts(expense))
    assert_equal 10_000, expense.expense_shares.sum(:percentage_basis_points)
  end

  test "allocates weighted share splits" do
    expense = write(split_method: "shares", amount_minor: 100, shares: [
      { user_id: @alice.id, share_units: 1 },
      { user_id: @bob.id, share_units: 2 }
    ])

    assert_equal({ @alice.id => 33, @bob.id => 67 }, share_amounts(expense))
  end

  test "rolls back the whole expense when payer totals do not match" do
    assert_no_difference "Expense.count" do
      error = assert_raises(ExpenseLedger::Writer::InvalidInput) do
        write(split_method: "equal", amount_minor: 100, participant_user_ids: [ @alice.id, @bob.id ], payers: [ { user_id: @alice.id, amount_minor: 99 } ])
      end
      assert_equal "payer total must equal expense amount", error.message
    end
  end

  private

  def write(overrides)
    attributes = {
      description: "Dinner",
      amount_minor: 100,
      currency_code: "usd",
      expense_date: Date.current,
      payers: [ { user_id: @alice.id, amount_minor: overrides.fetch(:amount_minor, 100) } ]
    }.merge(overrides)

    ExpenseLedger::Writer.new(expense: @group.expenses.build, actor: @alice, attributes:).call
  end

  def share_amounts(expense)
    expense.expense_shares.order(:user_id).pluck(:user_id, :amount_minor).to_h
  end
end
