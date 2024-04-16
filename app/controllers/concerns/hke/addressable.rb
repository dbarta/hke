module Hke
    module Addressable
        extend ActiveSupport::Concern
    
        included do
        # You can include callbacks here if any
        end

        def initialize_address(addressable, address_params)
            address_params = address_params.merge(address_type: 'billing', addressable_type: addressable.class.to_s)
            addressable.build_address(address_params)
        end
    
        def update_or_create_address(addressable, input_address)
            ActiveRecord::Base.transaction do
                if addressable.address.present?
                    unless addressable.address.update(input_address)
                        render json: addressable.address.errors, status: :unprocessable_entity
                        raise ActiveRecord::Rollback
                    end
                else
                    unless addressable.create_address(input_address.merge(address_type: 'billing', addressable_type: addressable.class.to_s))
                        render json: addressable.address.errors, status: :unprocessable_entity
                        raise ActiveRecord::Rollback
                    end
                end
            end
        end
    end
end
  