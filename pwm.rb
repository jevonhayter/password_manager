require 'sinatra'
require 'sinatra/reloader' if development?
require 'tilt/erubis'

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  session[:passwords] ||= []
end

not_found do
  'That password was not found'
end

helpers do
  def color_code(index)
    if index.even?
      'active'
    else
      'info'
    end
  end
end

# Home Page
get '/' do
  erb :index
end

# Form to create a new password
get '/passwords/new' do
  erb :new_password
end

# Creater a new password
post '/passwords' do
  pw_name = params[:name].strip
  pw = params[:password].strip
  url = params[:url].strip

  if pw_name.empty? || pw.empty?
    session[:error] = 'Must enter at leaset 1 character'
    redirect '/passwords/new'
  else
    session[:passwords] << { name: pw_name, password: pw, url: url }
    session[:success] = 'Password saved successfully'
  end

  redirect '/passwords'
end

# List all passwords in a table
get '/passwords' do
  @passwords = session[:passwords]

  erb :passwords
end

# Form to edit a password
get '/edit_password/:id' do
  @password_id = params[:id].to_i
  @password = session[:passwords][@password_id]

  erb :edit_password
end

# Update a password
post '/passwords/:id' do
  id = params[:id].to_i
  @password = session[:passwords][id]

  updated_name = params[:name].strip
  updated_url = params[:url].strip
  updated_password = params[:password].strip

  if updated_name.empty? || updated_password.empty?
    session[:error] = 'Must enter at leaset 1 character'
    redirect "/edit_password/#{id}"
  else
    @password[:name] = updated_name
    @password[:url] = updated_url
    @password[:password] = updated_password
    session[:success] = 'Password updated successfully'
  end

  redirect '/passwords'
end

# Destroy a password
post '/passwords/:id/destroy' do
  id = params[:id].to_i
  session[:passwords].delete_at(id)
  session[:error] = 'Password deleted successfully'

  redirect '/passwords'
end
