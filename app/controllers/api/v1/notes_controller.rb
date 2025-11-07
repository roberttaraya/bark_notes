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

      def create
        note = current_user.notes.build(note_params)
        if note.save
          render json: note.as_json(only: [:id, :title, :body]), status: :created
        else
          render json: { errors: note.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def update
        note = current_user.notes.find_by(id: params[:id])
        return head :not_found unless note

        if note.update(note_params)
          render json: note.as_json(only: [:id, :title, :body]), status: :ok
        else
          render json: { errors: note.errors.to_hash }, status: :unprocessable_entity
        end
      end

      private

      def set_note
        @note = current_user.notes.find_by(id: params[:id])
        render json: { error: "not found" }, status: :not_found unless @note
      end

      def note_params
        params.permit(:title, :body)
      end
    end
  end
end
