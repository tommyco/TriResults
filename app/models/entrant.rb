# Root-level document in the results collection
class Entrant
  include Mongoid::Document
  include Mongoid::Timestamps

  field :bib, type: Integer
  field :secs, type: Float
  field :o, as: :overall, type: Placing
  field :gender, type: Placing
  field :group, type: Placing

  store_in collection: "results"

  embeds_many :results, class_name: 'LegResult', order: [:"event.o".asc], after_add: :update_total, after_remove: :update_total
  embeds_one :race, class_name: 'RaceRef', autobuild: true
  embeds_one :racer, class_name: 'RacerInfo', as: :parent, autobuild: true

  scope :past, ->{ where(:"race.date".lt=>Date.current)}
  scope :upcoming, ->{ where(:"race.date".gte=>Date.current)}

  delegate :first_name, :first_name=, to: :racer
  delegate :last_name, :last_name=, to: :racer
  delegate :gender, :gender=, to: :racer, prefix: "racer"
  delegate :birth_year, :birth_year=, to: :racer
  delegate :city, :city=, to: :racer
  delegate :state, :state=, to: :racer

  delegate :name, :name=, to: :race, prefix: "race"
  delegate :date, :date=, to: :race, prefix: "race"

  def group_name
    group.name if group
  end
  # def group_place
  #   group.place if group
  # end
  # def overall_place
  #   overall.place if overall
  # end

  ["group","overall","gender"].each do |pobject|
     define_method("#{pobject}_place") do
       self.send("#{pobject}").send("place") if self.send("#{pobject}")
     end
  end

  RESULTS={"swim"=>SwimResult,
           "t1"=>LegResult,
           "bike"=>BikeResult,
           "t2"=>LegResult,
           "run"=>RunResult}


  RESULTS.keys.each do |name|
     # create_or_find result
     define_method("#{name}") do
       result = results.select {|result| name==result.event.name if result.event}.first
       if !result
          result=RESULTS["#{name}"].new(:event=>{:name=>name})
          results << result
       end
       result
     end

     # assign event details to result
     define_method("#{name}=") do |event|
        event = self.send("#{name}").build_event(event.attributes)
     end

     # expose setter/getter for each property of each results
     RESULTS["#{name}"].attribute_names.reject {|r|/^_/===r}.each do |prop|
       define_method("#{name}_#{prop}") do
         event=self.send(name).send(prop)
       end
       define_method("#{name}_#{prop}=") do |value|
         event=self.send(name).send("#{prop}=", value)
         update_total nil if /secs/===prop
       end
     end
  end

  def update_total(result)
    sum = 0
    results.each do |r|
       sum += r.secs if r.secs
    end
    self.secs = sum
  	# self.secs = results.inject(0){|sum, x| sum + x.secs }
  end

  # custom getter returns the result of race.race
  # where the first race references the embedded RaceRef
  # the second race references the Race document in the other collection
  def the_race
    race.race
  end
end
