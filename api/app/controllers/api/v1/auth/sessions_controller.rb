module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        respond_to :json

        def create
          self.resource = warden.authenticate!(auth_options)
          sign_in(resource_name, resource, store: false)
          token = jwt_token(resource)

          render json: {
            user: user_payload(resource),
            token: token
          }, status: :ok
          response.set_header("Authorization", "Bearer #{token}")
        end

        def destroy
          render json: {
            success: true,
            signed_out: true
          }, status: :ok
        end

        private

        def jwt_token(user)
          Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
        end

        def respond_to_on_destroy(*)
          head :no_content
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
