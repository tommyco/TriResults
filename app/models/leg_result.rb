# This will act as the base class for individual event leg results
# and the implementation class for the two transition results in between the three events
class LegResult
  include Mongoid::Document
  field :secs, type: Float

  embedded_in :entrant, class_name: 'Entrant'
  embeds_one :event, as: :parent, class_name: 'Event'

  validates_presence_of :event

  # callback used by sub-classes to update their event-specific average(s)
  # based on the details of the event and the time to complete in secs
  def calc_ave
  end

  # callback method
  after_initialize do |doc|
  	calc_ave
  end

  # custom setter
  def secs=(new_secs)
  	self[:secs] = new_secs
  	calc_ave
  end
end
