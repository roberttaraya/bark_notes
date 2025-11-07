module Api
  module V1
    class NotesController < BaseController
      def index
        notes = current_user.notes.order(id: :desc)
        render json: notes.as_json(only: %i[id title body])
      end
    end
  end
end
