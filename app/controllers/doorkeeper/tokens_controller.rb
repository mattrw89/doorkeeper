module Doorkeeper
  class TokensController < ActionController::Metal
    include Helpers::Controller

    def create
      response = strategy.authorize
      #so that devise #trackable works
      current_resource_owner.sign_in_count ||= 0
      current_resource_owner.sign_in_count += 1
      current_resource_owner.save(:validate => false)

      self.headers.merge! response.headers
      self.response_body = response.body.to_json
      self.status        = response.status
    rescue Errors::DoorkeeperError => e
      handle_token_exception e
    end

  private

    def strategy
      @strategy ||= server.token_request params[:grant_type]
    end
  end
end
