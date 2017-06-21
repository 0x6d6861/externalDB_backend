require 'sinatra/base'
require 'sinatra/json'


require File.dirname(__FILE__) + '/Model/loader'
require 'dm-serializer/to_json'

class MyApp < Sinatra::Base

  before {content_type 'application/json'}

  @token = nil
  @user = nil

  get('/') {
    # json({results: User.all}, encoder: :to_json, content_type: :js)
    users = {results: User.all}
    # SecureRandom.hex
    users.to_json
  }

  post('/log') {
    check_logged_in ? message = {error: false, message: 'logged in'} : message = {error: true, message: 'NOT logged in'}
    return message.to_json
  }

  get('/find') {
    # json({results: User.all}, encoder: :to_json, content_type: :js)
    user = User.first(email: 'agape@live.fr', password: 'password')
    user.to_json
  }


  # Login route
  post('/login') {

    email = params[:email]
    password = params[:password]


    user = User.first(email: email, password: password)

    if check_logged_in.nil? and user.nil? # Remove user1 if login not owrking
      message = {error: true, message: 'email or password incorrect'}
    else
      # Set login methods here
      @token = SecureRandom.hex

      unless @user.nil?
        user = @user
      end

      auth = Auth.first(email: user.email)

      if auth.nil?
        auth = Auth.create({email: user.email, token: @token})
      else
        auth.update(token: @token)
      end

      message = {error: false, message: 'Login Successful', _token: auth}
    end

    return message.to_json

  }

  post('/logout') {
    token = params[:token]
    auth = Auth.first(token: token)
    auth.destroy! unless auth.nil?
    message = {error: false, message: 'Logout Successful'}
    return message.to_json
  }

  post('/register') {

    name = params[:name]
    email = params[:email]
    password = params[:password]

    user = User.first(email: email)

    if user.nil? # finds if the emails exists in the database

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

    return message.to_json


  }

  get('/profile') {
    if check_logged_in
      message = @user
    else
      message = {error: true, message: 'Authentication Faild!'}
    end
    return message.to_json
  }

  get('/tasks') {
    if check_logged_in
      message = @user.tasks
    else
      message = {error: true, message: 'Authentication Faild!'}
    end
    return message.to_json
  }

  # Adding a task
  post('/tasks') {
    name = params[:name]

    if check_logged_in
      task = Task.new
      # need to save hashed passwords

      task.attributes = {
          name: name,
          user_id: @user.id
      }

      task.save

      message = {
          error: false,
          message: 'Task Added Successful!'
      }
    else
      message = {error: true, message: 'Authentication Faild!'}
    end

    return message.to_json
  }

  get('/tasks/:id') do |task|
    if check_logged_in
      # task = Task.find(task)
      message = @user.tasks.get(task)
      if message.nil?
        message = {error: true, message: 'Task could not be found!'}
      end
    else
      message = {error: true, message: 'Authentication Faild!'}
    end
    return message.to_json
  end


  delete('/tasks/:id') do |task|
    if check_logged_in
      task = @user.tasks.get(task)
      if (!task.nil?)
        task.destroy # TODO: Need to confirm this
        message = {error: false, message: 'Task has been deleted!'}
      else
        message = {error: true, message: 'Task Could not be found!'}
      end
    else
      message = {error: true, message: 'Authentication Faild!'}
    end
    return message.to_json
  end

  get('/task/:id/items') do |task|
    if check_logged_in
      # task = Task.find(task).items
      message = @user.tasks.get(task).items
    else
      message = {error: true, message: 'Authentication Faild!'}
    end
    return message.to_json
  end

  # addind an item
  post('/task/:id/items') do |task|
    name = params[:name]
    if check_logged_in

      task = @user.tasks.get(task)

      if !task.nil?
        item = Item.new
        # need to save hashed passwords

        item.attributes = {
            name: name,
            user_id: @user.id,
            task_id: task
        }

        item.save

        message = {
            error: false,
            message: 'Item Added Successful!'
        }
      else
        message = {
            error: true,
            message: 'You are not allowed to access this Task'
        }
      end

    else
      message = {error: true, message: 'Authentication Faild!'}
    end
    return message.to_json
  end

  get('/task/:task/items/:item') do |task, item|
    if check_logged_in
      # task = Task.find(task).items
      message = @user.tasks.get(task).items.get(item)
      if message.nil?
        message = {error: true, message: 'Item Could not be found!'}
      end
    else
      message = {error: true, message: 'Authentication Faild!'}
    end
    return message.to_json
  end


  delete('/task/:task/items/:item') do |task, item|
    if check_logged_in
      # task = Task.find(task).items
      item = @user.tasks.get(task).items.get(item)
      if (!item.nil?)
        item.destroy # TODO: Need to confirm this
        message = {error: false, message: 'Item has been deleted!'}
      else
        message = {error: true, message: 'Item Could not be found!'}
      end
    else
      message = {error: true, message: 'Authentication Faild!'}
    end
    return message.to_json
  end


  # @return [Object]
  def check_logged_in
    token = params[:token]
    auth = Auth.first(token: token)
    unless auth.nil?
      @user = User.first(:email => (Auth.first(:token => token)).email)
    end
    return true unless auth.nil?
  end


end
