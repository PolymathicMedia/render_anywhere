module RenderAnywhere
  class RenderingController < AbstractController::Base
    # Include all the concerns we need to make this work
    include AbstractController::Logger
    include AbstractController::Rendering
    include AbstractController::Layouts
    include AbstractController::Helpers
    include AbstractController::Translation
    include AbstractController::AssetPaths

    # Define additional helpers, this one is for csrf_meta_tag
    helper_method :protect_against_forgery?

    # override the layout in your subclass if needed.
    layout 'application'

    # configure the different paths correctly
    def initialize(*args)
      super()

      self.class.send :include, Rails.application.routes.url_helpers

      # this is you normal rails application helper
      self.class.send :helper, ApplicationHelper

      # include the all-important text helper
      self.class.send :helper, ActionView::Helpers::TextHelper

      # include all other helpers in the app/helpers directory.
      Dir[Rails.root.join('app','helpers/*_helper.rb')].each do |file|
        helper_key = Pathname.new(file).basename.to_s.gsub(/_helper\.rb$/,'')
        self.class.send :helper, helper_key
      end

      lookup_context.view_paths = Rails.root.join('app', 'views')
      config.javascripts_dir = Rails.root.join('public', 'javascripts')
      config.stylesheets_dir = Rails.root.join('public', 'stylesheets')
      config.assets_dir = Rails.root.join('public')
      
      # same asset host as the controllers
      self.asset_host = ActionController::Base.asset_host
    end

    # we are not in a browser, no need for this
    def protect_against_forgery?
      false
    end

    # so that your flash calls still work
    def flash
      {}
    end

    # and nil request to differentiate between live and offline
    def request
      nil
    end

    # and params will be accessible
    def params
      {}
    end

    # so that your cookies calls still work
    def cookies
      {}
    end

  end
end
