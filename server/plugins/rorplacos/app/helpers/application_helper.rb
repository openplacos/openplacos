module ApplicationHelper

  require 'dbus-openplacos'

  def room_tree(room,current)
      room_name = room.path.split("/").pop || "/"
      room_name = "<div class='current_room'>#{room_name}</div>" if current==room.path
      str = "<li><a href='/rooms#{room.path}'>#{room_name}</a></li>\n"
      room.childs.each{ |child|
        str << "<ul>"
        str << room_tree(child,current)
        str << "</ul>\n"
      }
      #str << "</li>\n"
      return str  
  end
end
