class AssetsController < ApplicationController
  before_action :set_asset, only: %i[show value]

  def index
    @assets = Asset.all
    render json: AssetSerializer.new(@assets).serializable_hash
  end

  def show
    render json: AssetSerializer.new(@asset).serializable_hash
  end

  def value
    render json: {
      data: {
        value: @asset.current_value
      }
    }
  end

  private

  def asset_params
    params.require(:asset).permit(:id, :code, :name, :fiat)
  end

  def set_asset
    @asset = Asset.find(params[:id])
  end
end
