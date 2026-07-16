module Api
  module V1
    class GroupMembershipsController < BaseController
      before_action :require_current_user!

      def create
        group = manageable_groups.find(params[:group_id])
        user = User.find(membership_params.fetch(:user_id))
        membership = group.group_memberships.build(user: user, role: membership_params[:role] || :member, invitation_status: :accepted)

        if membership.save
          render json: { membership: membership_payload(membership) }, status: :created
        else
          render_validation_errors(membership)
        end
      end

      def destroy
        membership = manageable_group_memberships.find(params[:id])
        membership.remove!
        render json: { membership: membership_payload(membership) }
      end

      private

      def membership_params
        params.require(:membership).permit(:user_id, :role)
      end

      def manageable_groups
        group_ids = current_user.group_memberships.active_records.where(role: [ :owner, :admin ]).select(:group_id)
        Group.where(id: group_ids)
      end

      def manageable_group_memberships
        GroupMembership.where(group_id: manageable_groups.select(:id))
      end

      def membership_payload(membership)
        {
          id: membership.id,
          group_id: membership.group_id,
          user_id: membership.user_id,
          role: membership.role,
          invitation_status: membership.invitation_status,
          joined_at: membership.joined_at&.iso8601,
          removed_at: membership.removed_at&.iso8601
        }
      end
    end
  end
end
