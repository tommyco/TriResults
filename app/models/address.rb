# Custom class to handle processing the address format within the ingested JSON data.
class Address
	attr_accessor :city, :state, :location

	# Constructs Address instance object
	def initialize(city=nil, state=nil, location=nil)
		@city = city if !city.nil?
		@state = state if !state.nil?
		@location = Point.new(location[:coordinates][0], location[:coordinates][1]) if !location.nil?
	end

	# Marshals the state of the instance into MongoDB format as a Ruby hash
	def mongoize
		{:city=>@city, :state=>@state, :loc=>Point.mongoize(location)}
	end

	# Returns the state marshalled into MongoDB format as a Ruby hash
	def self.mongoize object
		case object
		when nil then
			nil
		when Hash then
			if object[:city]
				Address.new(object[:city], object[:state], object[:loc]).mongoize
			end
		when Address then
			object.mongoize
		end
	end

	# Returns an instance of the class
	def self.demongoize object
		case object
		when nil then
			nil
		when Hash then
			if object[:city]
				Address.new(object[:city], object[:state], object[:loc])
			else
				Address.new
			end
		when Address then
			object
		end
	end

	# Behave the same as self.mongoize
	def self.evolve object
		object.mongoize
	end
end
