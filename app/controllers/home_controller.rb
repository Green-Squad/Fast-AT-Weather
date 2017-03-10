class HomeController < ApplicationController

  def index
    @shelters_states = {}
    @states = {}
    states = State.all

    states.each do |state|
      @states[:"#{state.name}"] = state.get_average_weather
    end

    states.each do |state|
      @shelters_states[:"#{state.name}"] = Shelter.where(state: state)
    end
  end


end