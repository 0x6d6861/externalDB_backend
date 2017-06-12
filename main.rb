require 'sinatra/base'
require 'sinatra/json'

require File.dirname(__FILE__) + '/Model/loader'
require 'dm-serializer/to_json'

class MyApp < Sinatra::Base

  before {content_type 'application/json'}

  get('/') {
    # json({results: User.all}, encoder: :to_json, content_type: :js)
    users = {results: User.all}
    users.to_json
  }

  get('/find') {
    # json({results: User.all}, encoder: :to_json, content_type: :js)
    user = User.first(email: 'agape@live.fr', password: 'manage')
    user.tasks.to_json
  }


  # Login route
  post('/login') {

    email = params[:email]
    password = params[:password]

    user = User.first(email: email, password: password)

    if user.blank?
      message = {error: true, message: 'email or password incorrect'}
    else
      # Set login methods here
      message = {error: false, message: 'Login Successful', user: user}
    end

    message.to_json

  }

  post('/register') {

    name = params[:name]
    email = params[:email]
    password = params[:password]

    user = User.first(email: email)

    if user.blank? # finds if the emails exists in the database
      
      user = User.new

      # need to save hashed passwords

      user.attributes = {
          name: name,
          email: email,
          password: password
      }

      user.save

      message = {
          error: false,
          message: 'Registration Successful!'
      }

    else
      message = {
          error: true,
          message: "A user with #{email} already exists!"
      }
    end


  }

  get('/tasks/') {'Hello many tasks'}

  get('/tasks/:id') {|task| "task number #{task}!"}

  get('/task/:id/items') {|task| "Items of task number #{task}!"}

  get('/task/:task/items/:item') {|task, item| "Item number #{item} of task number #{task}!"}


end
