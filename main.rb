require 'sinatra/base'
require 'slim'
require 'sass'
require 'sinatra/flash'
require 'pony'
require './sinatra/auth'
require 'v8'
require 'coffee-script'
require './asset-handler'
#require './song'

class Website < Sinatra::Base
	use AssetHandler
	register Sinatra::Auth
	register Sinatra::Flash
	
	configure :development do
		set :email_address => 'smtp.gmail.com',
			:email_user_name => 'aaa',
			:email_password => 'bbb',
			:email_domain => 'localhost.localdomain'
	end

	configure :production do
		set :email_address => 'smtp.example.com',
			:email_user_name => ENV['SENDGRID_USERNAME'],
			:email_password => ENV['SENDGRID_PASSWORD'],
			:email_domain => 'heroku.com'
	end

	before do
		set_title
	end

	def css(*stylesheets)
		stylesheets.map do |stylesheet|
			"<link href=\"/#{stylesheet}.css\" media=\"screen, projection\" rel=\"stylesheet\" />"
		end.join
	end

	def current?(path='/')
		(request.path==path || request.path==path+'/') ? "current" : nil
	end

	def set_title
		@title ||= "Songs by Sinatra"
	end

	def send_message
		Pony.mail(
			:from => params[:name] + "<" + params[:email] + ">",
			:to => 'pedro.lpedro@gmail.com'
			:subject => params[:name] + " has contacted you",
			:body => params[:message],
			:port => '587',
			:via => :smtp,
			:via_options => {
				:address => 'smtp.gmail.com',
				:port => '587',
				:enable_starttls_auto => true,
				:user_name => 'aaaaaa',
				:password => 'bbbbbb',
				:authentication => :plain
				:domain => 'localhost.localdomain'
			})
	end

	get '/' do
		slim :home
	end

	get '/about' do
		@title = "All about this website"
		slim :about
	end

	get '/contact' do
		@title = "Do you want to give me a call?"
		slim :contact
	end

	not_found do
		slim :not_found
	end

	post '/contact' do
		send_message
		flash[:notice] = "Thank you for your message."
		redirect to('/')
	end

	get '/set/:name' do
		session[:name] = params[:name]
	end

	#debug - to see that the name was stored in the session variable
	get '/get/hello' do
		"Hello #{session[:name]}"
	end

	get '/login' do
		slim :login
	end

	post '/login' do
		if params[:username] == settings.username && params[:password] == settings.password
			session[:admin] = true
			redirect to('/songs')
		else
			slim :login
		end
	end

	get '/logout' do
		session.clear
		redirect to('/login')
	end
end
