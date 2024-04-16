class Hke::Api::V1::CemeteriesController < Api::BaseController
  include Hke::Addressable
  before_action :set_cemetery, only: %i[ show update destroy ]

  # GET /cemeteries
  def index
    @cemeteries = Hke::Cemetery.all
    render json: @cemeteries
  end

  # GET /cemeteries/1
  def show
    render json: @cemetery
  end

  # POST /cemeteries
  # def create
  #   @cemetery = Hke::Cemetery.new(cemetery_params)
  #   # Merge address attributes from cemetery_params with additional attributes

  #   address_attributes = cemetery_params[:address_attributes]
  #   if address_attributes
  #     address_attributes = address_attributes.merge(address_type: 'billing', addressable_type: 'Hke::Cemetery')
  #     @cemetery.build_address(address_attributes)
  #   end

  #   if @cemetery.save
  #     render json: { cemetery: @cemetery, address: @cemetery.address }, status: :created, location: @cemetery
  #   else
  #     render json: @cemetery.errors, status: :unprocessable_entity
  #   end
  # end

  def create
    @cemetery = Hke::Cemetery.new(cemetery_params.except(:address_attributes))
    address_attributes = cemetery_params[:address_attributes]

    # Use the new method from the concern to handle address initialization
    initialize_address(@cemetery, address_attributes) if address_attributes

    if @cemetery.save
      render json: { cemetery: @cemetery, address: @cemetery.address }, status: :created, location: @cemetery
    else
      render json: @cemetery.errors, status: :unprocessable_entity
    end
  end

  def update
    params = cemetery_params
    input_address = params.delete("address_attributes")

    if @cemetery.update(params)
      update_or_create_address(@cemetery, input_address) if input_address
      render json: { cemetery: @cemetery, address: @cemetery.address }, status: :ok
    else
      render json: @cemetery.errors, status: :unprocessable_entity
    end
  end

  # DELETE /cemeteries/1
  def destroy
    @cemetery.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cemetery
      @cemetery = Hke::Cemetery.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cemetery_params
      params.require(:cemetery).permit(:name, :description, address_attributes: [:addressable_type, :address_type, :line1, :line2, :city, :state, :country, :postal_code])
    end

    def update_or_create_address(addressable, input_address)
      if addressable.address.present?
        addressable.address.update(input_address)
      else
        addressable.create_address(input_address.merge(address_type: 'billing', addressable_type: 'Hke::Cemetery'))
      end
    end
    
end
