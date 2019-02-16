class HomesController < ApplicationController
  def index
    session.delete(:user_return_to)
  end
end
