require 'capybara'
require 'capybara/webkit'
require 'forwardable'

Capybara.configure do |config|
  config.run_server = false
  config.app_host   = 'http://localhost:3000'

  # Strict Capybara 2.0 options minus `visible_text_only`
  config.match = :one
  config.exact_options = true
  config.ignore_hidden_elements = true

  config.save_and_open_page_path = PROJECT_DIR + "/tmp/capybara"
end

module Harvest
  module Clients
    class HarvestWebClient
      extend Forwardable

      def_delegators :@session, *Capybara::Session::DSL_METHODS

      def initialize(root_uri)
        # TODO: something with root_uri???
        @root_uri = root_uri
        @session = Capybara::Session.new(:webkit)
      end

      def start
        @session.visit("/")
      end

      def go_to_registrars_office
        # This won't always be the case...
        @session.click_link("Sign up")
      end

      def sign_up_fisherman(command_attributes)
        @session.fill_in("username", with: command_attributes.fetch(:name))
        @session.click_button("Sign up")
      end

      def location_name
        @session.find(:css, "#location")[:'data-location_name'].to_sym
      end

      def registered_fishermen
        [ ]
      end
    end
  end
end