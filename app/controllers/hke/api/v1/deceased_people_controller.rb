class Hke::Api::V1::DeceasedPeopleController < Api::BaseController
  before_action :set_hke_deceased_person, only: %i[ show update destroy ]

  # GET /hke/deceased_people
  def index
    @hke_deceased_people = Hke::DeceasedPerson.all

    render json: @hke_deceased_people
  end

  # GET /hke/deceased_people/1
  def show
    render json: @hke_deceased_person
  end

  # POST /hke/deceased_people
  def create
    @hke_deceased_person = Hke::DeceasedPerson.new(deceased_person_params)

    if @hke_deceased_person.save
      render json: @hke_deceased_person, status: :created, location: @hke_deceased_person
    else
      render json: @hke_deceased_person.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /hke/deceased_people/1
  def update
    if @hke_deceased_person.update(hke_deceased_person_params)
      render json: @hke_deceased_person
    else
      render json: @hke_deceased_person.errors, status: :unprocessable_entity
    end
  end

  # DELETE /hke/deceased_people/1
  def destroy
    @hke_deceased_person.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hke_deceased_person
      @hke_deceased_person = Hke::DeceasedPerson.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def deceased_person_params
      params.require(:deceased_person).permit(:first_name, :last_name, :gender, :father_first_name, 
        :mother_first_name, :hebrew_year_of_death, :hebrew_month_of_death, :hebrew_day_of_death, :time_of_death, 
        :location_of_death, :cemetery_id, :cemetery_region, :cemetery_parcel)
    end
end
