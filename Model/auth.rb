class Auth
  include DataMapper::Resource
  property :id, Serial
  property :token, String, required: true
  property :email, String, required: true
end