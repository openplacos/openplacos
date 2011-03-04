module ApplicationHelper

  require 'dbus-openplacos'

  def room_tree(room)
      room_name = room.path.split("/").pop || "/"
      str = "<li><a href='/opos#{room.path}'>#{room_name}</a></li>\n"
      room.childs.each{ |child|
        str << "<ul>"
        str << room_tree(child)
        str << "</ul>\n"
      }
      #str << "</li>\n"
      return str  
  end

end
