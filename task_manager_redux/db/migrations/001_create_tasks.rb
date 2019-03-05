require 'sqlite3'

database = SQLite3::Database.new("db/task_manager_development.db")
database.execute("CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT,
                                      title VARCHAR(64),
                                      description VARCHAR(64)
                                     );"
                )
puts "creating tasks table for development"
