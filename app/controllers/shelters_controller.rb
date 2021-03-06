class SheltersController < ApplicationController
  before_action :set_shelter, only: [:show]
  caches_page :show

  # GET /shelters/1
  # GET /shelters/1.json
  def show
    respond_to do |format|
      format.html {
        @weather_days = Weatherable.show_shelter(@shelter)
      }
      format.json {
        @shelters = []
        if (api_auth(params[:api_key]))
          if (params[:dist_miles])
            shelter_mile = @shelter.mileage
            distance = params[:dist_miles].to_f

            sorted_shelters = Shelter.where("mileage <= ? AND mileage > ?", shelter_mile + distance, shelter_mile)
            sorted_shelters.each do |shelter|
              shelter.daily_weather = Weatherable.show_shelter(shelter);
              @shelters << shelter
            end

            @shelters
          else
            @shelter.daily_weather = Weatherable.show_shelter(@shelter)
            @shelters << @shelter
          end
        else
          self.status = :unauthorized
          self.response_body = { error: 'Access denied' }.to_json
        end
      }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shelter
      @shelter = Shelter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shelter_params
      params.require(:shelter).permit(:name, :mileage, :elevation, :long, :latt, :state_id)
    end
end
