# Holds information to identify the racer and to register for races
class RacerInfo
  include Mongoid::Document
  field :racer_id, as: :_id
  field :_id, default:->{ racer_id }

  field :fn, as: :first_name, type: String
  field :ln, as: :last_name, type: String
  field :g, as: :gender, type: String
  field :yr, as: :birth_year, type: Integer
  field :res, as: :residence, type: Address

  embedded_in :parent, class_name: 'Racer', polymorphic: true

  validates_presence_of :first_name, :last_name, :gender, :birth_year
  validates_inclusion_of :gender, in: %w(M F), message: "%{value} must be M or F" 
  validates_numericality_of :birth_year, less_than: Date.current.year 

  # # brute force getter of a property in custom type
  # def city
  #   self.residence ? self.residence.city : nil 
  # end

  # # brute force setter of a property in custom type
  # def city= name 
  #   object=self.residence ||= Address.new
  #   object.city = name
  #   self.residence = object
  # end

  # defining getter and setter of custom type property
  # using Ruby metaprogramming
  ["city", "state"].each do |action|
     define_method("#{action}") do
        self.residence ? self.residence.send("#{action}") : nil
     end
     define_method("#{action}=") do |name|
        object=self.residence ||= Address.new
        object.send("#{action}=", name)
        self.residence = object
     end
  end
end
