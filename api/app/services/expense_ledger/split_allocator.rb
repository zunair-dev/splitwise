module ExpenseLedger
  class SplitAllocator
    def self.call(total_minor:, weights:)
      raise ArgumentError, "total must be positive" unless total_minor.to_i.positive?

      normalized = weights.to_h { |user_id, weight| [ Integer(user_id), Integer(weight) ] }
      raise ArgumentError, "at least one positive weight is required" if normalized.empty? || normalized.values.any? { |weight| !weight.positive? }

      total_weight = normalized.values.sum
      allocations = normalized.transform_values { |weight| (total_minor * weight).div(total_weight) }
      remainder = total_minor - allocations.values.sum

      order = normalized.keys.sort_by do |user_id|
        fractional_numerator = (total_minor * normalized.fetch(user_id)) % total_weight
        [ -fractional_numerator, user_id ]
      end
      remainder.times { |index| allocations[order.fetch(index)] += 1 }
      allocations
    end
  end
end
