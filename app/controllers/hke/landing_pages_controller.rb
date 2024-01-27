module Hke
  class LandingPagesController < ApplicationController
    layout "landing", only: :show
    include Hke::ApplicationHelper

    # Uncomment to enforce Pundit authorization
    # after_action :verify_authorized
    # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    # GET /landing_pages
    def index

    end

    # GET /landing_pages/1 or /landing_pages/1.json
    def show
      @id = params['id1']
      @token = params['token1']
      if @token
        @relation = Relation.find_by_token(@token)
        @contact_person = @relation.contact_person
        @deceased_person = @relation.deceased_person
        @contact_name = @contact_person.name
        @deceased_name = @deceased_person.name
        @salutation = generate_salutation(@contact_person.gender)
        @conjugated_relationship = conjugated_relationship @deceased_person.gender, @contact_person.gender, @relation.relation_of_deceased_to_contact
        @deceased_salutation =  generate_salutation(@deceased_person.gender)
        @welcome = generate_welcome @contact_person.gender
        @alav_hashalom = generate_alav_hashalom @deceased_person.gender
      else
      end

    end

    # GET /landing_pages/new
    def new
      @landing_page = LandingPage.new

      # Uncomment to authorize with Pundit
      # authorize @landing_page
    end

    # GET /landing_pages/1/edit
    def edit
    end

    # POST /landing_pages or /landing_pages.json
    def create
      @landing_page = LandingPage.new(landing_page_params)
      @landing_page.user = current_user

      # Uncomment to authorize with Pundit
      # authorize @landing_page

      respond_to do |format|
        if @landing_page.save
          format.html { redirect_to @landing_page, notice: "Landing page was successfully created." }
          format.json { render :show, status: :created, location: @landing_page }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @landing_page.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /landing_pages/1 or /landing_pages/1.json
    def update
      respond_to do |format|
        if @landing_page.update(landing_page_params)
          format.html { redirect_to @landing_page, notice: "Landing page was successfully updated." }
          format.json { render :show, status: :ok, location: @landing_page }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @landing_page.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /landing_pages/1 or /landing_pages/1.json
    def destroy
      @landing_page.destroy
      respond_to do |format|
        format.html { redirect_to landing_pages_url, notice: "Landing page was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_landing_page
      @landing_page = LandingPage.find(params[:id])

      # Uncomment to authorize with Pundit
      # authorize @landing_page
    end

    # Only allow a list of trusted parameters through.
    def landing_page_params
      params.require(:landing_page).permit(:name, :body, :user_id)

      # Uncomment to use Pundit permitted attributes
      # params.require(:landing_page).permit(policy(@landing_page).permitted_attributes)
    end
  end
end
