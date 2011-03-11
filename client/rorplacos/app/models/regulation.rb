class Regulation

  def initialize(connection, path)
     @connect = connection
     @path = path
     @backend = connection.reguls[@path]
  end

end
