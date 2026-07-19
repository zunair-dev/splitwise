module Api
  module V1
    class UsersController < BaseController
      before_action :require_current_user!, only: [ :show, :update ]

      def create
        user = User.new(user_params)

        if user.save
          render json: { user: user_payload(user) }, status: :created
        else
          render_validation_errors(user)
        end
      end

      def show
        render json: { user: user_payload(current_user) }
      end

      def update
        if current_user.update(profile_params)
          render json: { user: user_payload(current_user) }
        else
          render_validation_errors(current_user)
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end

      def profile_params
        params.require(:user).permit(:name, :profile_status, :avatar)
      end

      def user_payload(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          profile_status: user.profile_status,
          avatar_attached: user.avatar.attached?,
          created_at: user.created_at.iso8601,
          updated_at: user.updated_at.iso8601
        }
      end
    end
  end
end
