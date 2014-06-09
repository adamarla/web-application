class RubricsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json
end
