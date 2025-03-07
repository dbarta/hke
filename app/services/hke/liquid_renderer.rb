require 'liquid'

module Hke
  class LiquidRenderer
    def self.render(template_name, data, category: "web")
      # Load the correct template from the engine
      template_path = Hke::Engine.root.join("app/views/hke/liquid_templates/#{category}/#{template_name}.liquid")

      # Read and parse the template
      template_content = File.read(template_path)
      template = Liquid::Template.parse(template_content)

      # Render with provided data
      template.render(data)
    end
  end
end
