class ActivityController < ApplicationController
  respond_to :json

  def update
    activity = Activity.where(user_id: params[:uid], sku_id: params[:id]).first ||
        Activity.create(user_id: params[:uid], sku_id: params[:id], num_attempts: 0)

    updated = activity.update_attributes got_right: params[:bits], date: params[:date],
        num_attempts: activity.num_attempts+1

    render json: { updated: updated }, status: (updated ? :ok : :internal_server_error)
  end

end
