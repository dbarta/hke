module Hke
  class ApplicationController < ActionController::Base

    #include JumpstartApp::Application.routes.url_helpers
    #helper Devise::Controllers::Helpers
    impersonates :user
    include Sortable
    include SetLocale
    include CurrentHelper
    include SetCurrentRequestDetails
    layout 'application'

    def remove_empty_relations_from(model_name, nested_model_name)
      x = params[model_name]
      relations = x["relations_attributes"]
      # {"1639369042549"=>{"relation_of_deceased_to_contact"=>"",
      #   "contact_person_attributes"=>{"first_name"=>"", "last_name"=>"", "email"=>"", "phone"=>""}, "_destroy"=>"false"}}
      if relations
        keys_to_remove = []
        relations.each do |rel_key, rel_attrs|
          if rel_attrs["relation_of_deceased_to_contact"].empty?
            keys_to_remove << rel_key
          else
            contact_attrs = rel_attrs[nested_model_name + "_attributes"]
            if contact_attrs
                if contact_attrs.values.all? ""
                  keys_to_remove << rel_key
                end
            end
          end
        end
        puts "2222222222 keys_to_remove: #{keys_to_remove}"
        keys_to_remove.each {|k| relations.delete k}
        puts "3333333333 relations: #{relations}"
        if relations.empty?
          params[model_name].delete "relations_attributes"
        else
          params[model_name]["relations_attributes"] = relations
        end
        puts "4444444444 params: #{params}"
      end
    end

    private

    def authenticate_admin
      redirect_to "/", alert: t("unauthorized") unless user_signed_in? && current_user.admin?
    end
  end
end
