module Api
  module V1
    class SessionsController < ActionController::API
      def create
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          render json: { token: user.api_token }, status: :created
        else
          render json: { error: "invalid credentials" }, status: :unauthorized
        end
      end
    end
  end
end
