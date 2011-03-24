require "singleton"
class Opos_Connexion < Openplacos::Client
  include Singleton
  def initialize
    super
  end
end
