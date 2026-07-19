module Api
  module V1
    class GroupsController < BaseController
      def index
        groups = current_user.groups.includes(:group_memberships).order(created_at: :desc)
        render json: { groups: groups.map { |group| group_payload(group) } }
      end

      def create
        group = current_user.created_groups.build(group_params)

        if group.save
          render json: { group: group_payload(group) }, status: :created
        else
          render_validation_errors(group)
        end
      end

      def show
        group = current_user.groups.includes(:members, :group_invitations).find(params[:id])
        render json: { group: group_payload(group, include_members: true, include_invitations: true) }
      end

      def update
        group = manageable_groups.find(params[:id])

        if group.update(group_params)
          render json: { group: group_payload(group) }
        else
          render_validation_errors(group)
        end
      end

      private

      def group_params
        params.require(:group).permit(:name, :description, :group_type)
      end

      def manageable_groups
        group_ids = current_user.group_memberships.active_records.where(role: [ :owner, :admin ]).select(:group_id)
        Group.where(id: group_ids)
      end

      def group_payload(group, include_members: false, include_invitations: false)
        payload = {
          id: group.id,
          name: group.name,
          description: group.description,
          group_type: group.group_type,
          created_by_id: group.created_by_id,
          archived_at: group.archived_at&.iso8601,
          deleted_at: group.deleted_at&.iso8601,
          created_at: group.created_at.iso8601,
          updated_at: group.updated_at.iso8601
        }

        if include_members
          payload[:members] = group.group_memberships.includes(:user).map do |membership|
            {
              id: membership.id,
              user_id: membership.user_id,
              name: membership.user.name,
              email: membership.user.email,
              role: membership.role,
              invitation_status: membership.invitation_status,
              joined_at: membership.joined_at&.iso8601,
              removed_at: membership.removed_at&.iso8601
            }
          end
        end

        if include_invitations
          payload[:invitations] = group.group_invitations.map do |invitation|
            {
              id: invitation.id,
              email: invitation.email,
              role: invitation.role,
              status: invitation.status,
              invited_by_id: invitation.invited_by_id,
              created_at: invitation.created_at.iso8601
            }
          end
        end

        payload
      end
    end
  end
end
