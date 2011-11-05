module ApplicationHelper

  def room_tree(room,current,user)
      str = ""
      if Opos_Connexion.instance.readable?(room.path,user)
      room_name = room.path.split("/").pop || "/"
      room_name = "<div class='current_room'>#{room_name}</div>" if current==room.path
        str = "<li><a href='/rooms#{room.path}'>#{room_name}</a></li>\n"
        room.childs.each{ |child|
          str << "<ul>"
          str << room_tree(child,current,user)
          str << "</ul>\n"
        }
      end
      #str << "</li>\n"
      return str  
  end

    def get_avatar(email_address)
  
    # create the md5 hash
    hash = Digest::MD5.hexdigest((email_address || "default").downcase)

    # compile URL which can be used in <img src="RIGHT_HERE"...
    return "http://www.gravatar.com/avatar/#{hash}?d=mm"

  end
  
end
