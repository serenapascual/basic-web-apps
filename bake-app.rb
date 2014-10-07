require "sinatra"     # Load the Sinatra web framework
require "data_mapper" # Load the DataMapper database library

require "./database_setup"

class Message
  include DataMapper::Resource

  property :id,         Serial
  property :body,       Text,     required: true
  property :upvotes,    Integer,  required: true, default: 0
  property :downvotes,  Integer,  required:true,  default: 0
  property :shown,      Integer,  required: true, default: 0
  property :created_at, DateTime, required: true
  
end

DataMapper.finalize()
DataMapper.auto_upgrade!()

get("/") do
  records = Message.all(order: :created_at.desc)
  erb(:index, locals: { messages: records })
end

post("/messages") do
  message_body = params["body"]
  message_time = DateTime.now

  message = Message.create(body: message_body, created_at: message_time)

  if message.saved?
    redirect("/")
  else
    erb(:error)
  end
end

post("/messages/*/upvote") do |message_id|
  message = Message.get(message_id)
  message.upvotes = message.upvotes + 1

  if message.save
    redirect("/")
  else
    body("Error")
  end
end

post("/messages/*/downvote") do |message_id|
  message = Message.get(message_id)
  message.downvotes = message.downvotes + 1

  if message.save
    redirect("/")
  else
    body("Error")
  end
end

post("/messages/*/delete") do |message_id|
  message = Message.get(message_id)
  puts message_id
  message.shown = 1
  
end
  
  
get("/waffles") do
  html = ""

  html.concat("<img src='http://upload.wikimedia.org/wikipedia/commons/5/5b/Waffles_with_Strawberries.jpg' height='800'>")

  erb(:content, { locals: { content: html } })
end

get("/waffles/chocolate") do
  html = ""

  html.concat("<h2>We're out.</h2>")
  html.concat("<p>Sorry.</p>")

  erb(:content, { locals: { content: html } })
end

# Visit, e.g., /bake?baked_good=waffles&count=20

get("/bake") do
  count      = Integer(params["count"])
  baked_good = String(params["baked_good"])

  html = "Baking #{count} #{baked_good}..."
  html.concat("<ul>")
  count.times do |num|
    num=num+1
    html.concat("<li>#{baked_good} number #{num}</li>")
  end
  html.concat("</ul>")

  erb(:content, { locals: { content: html } })
end

get("/lets_bake") do

  html = ""
  html = "What do you want to bake?"
  html.concat("<li><a href='/bake?baked_good=cookies&count=100'>bake 100 cookies</a></li>")
  html.concat("<li><a href='/bake?baked_good=cronut&count=500'>bake 500 cronuts</a></li>")
  html.concat("<li><a href='/bake?baked_good=bread&count=2500'>bake 2500 loaves of bread</a></li>")
  html.concat("<li><a href='/suggestions'>I don't know what I want to bake.</a></li>")
 
  erb(:content, { locals: { content: html } })
end

get("/suggestions") do

  file_contents = File.readlines("message-of-the-day.txt").sample

  html = ""
  html.concat("<h1>Is that so?</h1>")
  html.concat("<p>How about <a href='/bake?baked_good=#{file_contents}s&count=100'>#{file_contents}</a>?")
  html.concat("<p><a href='/suggestions'>No, something else.</a>")

  body(html)
  erb(:content, { locals: { content: html } })
end