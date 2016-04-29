# Custom class to handle processing the GeoJSON Point format within the ingested JSON object
class Point
	attr_accessor :longitude, :latitude

	# Constructs Point instance object
	def initialize(longitude, latitude)
		@longitude = longitude
		@latitude = latitude
	end

	# Marshals the state of the instance into MongoDB format as a Ruby hash
	def mongoize
		return {:type=>"Point", :coordinates=>[@longitude, @latitude]}
	end

	# Returns the state marshalled into MongoDB format as a Ruby hash
	def self.mongoize object
		case object
		when nil then
			nil
		when Hash then
			if object[:type]	# object is in correct hash format
				Point.new(object[:coordinates][0], object[:coordinates][1]).mongoize
			end
		when Point then 
			object.mongoize
		end
	end

	# Returns an instance of the class
	def self.demongoize object
		case object
		when nil then
			nil
		when Hash then
			if object[:type]
				Point.new(object[:coordinates][0], object[:coordinates][1])
			end
		when Point then
			object
		end
	end

	# Behave the same as self.mongoize
	def self.evolve object
		object.mongoize
	end
end
