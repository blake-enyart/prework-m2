# Task Manager

## CRUD in Sinatra

What does CRUD (in the the programming world) stand for?

* C: Create
* R: Read
* U: Update
* D: Delete

The apps that you will be creating in Mod 2 will make heavy use of these four actions. 

Let's use Sinatra to build an application where we can manage our tasks.

We're going to follow the [MVC](https://www.sitepoint.com/getting-started-with-mvc/) design pattern (Rails uses this by default, but in Sinatra we will need to create this structure ourselves) to implement the CRUD actions.

Throughout the module, we'll talk through some conventions and best practices, but for now - we'd like for you to follow along with this tutorial. We highly recommend **not** copying and pasting the code in this tutorial. It's to your advantage to type each line of code on your own. 

## Getting Configured

Let's make a project folder from the command line: `mkdir task_manager`. Go into the directory with `cd task_manager`.

We'll also need a Gemfile: `touch Gemfile`. Inside of your Gemfile, add Sinatra and Shotgun. [Shotgun](https://github.com/rtomayko/shotgun) will allow us to make changes to our code base without having to restart the server each time.

```ruby
source 'https://rubygems.org'

gem 'sinatra', require: 'sinatra/base'
gem 'shotgun'
```

We will be using the [modular](http://www.sinatrarb.com/intro.html#Modular%20vs.%20Classic%20Style) style of Sinatra app, which is why we need to require 'sinatra/base'.

Next, let's make a config file from the command line: `touch config.ru`. This file will be used by Rackup. Add this code inside of the config file:

```ruby
require 'bundler'
Bundler.require

$LOAD_PATH.unshift(File.expand_path("app", __dir__))

require 'controllers/task_manager_app'

run TaskManagerApp
```

The first two lines of this file allow all of your gems to be required. Then, we change the load path so that everything inside of our `app` folder (we haven't created it yet) can be required. Next, we require a file called `task_manager_app` that will be inside of our `controllers` folder. Finally, we call the run method and specify that our app is called TaskManagerApp.

Run `bundle install` from the command line. This will install the contents of your `Gemfile` so that you (and others in the future) can use them throughout your project.

## Project Folder Structure

So far, we just have a Gemfile, config.ru, and Gemfile.lock. Let's create the folders we'll need for our Task Manager.

```
$ mkdir app
$ mkdir db
```

We'll use the `app` folder for all of our implementation code. Our `db` folder will hold our database.

We'll need a few folders inside of our app folder so that we can separate our files.

```
$ mkdir app/controllers
$ mkdir app/models
$ mkdir app/views
```

Although we could put all of our code inside of the same folder (or even most of it in the same file), we're going to use this structure to mimic the [MVC](https://www.youtube.com/watch?v=eTdVkgF_Slo) setup that Rails will give us.

## Getting the App Running

Ok, so we have our project structure. Let's now get our app up and running! Make a file inside of app/controllers called `task_manager_app.rb`:

```
$ touch app/controllers/task_manager_app.rb
```

Inside of it, add the following code:

```ruby
class TaskManagerApp < Sinatra::Base
  set :root, File.expand_path("..", __dir__)

  get '/' do
    'hello, world!'
  end
end
```

Remember when we wrote `run TaskManagerApp` in our `config.ru` file? Well, the class we just defined is what that line in our config.ru refers to.

Line 2 sets the root of our project. Here, we're taking the current file (`app/controllers/task_manager_app`) and going one folder up the chain. This should take us to our `app` folder. The reason we're doing this is because Sinatra will look relative to our app for views and stylesheets. We don't want to put these things in our controller folder, so we're specifying that our root is just `app`.

Next, we tell our app that when a `get` request is sent to the `'/'` path, it should send back 'hello, world!' as the response. Let's try it!

From the command line, change back into the `task_manager` directory where the `config.ru` file is and run:

```
$ shotgun
```

Navigate to http://localhost:9393/ and you should see magic!

## Using Views

Let's change our controller to render an ERB view instead of 'hello, world!'. Inside of `task_manager_app.rb`:

```ruby
class TaskManagerApp < Sinatra::Base
  set :root, File.expand_path("..", __dir__)

  get '/' do
    erb :dashboard
  end
end
```

This piece of code will look for an .erb file called 'dashboard' in the views folder at the root of the app. Since we've already set the root of the app and created a views folder there, we're ready to make a dashboard file. If you're still running your server, press control+c to stop it.

```
$ touch app/views/dashboard.erb
```

Inside of this file, let's add links to some functionality we might want in our app:

```erb
<h1>Welcome to the Task Manager</h1>

<ul>
  <li><a href="/tasks">Task Index</a></li>
  <li><a href="/tasks/new">New Task</a></li>
</ul>
```

We have an h1 tag for our welcome message, then an unordered list (ul) with two list items (li) inside. If you are unfamiliar with HTML tags, try one of the [HTML tutorials](https://github.com/turingschool/intermission-assignments/blob/master/2be/details/html-css.md) before continuing.

Inside of each li tag, we have an `a` tag. The href of the tag is the path where the link will go. In the first a tag, the path will be `http://localhost:9393/tasks`. The second path will be `http://localhost:9393/tasks/new`.

Restart your server with `shotgun` from the command line, then refresh the page. You should see our welcome message and two links. We haven't set up our controller to handle either of these yet, so clicking on these should give us a "Sinatra doesn't know this ditty" error.

## Adding a Task Index Route

In a Sinatra app, we can add routes by combining an HTTP verb (get, post, put, delete, etc.) with a URL pattern. If you're unfamiliar with HTTP verbs, check out [A Beginner's Guide to HTTP and REST](http://code.tutsplus.com/tutorials/a-beginners-guide-to-http-and-rest--net-16340).

Our controller currently has one route:

```ruby
  get '/' do
    erb :dashboard
  end
```

Let's add a route for the first link we want -- our Task Index. In `app/controllers/task_manager_app.rb`:

```ruby
class TaskManagerApp < Sinatra::Base
  set :root, File.expand_path("..", __dir__)

  get '/' do
    erb :dashboard
  end

  get '/tasks' do
    @tasks = ["task1", "task2", "task3"]
    erb :index
  end
end
```

What are we doing here? Well, we create an instance variable `@tasks` and assign an array of three strings to it. Then, we render the `index.erb` file. Our instance variable will be available to use in the view.

Let's try rendering this array in the view. First, we need to create our `index.erb`:

```
$ touch app/views/index.erb
```

Inside of the view, we will iterate through the array and display each string:

```erb
<h1>All Tasks</h1>

<% @tasks.each do |task| %>
  <h3><%= task %></h3>
<% end %>
```

Navigate to `http://localhost:9393/tasks` and check that each task is displayed. Our `index.erb` is looking ok right now.

## Adding a New Task Route

We need a route that will bring a user to a form where they can enter a new task. This is the second link we had in our dashboard. In our controller:

```ruby
class TaskManagerApp < Sinatra::Base
  set :root, File.expand_path("..", __dir__)

  get '/' do
    erb :dashboard
  end

  get '/tasks' do
    @tasks = ["task1", "task2", "task3"]
    erb :index
  end

  get '/tasks/new' do
    erb :new
  end
end
```

We don't need any instance variables here; we just need to render the view. Let's make that view:

```
$ touch app/views/new.erb
```

In that file, we'll add a form:

```erb
<form action="/tasks" method="post">
  <p>Enter a new task:</p>
  <input type='text' name='task[title]'/><br/>
  <textarea name='task[description]'></textarea><br/>
  <input type='submit'/>
</form>
```

Here we have a form with an action (url path) of `/tasks` and a method of `post`. This combination of path and verb will be important when we create the route in the controller. We then have an text input field for the title, a textarea for the description, and a submit button.

Navigate to `http://localhost:9393/tasks/new` to see your beautiful form!

Try clicking the submit button. You should get a "Sinatra doesn't know that ditty" error because we haven't set up a route in our controller to handle this action - method combination from the form submission.

In our controller:

```ruby
class TaskManagerApp < Sinatra::Base
  set :root, File.expand_path("..", __dir__)

  get '/' do
    erb :dashboard
  end

  get '/tasks' do
    @tasks = ["task1", "task2", "task3"]
    erb :index
  end

  get '/tasks/new' do
    erb :new
  end

  post '/tasks' do
    "<p>Params: #{params}</p> <p>Task params: #{params[:task]}</p>"
  end
end
```

Why `post` instead of `get`? First, we specified a method of post in our form (go look at the form if that sentence doesn't make sense to you). Although we could make it work using `get`, HTTP convention specifies that a `get` request should request data from a specified resource while a `post` should submit data to be processed. In our case, we are submitting form data that needs to be processed, so we're using `post`.

Inside of this route, we'll need to eventually do some work. But for right now, we're just displaying the params.

Go back to `http://localhost:9393/tasks/new`. Fill in a fake title and a fake description. Click submit. On the page, you should see something like:

```
Params: {"task"=>{"title"=>"Make cookies", "description"=>"Chocolate chip cookies are so delicious. I am hungry."}}

Task params: {"title"=>"Make cookies", "description"=>"Chocolate chip cookies are so delicious. I am hungry."}
```

Notice that `params` is a hash. The key is `"task"` and the value is another hash containing the `title` and `description`. This structure was created because of the way we named the input fields in our form (go back and look at the form to see how these are connected).

When we access `params[:task]`, we get back only the part we want; the title and description. This is what we'll use to build a task.

## Saving Tasks

So we're able to get information in from our form, but we haven't really done much with it yet. It would be great if we could save it somewhere...

### Our Approach

Let's think for a little bit about what we'd like to do with these task params that we're getting when our form is submitted. Really what we want to do here is create a new task using those parameters, and then save it somewhere that we can retrieve it.

For now, let's ignore the particulars of that problem. We're going to program with enough faith in ourselves that we can figure those things out when we get to them.

I'm sure we could figure out a way to do everything we needed to do in this file, but right now, as a programmer with some OO background, sitting in my controller, thinking about creating and saving new tasks makes me wish that I had some sort of Task class that I could use to create Task objects.

### Creating Our Task Class

Let's change the code inside of our controller to use this Task class that we're thinking about creating. If it were up to me (and it is), I would create a new task with my task params and then save it so that I could find it later. Let's assume that we're going to create a class that does just that. Find the `post'/tasks'` route inside of the `app/controllers/task_manager_app.rb` file and replace our existing code with the following:

```ruby
# /app/controllers/task_manager_app.rb

post '/tasks' do
  task = Task.new(params[:task])
  task.save
  redirect '/tasks'
end
```

You'll sometimes see this I'm-going-to-assume-I-have-a-thing-that-works approach referred to as "top-down" programming. For an awesome video demonstration take a look at [this](https://vimeo.com/131588133) when you have a moment. The opposite approach would be "bottom-up" where we start with the smallest piece that we can get to work and start building on it. Both are totally valid.

In order to follow MVC conventions, we're going to create this file in our `app/models` directory. Let's create our new model using `touch app/models/task.rb`

In that file, create an `#initialize` method that will be called when a new Task instance is created.

```ruby
class Task
  def initialize(task_params)
    @description = task_params["description"]
    @title       = task_params["title"]
  end
end
```

Before we forget, let's `require` this new Task class in `/app/controllers/task_manager_app.rb` where we plan on using it.

```ruby
require_relative '../models/task.rb'
```

Cool. We have a Task class that we can use to create new tasks. That first line of our `post '/tasks'` method in our controller should work at this point. But what about the next one? Right now we don't have a `save` method in our Task class. Let's see if we can get that created so we can move on.

There are a lot of ways we could do this. We could potentially store each task in a CSV file and retrieve it using the CSV methods that Ruby gives us. I'm betting you could write an implementation that does that with the skills you have now. However, as our apps become more complex we're going to need more sophisticated ways to store and retrieve data. To that end, we're going to use this app as an opportunity to introduce you to some basic SQL.

### An SQL Detour

At this point, let's do some of the basic things that we need to do to get SQL set up in our project. We'll need to take the following steps:

* Add an SQL gem to our Gemfile
* Create an SQL database and a Task table in that database

Let's get started.

#### Add an SQL gem to our Gemfile

For this project, we're going to be using SQLite3. In our `Gemfile` let's add the following:

```
gem 'sqlite3'
```

And `bundle`. FIRST STEP DONE. You are amazing.

#### Create an SQL Database and Task Table (with migrations)

That's great, but how do we actually put that gem to work? We need to create a database and add some tables. We could potentially access those things directly from our terminal, but that's no fun, and it makes it pretty difficult to work with other people. Instead, let's create some migrations.

Migrations allow you to evolve your database structure over time. Each migration includes instructions to make some change to the database (e.g. adding a table, adding columns to a table, dropping a table, etc.). One advantage to this approach is that it will allow you to transfer the application to different computers without transferring the whole database. This isn't a big problem for us now, but as your database grows it will be advantageous to be able to transfer the *instructions to create the database* instead of the database itself.

To the degree possible/reasonable, we're going to work to replicate some of the naming conventions that we expect you to see in the future around migrations.

Let's start with a migration to create the database and an initial table. Create a directory for your migrations and then a file to hold your first migration:

```
$ mkdir db/migrations
$ touch db/migrations/001_create_tasks.rb
```

The 001 in the file name above helps us keep our migrations in order. If we create a table in one migration and then later in our project decide that we need to add a column to that table, the file names will keep us from trying to add a column to a table that doesn't yet exist.

Add the code below to your newly created migration.

```
# db/migrations/001_create_tasks.rb

require 'sqlite3'

database = SQLite3::Database.new("db/task_manager_development.db")
database.execute("CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT,
                                      title VARCHAR(64),
                                      description VARCHAR(64)
                                     );"
                )
puts "creating tasks table for development"
```

Run the code in this file with:

```
$ ruby db/migrations/001_create_tasks.rb
```

Congrats! You have a database? I mean, the command line told me so, right?

##### Are you sure?

We have a migration. We ran the migration. How do we know if our database was created?

We can open our database using the sqlite3 gem with the following command:

```
$ sqlite3 db/task_manager_development.db
```

That will bring us into the command line shell for SQLite3. Let's see if we've successfully created the table we wanted to create. Run the following line of code in the shell:

```
sqlite> .schema
```

You should see a description of the table that you just created in your database. Ideally there is some reference to an id, title, and description included in the response you see. That should give you some comfort that your table has been created with the proper headers.

We can also use some SQL to see what's in the database. Use the following code to select all rows from your tasks table.

```
sqlite> SELECT * FROM tasks;
```

That was a little bit anticlimactic. I expect that you didn't see any output. Take solace in the fact that if you didn't have a table in your database you would've seen an error.

Also, know that this is a great tool for us to have at our fingertips. If ever you feel like you're a little unsure of what you have in your database, know that you can poke around using the commands above.

To exit use `Ctrl-\`

We could add some data to our table from this interface, but that's not exactly what web development is all about. We have this database. Let's see if we can link it up to our app.

### Linking Our App to Our Database

One question that we might have is where exactly we want to link our database to our app. To answer this question, let's think a little bit about the MVC pattern. In our app we have the following:

* **A Controller** that we're using to marshall resources to respond to requests.
* **Views** which the controller is accessing to render HTML to send back to our client.
* **A Model** which right now is just serving as an object our controller can use to create new Tasks.

If our Task model is really supposed to be in charge of creating tasks, then right now it's only doing half it's job. Let's have our model save tasks to our new database so we can find them all later.

At the top of our `app/models/task.rb` file, let's require our new SQLite3 gem:

```
require 'sqlite3'
```

And now, in the same file add the following code to our `initialize` method:

```
@database = SQLite3::Database.new('db/task_manager_development.db')
@database.results_as_hash = true
```

For more information on the #results_as_hash method take a look at the documentation [here](http://www.rubydoc.info/github/luislavena/sqlite3-ruby/SQLite3%2FDatabase%3Aresults_as_hash).

### Writing to Our Database

Let's see if we can use this database to implement the save method that we have still hanging out in our controller.

In the Task class (`app/models/task.rb`), let's add the following method:

```ruby
def save
  @database.execute("INSERT INTO tasks (title, description) VALUES (?, ?);", @title, @description)
end
```

Just to walk through that a little bit, we're using #execute on our SQLite3::Database object and passing raw SQL. The #execute method will replace the question marks it finds in the SQL with the additional parameters (i.e. in this case `@title`, and `@description`) that we pass before running the SQL command.

### Reading from Our Database

Cool. With that in place, let's go check on our website. If you happened to have left your server running in a terminal window, be sure to quit that (using `Control-c`), and then restart it (`shotgun`). Shotgun is pretty good about picking up changes to our code, but adding that gem to our Gemfile will require a restart. In the future if you're not seeing the changes you expect, this might be one thing to check.

Once you've restarted, visit `/`, click on `New Task`, enter some information into your form, click on `Submit`, and... nothing? We're still displaying those same old tasks. Some quick investigation and we'll remember that we still have the following code in our `app/controllers/task_manager_app.rb` file:

```ruby
get '/tasks' do
  @tasks = ['task1', 'task2', 'task3']
  erb :index
end
```

We're not actually getting the tasks that we've saved, but instead always rendering the tasks in that hard coded array.

We're going to want to change that so that we can display the actual tasks that we've created, but not seeing my tasks makes me suspicious... Did we even successfully write a new task to our database with our form?

Let's drop down into our command line tool to find out. In your terminal run the following:

```
$ sqlite3 db/task_manager_development.db
sqlite > SELECT * FROM tasks;
```

I'm hoping that this returns an actual task that you created. Add a few more tasks from your browser (your server is still running in a different terminal window, right?), and then check again to see if those tasks have been added successfully.

Assuming everything checks out, let's get back to that `get 'tasks'` method.

#### Updating Our Task Manager Controller

Looking at that method, it's clear that we need to somehow get all of our tasks from the database (instead of the array that we currently have hard coded). In our SQL fueled excitement we might be tempted to access the database directly here in our controller. Don't do it!

Remember, part of our goal here is to limit what our controller has to do. Right now, the job of the controller is just to manage task manipulation and responses to requests *at a high level*. Let's keep it that way. We already have a Task class that's responsible for actually creating and saving tasks by interacting with our database. If we're going to add some more database interaction, let's add it there.

That said, we'll still need to change this method. We're going to have to go write the method that does all the work, so that means it's up to us to decide how it works. Let's replace our current `get '/tasks'` method in `/app/controllers/task_manager_app.rb` with the following:

```ruby
get '/tasks' do
  @tasks = Task.all
  erb :index
end
```

Doesn't that look great? As far as our controller is concerned, this is a pretty straightforward operation. There may be some complexity, but we're going to hide it away in our Task class.

Speaking of which, let's go write that new method we've just decided is going to exist.

#### Updating Our Task Model

The first thing to notice is that in our new `get '/tasks'` we didn't bother to create a new instance of Task before calling `Task.all`. Why not? Because `Task.new` would require us to actually create a new task with some task params, and we don't want to do that. We don't want to interact with a single instance of Task, but instead want to collect *all the tasks*.

Let's use a class method so that we can call #all without initializing a new class. Add the following code to your `/app/models/task.rb` file:

```ruby
def self.all
  database = SQLite3::Database.new('db/task_manager_development.db')
  database.results_as_hash = true
  tasks = database.execute("SELECT * FROM tasks")
  tasks.map do |task|
    Task.new(task)
  end
end
```

Why are we creating a new database object in the code above? Remember that we haven't initialized a new Task, so the code in that initialize method isn't run, and we don't have an instance variable holding the database for us. Also, note that `SQLite3::Database#new` creates a new database *object* not necessarily a new database (i.e. it doesn't overwrite our existing database), though it will create a new one if no such database exists.

#### Checking Our Results

So... if that all works, we should be able to go to `/tasks` to see all of our tasks, right? Let's check it out. Visit `/tasks` and see what you find.

Not quite what you expected? It looks to me like we switched from some simple strings that were displaying pretty well to... a mess?

#### Updating Our View

Let's go into `/app/views/index.html` and take a look at how we're displaying our tasks.

Currently I have this code:

```erb
<% @tasks.each do |task| %>
  <h3><%= task %></h3>
<% end %>
```

So, in those `<h3>` tags we're just rendering a task, which if we look at our `self.all` method in our `app/models/task.rb` file makes sense. It's a little bit surprising that these are actually showing up on the page as pound symbols, but interesting to note. Let's update our view in `/app/views/index.erb` to the following:

```erb
<% @tasks.each do |task| %>
  <h3><%= task.title %></h3>
  <p><%= task.description %></p>
<% end %>
```

Let's visit our page to see if that's done what we expect it to. Reload `/tasks` and see if you find your tasks now instead of those pesky pound signs.

No? Do you get a no method error? Bummer. If we're still on the same page it looks like we do still have a `Task` object, but `title` is not a method for that object.

That makes sense. We didn't define a `title` method. However, a `title` method is only kind of what we want. Let's go to `/app/models/task.rb` and add an `attr_reader` line.

```ruby
attr_reader :title, :description
```

Try to reload `/tasks` again, and... success!

LOOKING GOOD!

### Showing Individual Tasks

Let's see if we can show some individual tasks. At this point we should be able to rely on a lot of the pieces we have already set up. At a high level we want to do the following:

* Add a route for an individual task
* Add `#find` method to our Task class
* Add a view for an individual task
* Add links to our `index.erb` file so that we can visit individual tasks without typing them into our address bar.

Let's get started.

#### Add a route for an individual task

In our `/app/controllers/task_manager.rb` file, let's add the following code:

```ruby
get '/tasks/:id' do
  @task = Task.find(params[:id])
  erb :show
end
```

Let's visit `/tasks/1` to see what we've done.

I get an undefined method error regarding `#find` for our Task class. That's nice. That was our next step. Let's go do that.

#### Add `#find` method to our Task class

Now we need to find a specific instance of a task based on it's id. Similar to the `#all` method, we're going to want to be able to call this method without creating a specific instance of Task, so let's use a class method. In `app/models/task.rb` add the following method:

```ruby
def self.find(id)
  database = SQLite3::Database.new('db/task_manager_development.db')
  database.results_as_hash = true
  task = database.execute("SELECT * FROM tasks WHERE id = ?", id.to_i).first
  Task.new(task)
end
```

Why `#first` in the line where we define task? Even when our database is selecting only a single row, it still returns an array.

Let's visit `/tasks/1` again to see what's what. At this point I'm getting an error that's telling me my app isn't finding the `show.erb` file we told it to find.

THAT WAS OUR NEXT STEP!

#### Add a view for an individual task

Let's create the view. Create the file:

```
$ touch app/views/show.erb
```

And add HTML and ERB to that file that will display one specific task along with a link back to the task index:

```erb
<a href="/tasks">Task Index</a>

<h1><%= @task.title %></h1>

<p><%= @task.description %></p>
```

Revisit `/tasks/1` and you should see a simple page displaying your first task. But we still have some work to do...

#### Add links to our `index.erb` file

Let's see if we can link to our new `show` page from our `index.erb` file. Here's what I'm thinking we want to do in `/app/views/index.erb`:

```erb
<h1>All Tasks</h1>

<% @tasks.each do |task| %>
<h3><a href="/tasks/<%= task.id %>"><%= task.title %></a></h3>
  <p><%= task.description %></p>
<% end %>
```

Enter that code, visit `/tasks` and... we get another no method error, but this time for `id`.

Let's see if we can fix this in our Task class. HOT TIP: this is going to be just a little trickier than I would like, but let's see how it goes.

##### Adding an ID to Task

Here's the issue, currently we create Task objects at two separate times:

1. From our controller when we want to create a new task before a Task has been saved to the database, and
2. From within class methods in the Task class when we want to return Task objects based on what's currently in the database.

This is important to our current problem because the id is only generated when the task is saved to the database. The Task objects we have in 1 above won't have ids, while those in 2 will.

With that in mind, let's add the following code to our initialize method in `/app/models/task.rb`:

```ruby
@id = task_params["id"] if task_params["id"]
```

Let's also update our `attr_reader` line in the same file:

```ruby
attr_reader :title, :description, :id
```

Reload `/tasks` and at this point you should be able to see the tasks, click on a link to see an individual task, and then click on a link to take you back to the Task Index.

### Refactoring

In our `task` model, we currently have two class methods (`.all`, and `.find`) that begin with identical lines of code.

```ruby
    database = SQLite3::Database.new('db/task_manager_development.db')
    database.results_as_hash = true
```

Wouldn't it be great if we could DRY up this code? Let's put those two lines into their own method. Remove those lines, and add the following method to `/app/models/task.rb`. We'll name the method `database`, the same as the variables that we're currently using, so that we don't have to change the remaining code in the existing methods.

```ruby
  def self.database
    database = SQLite3::Database.new('db/task_manager_development.db')
    database.results_as_hash = true
    database
  end
```

Why did we have to add the last line? Remember, Ruby methods return the last line that's evaluated. The second line in this method actually returns `true`. If you'd like to see for yourself, run `t = true` or something similar in `pry` or `irb`. Alternatively, go ahead and leave that last `database` out and read through the errors you see when using the applciation. That last line returns the database itself, which is what we'll want to be using in all the other methods where we call it.

### Editing a task

Our **edit** route should bring the user to a form where they can change the title and description of the task. In order to create this functionality, we'll need to create a button to get to the edit page, a route in our controller for that link, and a view that will be rendered when we hit the new route.

In our `index.erb` view:

```erb
<h1>All Tasks</h1>

<% @tasks.each do |task| %>
  <h3><a href="/tasks/<%= task.id %>"><%= task.title %></a></h3>
  <p><%= task.description  %></p>
  <a href="/tasks/<%= task.id %>/edit">Edit</a>
<% end %>
```

In our controller:

```ruby
  get '/tasks/:id/edit' do
    @task = Task.find(params[:id])
    erb :edit
  end
```
In our view, `edit.erb`:

```erb
<form action="/tasks/<%= @task.id %>" method="post">
  <p>Edit</p>
  <input type="hidden" name="_method" value="PUT" />
  <input type='text' name='task[title]' value="<%= @task.title %>"/><br/>
  <textarea name='task[description]'><%= @task.description %></textarea><br/>
  <input type='submit'/>
</form>
```

One quick note about the form: you'll notice that there's a hidden field with a value of `PUT`. Normally, HTML forms only allow `GET` or `POST` requests (see more information [here](http://www.w3schools.com/tags/att_form_method.asp)). 

We're going to want this form to access a route in our controller (that we'll create momentarily) using `PUT` to be consistent with conventions about the HTTP verb that is used when updating a resource (take a quick look at [this table](http://www.restapitutorial.com/lessons/httpmethods.html) if this is new information). 

HTML won't allow us to use `method='put'` in our `form` tag, but passing it as a hidden value gives our controller the information it needs to route the request correctly.

### Updating a task

Our new form needs somewhere to go when a user clicks submit. We'll use the **update** route to do the work of changing the task in the database.

In our controller:

```ruby
  set :method_override, true  # this allows us to use _method in the form
  ...
  put '/tasks/:id' do |id|
    Task.update(id.to_i, params[:task])
    redirect "/tasks/#{id}"
  end
```

In our Task model:

```ruby
  def self.update(id, task_params)
    database.execute("UPDATE tasks
                      SET title = ?,
                          description = ?
                      WHERE id = ?;",
                      task_params[:title],
                      task_params[:description],
                      id)

    Task.find(id)
  end
```

### Deleting a task

We don't need a form to delete a task, we just need to know which task we want to delete. We'll use a form to send a `DELETE` request to a route with our task id.

In our `index.erb` view:

```erb
<% @tasks.each do |task| %>
  <h3><a href="/tasks/<%= task.id %>"><%= task.title %></a></h3>
  <p><%= task.description %></p>
  <a href="/tasks/<%= task.id  %>/edit">Edit</a>
  <form action="/tasks/<%= task.id %>" method="POST">
    <input type="hidden" name="_method" value="DELETE">
    <input type="submit" value="delete"/>
  </form>
<% end %>
```

In our controller:

```ruby
  delete '/tasks/:id' do |id|
    Task.destroy(id.to_i)
    redirect '/tasks'
  end
```

In our Task model:

```ruby
  def self.destroy(id)
    database.execute("DELETE FROM tasks
                      WHERE id = ?;", id)
  end
```

## Finished?
Answer the questions [here](https://gist.github.com/case-eee/1f066fa3be100f8f18f4d31f521a3da4) to recap what you've learned.

Take a moment to appreciate how cool it is that you made this all from scratch. As you move forward, you'll likely be using frameworks that give you some of this functionality for free, but it's not magic, just some thoughtful coding and elbow grease.
