# Mongoid model sub-classes of LegResult
class SwimResult < LegResult
  # the pace the swimmer would complete 100 meters
  # given the distance and time they take to complete the course
  field :pace_100, type: Float

  def calc_ave
    if event && secs
    	meters = event.meters
    	self.pace_100 = meters.nil? ? nil : (secs/(meters/100))
    end
  end
end