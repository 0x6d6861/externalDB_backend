class User
  include DataMapper::Resource
  has n, :tasks
  has n, :items, through: :tasks
  property :id, Serial
  property :name, String, required: true
  property :email, String, required: true
  property :password, String, required: true
    # property :created_at => Time.now
end