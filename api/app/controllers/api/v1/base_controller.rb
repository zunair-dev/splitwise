module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_user!

      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity

      private

      def render_validation_errors(record)
        render json: {
          error: {
            code: "validation_failed",
            message: "Validation failed",
            details: record.errors.to_hash(true)
          }
        }, status: :unprocessable_entity
      end

      def render_not_found
        render json: { error: { code: "not_found", message: "Resource not found" } }, status: :not_found
      end

      def render_unprocessable_entity(error)
        render_validation_errors(error.record)
      end
    end
  end
end
