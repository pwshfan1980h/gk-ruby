class ReadinessController < ActionController::Base
  def show
    ActiveRecord::Base.lease_connection.select_value("SELECT 1")
    head :ok
  rescue ActiveRecord::ActiveRecordError
    head :service_unavailable
  end
end
