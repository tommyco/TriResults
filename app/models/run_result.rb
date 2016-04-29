# Mongoid model sub-classes of LegResult
class RunResult < LegResult
  # the average time required to complete 1 mile given the length and time to complete the course
  field :mmile, as: :minute_mile, type: Float

  def calc_ave
  	if event && secs
  		miles = event.miles
  		self.mmile = miles.nil? ? nil : ((secs/60)/miles)
  	end
  end
end