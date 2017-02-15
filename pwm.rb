require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  session[:passwords] ||= []
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
  pw_name = params[:name]
  pw = params[:password]
  url = params[:url]

  session[:passwords] << {name: pw_name, password: pw, url: url}
  session[:success] = "Password saved successfully"

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

  @password[:name] = updated_name
  @password[:url] = updated_url
  @password[:password] = updated_password
  session[:success] = "Password updated successfully"

  redirect '/passwords'
end

# Destroy a password
post '/passwords/:id/destroy' do
  id = params[:id].to_i
  session[:passwords].delete_at(id)
  session[:error] = "Password deleted successfully"

  redirect '/passwords'
end