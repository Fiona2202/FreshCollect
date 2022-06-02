class ItemsController < ApplicationController
  before_action :set_item, only: [ :show, :edit, :update, :destroy ]

  def index
    @items = Item.all
    @markers = @items.geocoded.map do |item|
      {
        lat: item.latitude,
        lng: item.longitude,
        info_window: render_to_string(partial: "info_window", locals: { item: item })
      }
    end
  end

  def show
    @pickup = Pickup.new
  end

  def new
    @item = Item.new
  end

  def user_address
    params.dig(:item, :user, :address)
  end

  def create
    current_user.update(address: user_address) if user_address.present?

    @item = Item.new(item_params)
    @item.user = current_user
    if @item.save
      redirect_to @item
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to @item
    else
      render :edit
    end
  end

  def destroy
    @item.destroy
    redirect_to items_path
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:title, :description, :start_pickup_at, :end_pickup_at, :latitude, :longitude, :photo)
  end
end
