module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate!

      private

      def authenticate!
        token = request.authorization.to_s.split(" ").last
        @current_user = User.find_by(api_token: token)
        render json: { error: "unauthorized" }, status: :unauthorized unless @current_user
      end

      def current_user = @current_user
    end
  end
end
