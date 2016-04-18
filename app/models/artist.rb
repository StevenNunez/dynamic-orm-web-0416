class Artist < HacktiveRecord::Base
  private
  def update
    query = <<-SQL
      UPDATE artists
      SET name=?
      WHERE id=?
    SQL

    DB.execute(query, name, id)
    self
  end
end
