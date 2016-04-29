# Mongoid model class
class Event
  include Mongoid::Document
  field :o, as: :order, type: Integer
  field :n, as: :name, type: String
  field :d, as: :distance, type: Float
  field :u, as: :units, type: String

  embedded_in :parent, class_name: 'Race', touch: true

  validates_presence_of :order, :name

  # returns the length of the course in meters
  def meters
  	case self.u
  	when "meters", "meter" then
  		self.d
  	when "kilometers", "kilometer" then
  		self.d * 1000.0
  	when "yards", "yard" then
  		self.d * 0.9144
  	when "miles", "mile" then
  		self.d * 1609.344
  	else
  		nil
  	end
  end

  # returns the length of the course in miles
  def miles
  	case self.u
  	when "miles", "mile" then
  		self.d
  	when "meters", "meter" then
  		self.d / 1609.344
  	when "kilometers", "kilometer" then
  		self.d * 0.621371
  	when "yards", "yard" then
  		self.d * 0.000568182
  	else
  		nil
  	end
  end
end
