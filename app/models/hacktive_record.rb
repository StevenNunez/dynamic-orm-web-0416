module HacktiveRecord
  class Base
    def self.inherited(base)
      base.class_eval do
        attr_accessor *self.columns
      end
    end

    def self.new_from_row(row)
      instance = new
      columns.each do |value|
        instance.public_send("#{value}=", row[value])
      end
      instance
    end

    def self.table_name
      to_s.downcase + "s"
    end

    def self.columns
      DB.table_info(table_name).map {|field| field["name"]}
    end

    def self.all
      query = <<-SQL
        SELECT *
        FROM #{table_name}
      SQL
      DB.execute(query).map {|row| new_from_row(row)}
    end

    def self.find(id)
      query = <<-SQL
        SELECT *
        FROM #{table_name}
        WHERE id=?
        LIMIT 1
      SQL
      DB.execute(query, id).map {|row| new_from_row(row)}.first
    end

    def persisted?
      !!id
    end

    def save
      persisted? ? update : insert
    end

    def delete
      query = <<-SQL
        DELETE FROM #{self.class.table_name}
        WHERE id=?
      SQL

      DB.execute(query, id)
      self
    end
  end

  private
  def insert
    query = <<-SQL
      INSERT INTO #{self.class.table_name}
      (#{insertable_attributes})
      VALUES (#{placeholders_for_insert})
    SQL

    DB.execute(query, insertable_attribute_values)
    self.id = DB.last_insert_row_id
    self
  end

  def insertable_attributes
    insertable_columns.join(",")
  end

  def insertable_columns
    (self.class.columns - ["id"])
  end

  def insertable_attribute_values
    insertable_columns.map do |field|
      public_send(field)
    end
  end

  def placeholders_for_insert
    size = insertable_columns.count
    Array.new(size,"?").join(',')
  end
end
