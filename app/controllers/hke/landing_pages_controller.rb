module Hke
  class LandingPagesController < ApplicationController
    before_action :set_community_as_current_tenant
    layout "hke/landing", only: :show
    include Hke::ApplicationHelper

    # Uncomment to enforce Pundit authorization
    # after_action :verify_authorized
    # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    # GET /landing_pages
    def index

    end

    # GET /landing_pages/1 or /landing_pages/1.json
    def show
      @token = params['token']
      if @token
        @relation = Relation.find_by_token(@token)
        if @relation
          msg_data = {
            "c_first_name" => @contact_name.split.first,
            "c_last_name" => @contact_name.split.last,
            "num_days_till" => @num_days_till,
            "day_of_week" => "יום חמישי",
            "heb_month_and_day" => "י׳ חשוון",
            "yahrzeit_years" => "22",
            "relation" => @conjugated_relationship,
            "d_salutation" => @deceased_salutation,
            "d_first_name" => @deceased_name.split.first,
            "d_last_name" => @deceased_name.split.last,
            "alav" => @alav_hashalom,
            "petirata" => "הפטירה"
          }
          @cp = @relation.contact_person
          @dp = @relation.deceased_person
          @contact_name = @cp.name
          @deceased_name = @dp.name
          @salutation = generate_salutation(@cp.gender)
          @conjugated_relationship = conjugated_relationship @dp.gender, @cp.gender, @relation.relation_of_deceased_to_contact
          @deceased_salutation =  generate_salutation(@dp.gender)
          @welcome = generate_welcome @cp.gender
          @alav_hashalom = generate_alav_hashalom @dp.gender
        end
      else
      end
      # Example values (these would typically come from the database)


      @welcome = "ברוך הבא"

      @deceased_salutation = "מר"


      @hebrew_date = "י׳ חשוון תשס״א"
      @relationship_type = "בן"
      @num_days_till = 7

      # Generate SMS Preview
      sms_data = {
        "c_first_name" => @contact_name.split.first,
        "c_last_name" => @contact_name.split.last,
        "num_days_till" => @num_days_till,
        "day_of_week" => "יום חמישי",
        "heb_month_and_day" => "י׳ חשוון",
        "yahrzeit_years" => "22",
        "relation" => @conjugated_relationship,
        "d_salutation" => @deceased_salutation,
        "d_first_name" => @deceased_name.split.first,
        "d_last_name" => @deceased_name.split.last,
        "alav" => @alav_hashalom,
        "petirata" => "הפטירה"
      }
      @sms_preview = Hke::LiquidRenderer.render("reminder.txt", sms_data, category: "sms")

      # Render the full landing page using Liquid
      landing_page_data = {
        "contact_name" => @contact_name,
        "salutation" => @salutation,
        "welcome" => @welcome,
        "conjugated_relationship" => @conjugated_relationship,
        "deceased_salutation" => @deceased_salutation,
        "deceased_name" => @deceased_name,
        "alav_hashalom" => @alav_hashalom,
        "hebrew_date" => @hebrew_date,
        "relationship_type" => @relationship_type,
        "num_days_till" => @num_days_till,
        "sms_preview" => @sms_preview
      }
      @landing_page_preview = Hke::LiquidRenderer.render("reminder.html", landing_page_data, category: "web")
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
