class Hke::Api::V1::ImportDataController < Api::BaseController

  # Make sure to skip CSRF checks if it's API-only
  #skip_before_action :verify_authenticity_token, only: [:upload]

  def upload
    # Ensure that the file was provided
    if params[:file].nil?
      render json: { error: "No file uploaded" }, status: :unprocessable_entity and return
    end

    # Save the uploaded file to a temporary location
    uploaded_file = params[:file]
    file_path = Rails.root.join('tmp', uploaded_file.original_filename)
    
    # Write the file to disk
    File.open(file_path, 'wb') do |file|
      file.write(uploaded_file.read)
    end

    render json: { message: "File uploaded successfully", file_path: file_path.to_s }, status: :ok
  end
end
