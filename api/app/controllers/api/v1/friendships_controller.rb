module Api
  module V1
    class FriendshipsController < BaseController
      def index
        friendships = current_user.friendships.includes(:requester, :addressee).order(created_at: :desc)
        render json: { friendships: friendships.map { |friendship| friendship_payload(friendship) } }
      end

      def create
        addressee = User.find_by!(email: friendship_params.fetch(:email).to_s.strip.downcase)
        friendship = current_user.requested_friendships.build(addressee: addressee)

        if friendship.save
          render json: { friendship: friendship_payload(friendship) }, status: :created
        else
          render_validation_errors(friendship)
        end
      end

      def accept
        friendship = Friendship.find(params[:id])
        return render_forbidden unless friendship.addressee == current_user

        friendship.accept!
        render json: { friendship: friendship_payload(friendship) }
      end

      private

      def friendship_params
        params.require(:friendship).permit(:email)
      end

      def friendship_payload(friendship)
        other_user = friendship.requester == current_user ? friendship.addressee : friendship.requester

        {
          id: friendship.id,
          status: friendship.status,
          requester_id: friendship.requester_id,
          addressee_id: friendship.addressee_id,
          friend: {
            id: other_user.id,
            name: other_user.name,
            email: other_user.email
          },
          accepted_at: friendship.accepted_at&.iso8601,
          created_at: friendship.created_at.iso8601
        }
      end

      def render_forbidden
        render json: { error: { code: "forbidden", message: "You cannot perform this action." } }, status: :forbidden
      end
    end
  end
end
