class Item
  include DataMapper::Resource
  belongs_to :user
  belongs_to :task
  property :id, Serial
  property :name, String, required: true
  # property :created_at => Time.now
end