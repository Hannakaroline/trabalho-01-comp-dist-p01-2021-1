class BookingsController < AuthenticatedController
  def index
    @bookings = @current_user.bookings.where('bookings.cancelled = false AND bookings.from > ?', DateTime.now)
    render json: @bookings
  end

  def cancel
    @booking = @current_user.bookings.find_by(id: params[:id])
    unless @booking.present?
      return render json: [error: [I18n.t('errors.not_found')]], status: 404
    end

    @booking.update(cancelled: true)

    render json: @booking
  end
end
