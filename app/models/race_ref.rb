# Mongoid embedded model class to hold information
# about the Race that queries of an Entrant will need to immediately know about
class RaceRef
  include Mongoid::Document
  field :n, as: :name, type: String
  field :date, type: Date

  embedded_in :entrant, class_name: 'Entrant'
  belongs_to :race, foreign_key: "_id"
end
