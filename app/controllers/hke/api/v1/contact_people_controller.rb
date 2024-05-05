class Hke::Api::V1::ContactPeopleController < Api::BaseController
    include Hke::Addressable
    before_action :set_contact_person, only: %i[ show update destroy ]
  
    # GET /hke/contact_people
    def index
      @contact_people = Hke::ContactPerson.all
      render json: @contact_people
    end
  
    # GET /hke/contact_people/1
    def show
      render json: { contact_person: @contact_person, address: @contact_person.address }
    end
  
    # POST /hke/contact_people
    def create
      @contact_person = Hke::ContactPerson.new(contact_person_params.except(:address_attributes))
      address_attributes = contact_person_params[:address_attributes]
  
      # Use the new method from the concern to handle address initialization
      initialize_address(@contact_person, address_attributes) if address_attributes
  
      if @contact_person.save
        render json: { contact_person: @contact_person, address: @contact_person.address }, status: :created, location: @contact_person
      else
        render json: @contact_person.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /hke/contact_people/1
    def update
      params = contact_person_params
      input_address = params.delete("address_attributes")
  
      if @contact_person.update(params)
        update_or_create_address(@contact_person, input_address) if input_address
        render json: { contact_person: @contact_person, address: @contact_person.address }, status: :ok
      else
        render json: @contact_person.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /hke/contact_people/1
    def destroy
      @contact_person.destroy!
    end
  
    private
      
      def set_contact_person
        @contact_person = Hke::ContactPerson.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def contact_person_params
        params.require(:contact_person).permit(
            :first_name, :last_name, :email, :phone, :gender, 
            address_attributes: [:addressable_type, :address_type, :line1, :line2, :city, :state, :country, :postal_code]
        )
      end
      
  end
  