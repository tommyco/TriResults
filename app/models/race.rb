# Mongoid model class to act as root-level document in the races collection
class Race
  include Mongoid::Document
  include Mongoid::Timestamps
  field :n, as: :name, type: String
  field :date, as: :date, type: Date
  field :loc, as: :location, type: Address

  field :next_bib, type: Integer, default: 0

  scope :past, ->{ where(:date.lt=>Date.current)}
  scope :upcoming, ->{ where(:date.gte=>Date.current)}

  embeds_many :events, as: :parent, class_name: 'Event', order: [:order.asc]
  has_many :entrants, foreign_key: "race._id", order: [:secs.asc, :bib.asc], dependent: :delete

  DEFAULT_EVENTS = {"swim"=>{:order=>0, :name=>"swim", :distance=>1.0,  :units=>"miles"},
  					"t1"  =>{:order=>1, :name=>"t1"},
  					"bike"=>{:order=>2, :name=>"bike", :distance=>25.0, :units=>"miles"},
  					"t2"  =>{:order=>3, :name=>"t2"},
  					"run" =>{:order=>4, :name=>"run",  :distance=>10.0, :units=>"kilometers"}}

  DEFAULT_EVENTS.keys.each do |name|
  	define_method("#{name}") do
  	  event=events.select {|event| name==event.name}.first
  	  event||=events.build(DEFAULT_EVENTS["#{name}"])
  	end

  	["order","distance","units"].each do |prop|
  	  if DEFAULT_EVENTS["#{name}"][prop.to_sym]
  	    # getter for property
  	    define_method("#{name}_#{prop}") do
  	      event=self.send("#{name}").send("#{prop}")
  		end
  		# setter for property
  		define_method("#{name}_#{prop}=") do |value|
  		  event=self.send("#{name}").send("#{prop}=", value)
  		end
  	  end
  	end
  end

  # Returns a default instance of Race with the DEFAULT_EVENTS properties above
  def self.default 
  	Race.new do |race|
  		DEFAULT_EVENTS.keys.each {|leg| race.send("#{leg}")}
	end		
  end

  # defining getter and setter of custom type property
  # using Ruby metaprogramming
  ["city", "state"].each do |action|
     define_method("#{action}") do
        self.location ? self.location.send("#{action}") : nil
     end
     define_method("#{action}=") do |name|
        object=self.location ||= Address.new
        object.send("#{action}=", name)
        self.location = object
     end
  end

  # getter that will increment the next_bib value in the database
  # and return the result
  def next_bib
  	self[:next_bib] = self[:next_bib] + 1
  end

  # returns a Placing instance with its name set to the name 
  # of the age group the racer will be competing in
  def get_group racer
    if racer && racer.birth_year && racer.gender
      quotient=(date.year-racer.birth_year)/10
      min_age=quotient*10
      max_age=((quotient+1)*10)-1
      gender=racer.gender
      name=min_age >= 60 ? "masters #{gender}" : "#{min_age} to #{max_age} (#{gender})"
      Placing.demongoize(:name=>name)
    end
  end

  # create a new Entrant for the Race for a supplied Racer
  def create_entrant racer
    # build a new Entrant
    entrant = Entrant.new { |r| 
      # clone the relevant Race information within Entrant.race
      r.build_race(self.attributes.symbolize_keys.slice(:_id, :n, :date))
      # clone the RaceInfo attributes within Entrant.racer
      r.build_racer(racer.info.attributes)
      # determine the group for the racer and assign it to the entrant
      r.group = get_group(r.racer)
    }
      # validate the Entrant
    if entrant.validate
      # assign a new unique bib number from the database and save to the database
      entrant.bib = self.next_bib
      entrant.save
      self.events.each do |event|
        entrant.results.create(:event=>event)
      end
    end
    # return the Entrant
    entrant
  end

  # returns a criteria result representing all the upcoming Races that the Racer 
  # has not yet registered for
  def self.upcoming_available_to racer
    # array of upcoming race ids for the racer
    upcoming_race_ids = racer.races.upcoming.pluck(:race).map {|r| r[:_id]}
    where(:date.gte=>Date.current).where(:_id.nin=>upcoming_race_ids)
  end
end
