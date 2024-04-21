class AssetsController < ApplicationController
  before_action :set_asset, only: %i[show value]

  def index
    @assets = Asset.all
    serialized_assets = AssetSerializer.new(@assets).serializable_hash
    assets_data = serialized_assets[:data]

    render json: {
      data: assets_data
    }
  end

  def show
    serialized_asset = AssetSerializer.new(@asset).serializable_hash
    asset_data = serialized_asset[:data]

    render json: {
      data: asset_data
    }
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
