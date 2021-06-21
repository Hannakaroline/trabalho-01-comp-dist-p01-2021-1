require 'hanami/validations'

class BookingRequestsController < AuthenticatedController
  # Tenta criar uma solicitação de reserva para um lugar
  # Se o lugar já estiver reservado, já responde com um erro 409 de conflito para indicar que já existe uma reserva no período solicitado
  # Se o lugar não estiver reservado e o lugar estiver configurado para aceitar reservas automaticamente, a reserva é feita
  # Se o lugar não estiver reservado, mas o lugar não estiver configurado para aceitar reservas automaticamente, a solicitação de reserva é criada
  # Responde com 404 se o lugar não existir
  def create
    create_params = create_params_filter
    puts create_params.inspect
    validation = BookingRequestForm.new(create_params).validate

    unless validation.success?
      return render json: validation.errors, status: 400
    end

    @place = Place.find_by(id: create_params[:place_id], enabled: true)
    unless @place
      return render json: { error: [I18n.t('errors.not_found')] }, status: 404
    end

    from = create_params[:from]
    to = create_params[:to]

    @conflicting_booking = @place.bookings.where('bookings.cancelled = false AND (bookings.from between ? and ? or bookings.to between ? and ?)', from, to, from, to)

    if @conflicting_booking.present?
      return render json: { error: [I18n.t('errors.already_booked')] }, status: 409
    end

    if @place.auto_accept
      @booking = Booking.create(
        from: from,
        to: to,
        place_id: @place.id,
        user_id: @current_user.id,
        approved_by_user_id: @place.place_admins.first.id,
      )
      @booking_request = BookingRequest.create(
        place_id: @place.id,
        from: from,
        to: to,
        user_id: @current_user.id,
        accepted: true,
        booking_id: @booking.id
      )
      return render json: @booking_request
    end

    @booking_request = BookingRequest.create(place_id: @place.id, from: from, to: to, user_id: @current_user.id)

    render json: @booking_request
  end

  # Deleta uma solicitação de reserva pendente
  # Não é possível apagar uma solicitação já aceita
  # Responde com um erro se a solicitação não existir ou se não pertencer ao usuário
  # Também responde com um erro se a solicitação já estiver cancelada ou aceita
  def destroy
    @booking_request = @current_user.booking_requests.find_by(id: params[:id])
    unless @booking_request
      return render json: { error: [I18n.t('errors.not_found')] }, status: 404
    end

    if @booking_request.accepted.nil?
      @result = @booking_request.destroy!

      render json: @result
    else
      render json: { error: [I18n.t('errors.invalid_request')] }, status: 400
    end
  end

  # Lista as solicitações de reserva feitas por um usuário que ainda não foram respondidas
  def made
    @booking_requests = @current_user.booking_requests.where('accepted is null OR accepted is false').last(100)
    render json: @booking_requests
  end

  # Lista as solicitações recebeidas por todos os lugares que um usuário possui que ainda nao foram respondidas
  def received
    @booking_requests = BookingRequest.joins("JOIN place_admins on booking_requests.place_id = place_admins.place_id and place_admins.user_id = #{@current_user.id}")
    render json: @booking_requests
  end

  # Responde uma solicitação de reserva
  # Valida a existência da solicitação de reserva e se já foi respondida
  # Valida se o usuário é admin do lugar
  # Atualiza a solicitação com a resposta e cria uma reserva no banco se a reserva for aceita
  def answer
    answer_params = answer_params_filter
    @booking_request = BookingRequest.find_by(id: answer_params[:id], accepted: nil)

    unless @booking_request.present?
      return render json: { error: [I18n.t('errors.not_found')] }, status: 404
    end

    unless @current_user.places.find_by(id: @booking_request[:place_id])
      return render json: { error: [I18n.t('errors.not_found')] }, status: 404
    end

    unless answer_params[:accepted]
      @booking_request.update(accepted: false)
      return render json: @booking_request
    end

    ActiveRecord::Base.transaction do
      @booking = Booking.create(
        from: @booking_request.from,
        to: @booking_request.to,
        place: @booking_request.place,
        user: @booking_request.user,
        approved_by_user_id: @current_user.id
      )

      from = @booking.from
      to = @booking.to
      query = %Q(
      booking_requests.id <> ? AND booking_requests.accepted IS NULL AND booking_requests.place_id = ? AND
      \(booking_requests.from between ? and ? OR booking_requests.to between ? and ?\))

      BookingRequest.where(query, @booking_request.id, @booking.place_id, from, to, from, to)
                    .update_all "accepted = false, note = 'conflict'"

      @booking_request.update(accepted: true, booking: @booking)
    end

    render json: @booking_request
  end

  private

  def create_params_filter
    filtered = params.permit(:place_id, :from, :to)
    { place_id: filtered[:place_id], from: filtered[:from].to_datetime, to: filtered[:to].to_datetime }
  end

  def answer_params_filter
    params.permit(:id, :accepted)
  end

  class String
    def to_datetime
      begin
        DateTime.iso8601(self)
      rescue
        nil
      end
    end
  end
end

class MyPredicates
  include Hanami::Validations::Predicates

  predicate :date_time_str? do |current|
    begin
      DateTime.iso8601(current).is_a?(DateTime)
    rescue
      false
    end
  end
end

class BookingRequestForm
  include Hanami::Validations
  predicates MyPredicates

  validations do
    required(:from).filled { date_time? }
    required(:to).filled { date_time? }
    required(:place_id).filled { int? }
    rule(valid_range: [:from, :to]) do |from, to|
      from.lt?(to)
    end
  end
end
