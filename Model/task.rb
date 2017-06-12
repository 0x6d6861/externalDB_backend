class Task
  include DataMapper::Resource
  belongs_to :user
  has n, :items
  property :id, Serial
  property :name, String, required: true
  property :email, String, required: true
  property :password, String, required: true
  # property :created_at => Time.now
end