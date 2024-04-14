class Hke::Api::V1::CemeteriesController < Api::BaseController
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
  def create
    @cemetery = Hke::Cemetery.new(name: cemetery_params["name"], description: cemetery_params["description"] )

    if @cemetery.save
      render json: @cemetery, status: :created, location: @cemetery
    else
      render json: @cemetery.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /cemeteries/1
  def update
    if @cemetery.update(cemetery_params)
      render json: @cemetery
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
      params.require(:cemetery).permit(:name, :description, :line1, :line2, :city, :state, :country, :postal_code)
    end
end
