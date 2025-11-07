module Api
  module V1
    class NotesController < BaseController
      before_action :set_note, only: :show

      def index
        notes = current_user.notes.order(id: :desc)
        render json: notes.as_json(only: %i[id title body])
      end

      def show
        render json: @note.as_json(only: %i[id title body])
      end

      private

      def set_note
        @note = current_user.notes.find_by(id: params[:id])
        render json: { error: "not found" }, status: :not_found unless @note
      end
    end
  end
end
