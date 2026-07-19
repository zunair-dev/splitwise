module Api
  module V1
    class GroupInvitationsController < BaseController
      before_action :require_current_user!

      def create
        group = manageable_groups.find(params[:group_id])
        invitation = group.group_invitations.build(invitation_params.merge(invited_by: current_user))

        if invitation.save
          render json: { invitation: invitation_payload(invitation) }, status: :created
        else
          render_validation_errors(invitation)
        end
      end

      def revoke
        invitation = GroupInvitation.where(group_id: manageable_groups.select(:id)).find(params[:id])
        invitation.revoke!
        render json: { invitation: invitation_payload(invitation) }
      end

      private

      def invitation_params
        params.require(:invitation).permit(:email, :role)
      end

      def manageable_groups
        group_ids = current_user.group_memberships.active_records.where(role: [ :owner, :admin ]).select(:group_id)
        Group.where(id: group_ids)
      end

      def invitation_payload(invitation)
        {
          id: invitation.id,
          group_id: invitation.group_id,
          invited_by_id: invitation.invited_by_id,
          email: invitation.email,
          role: invitation.role,
          status: invitation.status,
          accepted_at: invitation.accepted_at&.iso8601,
          declined_at: invitation.declined_at&.iso8601,
          revoked_at: invitation.revoked_at&.iso8601,
          created_at: invitation.created_at.iso8601
        }
      end
    end
  end
end
