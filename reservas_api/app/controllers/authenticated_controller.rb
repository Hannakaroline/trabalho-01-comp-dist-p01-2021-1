class AuthenticatedController < ApplicationController
  # Executa a autenticação do usuário baseado no header enviado na request 'x-access-token'
  # O método authenticate_request é executado antes de todas requests feitas pelos controllers que herdam desse controller
  # Retorna um erro de autenticação 401 se o usuário não estiver autenticado
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
