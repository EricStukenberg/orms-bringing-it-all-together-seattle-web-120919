require 'pry'
class Dog 
    attr_accessor :id, :name, :breed
    def initialize(id: nil, name:, breed:)
        @id = id
        @name =name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
        SQL
    
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end


    def save
        if self.id
          self.update
        else
          sql = <<-SQL
            INSERT INTO dogs (name, breed) 
            VALUES (?, ?)
          SQL
    
          DB[:conn].execute(sql, self.name, self.breed)
          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        return dog
    end
    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
 
        sql = <<-SQL
          SELECT * FROM dogs WHERE id = ? LIMIT 1;
        SQL
         
        dog = DB[:conn].execute(sql,id)[0]
        self.new_from_db(dog)
      end

    def self.find_by_name(name)
 
        sql = <<-SQL
          SELECT * FROM dogs WHERE name = ? LIMIT 1;
        SQL
         
        dog = DB[:conn].execute(sql,name)[0]
        self.new_from_db(dog)
      end


      def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs 
        WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
          dog_data = dog[0]
          dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
          dog = self.create(name: name, breed: breed)
        end
        dog
      end

end