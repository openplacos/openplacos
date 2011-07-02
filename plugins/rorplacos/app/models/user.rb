require 'digest/sha1'

class User < ActiveRecord::Base
  validates :login,  :presence => true
  has_many :posts
  
  def self.authenticate(user_name,password)
    sha1 = Digest::SHA1.hexdigest(password<<"_openplacos")
    ack = Opos_Connexion.instance.auth(user_name,sha1)
    if ack==true
      if User.find(:first, :conditions => {:login => user_name}).nil?
        user_id = User.create(:login => user_name).id
      end
    end
    
    return ack
  end

end
