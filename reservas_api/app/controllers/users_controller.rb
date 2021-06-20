require 'hanami/validations'
require 'jwt'

class UsersController < ApplicationController

  # Faz o signup de novas contas
  # Valida e-mail
  # Valida força da senha
  # Valida confirmação da senha
  # Responde com os dados do novo usuário criado ou
  # Responde com um erro se as validações falharem ou já existir um e-mail cadastrado com o e-mail que se tentou fazer o signup
  def signup
    signup_params = signup_params_filter
    validation = Signup.new(signup_params).validate
    unless validation.success?
      return render json: validation.errors, status: 400
    end

    if User.exists?(signup_params.require(:email))
      return render json: { email: [I18n.t('errors.email.taken')] }, status: 400
    end

    rsa_private = OpenSSL::PKey::RSA.new(ENV['RESERVAS-API_RSA-PRIVATE-KEY'])
    payload = { email: signup_params.require(:email),
                password: signup_params.require(:password) }
    token = JWT.encode payload, rsa_private, 'RS256'
    @user = User.create(name: signup_params[:name], email: signup_params[:email], access_token: token)
    render json: @user
  end

  # Faz login, valida se o e-mail existe e se a senha bate com o que está salvo no banco
  def login
    login_params = login_params_filter
    validation = Login.new(login_params).validate

    unless validation.success?
      return render json: validation.errors, status: 400
    end

    rsa_private = OpenSSL::PKey::RSA.new(ENV['RESERVAS-API_RSA-PRIVATE-KEY'])
    payload = { email: login_params[:email],
                password: login_params.require(:password) }
    token = JWT.encode payload, rsa_private, 'RS256'
    @user = User.find_by email: login_params[:email], access_token: token

    unless @user
      return render json: I18n.t('errors.login.invalid_credentials')
    end

    render json: @user
  end

  private

  # Métodos privados para filtrar parametros de input nas requests
  def signup_params_filter
    params.permit(:name, :email, :password, :password_confirmation)
  end

  def login_params_filter
    params.permit(:email, :password)
  end
end

# Validação de parametros
class MyPredicates
  include Hanami::Validations::Predicates

  predicate :email? do |current|
    current.match(URI::MailTo::EMAIL_REGEXP)
  end

  predicate(:has_a_digit?) do |current|
    current.match(/(.*\d.*)/)
  end

  predicate(:has_a_lower_case?) do |current|
    current.match(/.*[a-z].*/)
  end

  predicate(:has_an_upper_case?) do |current|
    current.match(/.*[A-Z].*/)
  end

  predicate(:has_a_symbol?) do |current|
    current.match(/.*[^A-Za-z0-9\s].*/)
  end
end

class Signup
  include Hanami::Validations
  predicates MyPredicates

  validations do
    required(:name).filled { str? & min_size?(1) }
    required(:email).filled { str? & email? }
    required(:password).filled { min_size?(8) & has_a_digit? & has_a_lower_case? & has_an_upper_case? & has_a_symbol? }.confirmation
  end
end

class Login
  include Hanami::Validations
  predicates MyPredicates

  validations do
    required(:email).filled { str? & email? }
    required(:password).filled
  end
end
