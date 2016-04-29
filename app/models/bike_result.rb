# Mongoid model sub-classes of LegResult
class BikeResult < LegResult
  # average speed the biker traveled over the course
  # given the length of the course and the time they take to complete the course
  field :mph, type: Float

  def calc_ave
  	if event && secs
  		miles = event.miles
  		self.mph = miles.nil? ? nil : (miles*3600/secs)
  	end
  end
end