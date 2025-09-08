module Hke
  class CsvImportsController < ApplicationController
    include Hke::SetCommunityAsTenant
    before_action :authenticate_user!
    before_action :authorize_community_admin!

    def new
      @csv_import = CsvImport.new
      authorize @csv_import
    end

    def create
      @csv_import = CsvImport.new(csv_import_params)
      @csv_import.user = current_user
      @csv_import.community = ActsAsTenant.current_tenant

      if @csv_import.save
        # Process CSV in background with Sidekiq
        CsvImportJob.perform_async(@csv_import.id)
        redirect_to csv_import_path(@csv_import), notice: t('csv_imports.upload_success')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @csv_import = CsvImport.find(params[:id])
      authorize @csv_import
    end

    def index
      @csv_imports = policy_scope(CsvImport).includes(:user).order(created_at: :desc)
      authorize CsvImport
    end

    private

    def csv_import_params
      params.require(:csv_import).permit(:file, :import_type)
    end

    def authorize_community_admin!
      unless current_user.community_admin? || current_user.system_admin?
        redirect_to root_path, alert: t('access_denied')
      end
    end
  end
end
