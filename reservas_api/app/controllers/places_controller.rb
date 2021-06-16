require 'hanami/validations'

class PlacesController < AuthenticatedController
  def index
    @places = @current_user.places
    render json: @places
  end

  def create
    validations = PlaceForm.new(create_params_filter).validate
    unless validations.success?
      return render json: validations.errors, status: 400
    end

    @place = Place.create(create_params_filter)
    PlaceAdmin.create(user: @current_user, place: @place)
    render json: @place
  end

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

  def enable
    update_params = update_params_filter
    @place = @current_user.places.find_by(id: update_params[:id])
    unless @place
      return render json: [error: [I18n.t('errors.not_found')]], status: 404
    end

    @place.update(enabled: true)
    render json: @place
  end

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