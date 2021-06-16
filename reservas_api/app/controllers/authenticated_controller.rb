class AuthenticatedController < ApplicationController
  before_action :authenticate_request
  attr_reader :current_user

  private
  def authenticate_request
    @access_token = request.headers['x-access-token']
    unless User.exists? access_token: @access_token
      render json: { error: [I18n.t('errors.authentication.invalid_credentials')] }, status: 401
    end
    @current_user = User.find_by access_token: @access_token
  end
end
