# Custom class to handle processing the placing format within the ingested JSON data.
class Placing
	attr_accessor :name, :place

	# Constructs Placing instance object
	def initialize(name, place)
		@name = name
		@place = place
	end

	# Marshals the state of the instance into MongoDB format as a Ruby hash
	def mongoize
		{:name=>@name, :place=>@place}
	end

	# Returns the state marshalled into MongoDB format as a Ruby hash
	def self.mongoize object
		case object
		when nil then
			nil
		when Hash then
			Placing.new(object[:name], object[:place]).mongoize
		when Placing then
			object.mongoize
		end
	end

	# Returns an instance of the class
	def self.demongoize object
		case object
		when nil then
			nil
		when Hash then
			Placing.new(object[:name], object[:place])
		when Placing then
			object
		end
	end

	# Behave the same as self.mongoize
	def self.evolve object
		object.mongoize
	end
end
