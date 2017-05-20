class ActivityController < ApplicationController

  def update
        

    sku_type = params[:sku_type] == 1 ? "Question" : "Snippet"
    sku_id = Sku.where(stockable_id: params[:id], stockable_type: sku_type).first.id

    activity = Activity.where(user_id: params[:uid], sku_id: sku_id).first ||
        Activity.create(user_id: params[:uid], sku_id: sku_id, num_attempts: 0)

    updated = activity.update_attributes got_right: params[:bits], date: params[:date],
        num_attempts: activity.num_attempts+1

    render json: { updated: updated }, status: (updated ? :ok : :internal_server_error)
  end

end
