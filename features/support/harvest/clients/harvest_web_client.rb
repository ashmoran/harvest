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

      def location_name
        (
          location_element[:'data-location_name'] or raise "#location element had no data-location_name attribute"
        ).to_sym
      end

      def go_to_registrars_office
        # This won't always be the case...
        @session.click_link("Sign up") unless location_name ==  :inside_registrars_office
      end

      def sign_up_fisherman(command_attributes)
        name = command_attributes.fetch(:name)
        @session.fill_in("username",          with: name)
        @session.fill_in("email_address",     with: "#{name}@playharvest.net")
        @session.fill_in("password",          with: "Standard password 123")
        @session.fill_in("confirm_password",  with: "Standard password 123")
        @session.click_button("Sign up")
        if signup_failed?
          @session.save_and_open_page
          raise "Signup failed with form validation errors"
        end
      end

      private

      def signup_failed?
        # Hmmmm, coupled to the "invalid" CSS class we inherited from Groundwork
        @session.has_selector?("form .invalid")
      end

      def location_element
        @session.find(:css, "#location")
      end

      def registered_fishermen
        [ ]
      end
    end
  end
end