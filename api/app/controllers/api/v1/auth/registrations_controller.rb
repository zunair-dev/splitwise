module Api
  module V1
    module Auth
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json

        def create
          build_resource(sign_up_params)

          if resource.save
            sign_in(resource_name, resource, store: false)
            token = jwt_token(resource)
            render json: {
              user: user_payload(resource),
              token: token
            }, status: :created
            response.set_header("Authorization", "Bearer #{token}")
          else
            render json: {
              error: {
                code: "validation_failed",
                message: "Validation failed",
                details: resource.errors.to_hash(true)
              }
            }, status: :unprocessable_entity
          end
        end

        private

        def sign_up_params
          params.require(:user).permit(:name, :email, :password, :password_confirmation)
        end

        def jwt_token(user)
          Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
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
end
