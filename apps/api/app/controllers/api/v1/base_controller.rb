module Api
  module V1
    class BaseController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity

      private

      def current_user
        @current_user ||= User.find(request.headers.fetch("X-User-Id"))
      end

      def require_current_user!
        current_user
      rescue KeyError
        render json: { error: { code: "unauthorized", message: "X-User-Id header is required until auth is implemented." } }, status: :unauthorized
      end

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
