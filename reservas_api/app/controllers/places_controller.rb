require 'hanami/validations'

class PlacesController < AuthenticatedController
  # Lista os lugares cadastrados por um usuário (que o user é admin)
  def index
    @places = @current_user.places
    render json: @places
  end

  # Cria um lugar para um usuário, validando a presença de campos necessários
  def create
    validations = PlaceForm.new(create_params_filter).validate
    unless validations.success?
      return render json: validations.errors, status: 400
    end

    @place = Place.create(create_params_filter)
    PlaceAdmin.create(user: @current_user, place: @place)
    render json: @place
  end

  # Atualiza um lugar
  def update
    update_params = update_params_filter
    @place = @current_user.places.find_by(id: update_params[:id])

    unless @place
      return render json: [error: [I18n.t('errors.not_found')]], status: 404
    end

    validations = PlaceForm.new(update_params).validate
    unless validations.success?
      return render json: validations.errors
    end

    @place.update(update_params)

    render json: @place
  end

  # Habilita um lugar para reservas
  def enable
    update_params = update_params_filter
    @place = @current_user.places.find_by(id: update_params[:id])
    unless @place
      return render json: [error: [I18n.t('errors.not_found')]], status: 404
    end

    @place.update(enabled: true)
    render json: @place
  end

  # Desabilita um lugar para reservas
  def disable
    update_params = update_params_filter
    @place = @current_user.places.find_by(id: update_params[:id])
    unless @place
      return render json: [error: [I18n.t('errors.not_found')]], status: 404
    end

    # TODO: Reject any pending requests
    # TODO: Cancel any pending bookings
    @place.update(enabled: false)
    render json: @place
  end

  # Busca lugares para reserva de acordo com nome e endereço, o usuário da API pode passar url parameters para o filtro
  def search
    search_params = params.permit(:name, :address)

    if search_params[:name] && search_params[:address]
      @result = Place.where('name LIKE ? or address LIKE ?', "%#{search_params[:name]}%", "%#{search_params[:address]}%").first(10)
    elsif search_params[:name]
      @result = Place.where('name LIKE ?', "%#{search_params[:name]}%").first(10)
    elsif search_params[:address]
      @result = Place.where('address LIKE ?', "%#{search_params[:address]}%").first(10)
    else
      return render json: { error: [I18n.t('errors.invalid_query')] }
    end

    render json: @result
  end

  # Mostra as reservas de um lugar daqui para frente
  def bookings
    @place = Place.find_by(id: params[:id])

    unless @place.present?
      return render json: [error: [I18n.t('errors.not_found')]], status: 404
    end

    @bookings = @place.bookings.where('bookings.cancelled = false AND bookings.from > ?', DateTime.now)
    render json: @bookings
  end

  private

  def create_params_filter
    params.permit(:name,
                  :address,
                  :auto_accept)
  end

  def update_params_filter
    params.permit(:id,
                  :name,
                  :address,
                  :auto_accept)
  end
end

class PlaceForm
  include Hanami::Validations

  validations do
    required(:name).filled { str? & min_size?(3) }
    required(:address).filled { str? & min_size?(3) }
    required(:auto_accept).maybe { bool? }
  end
end
