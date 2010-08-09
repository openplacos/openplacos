#!/usr/bin/env ruby


require 'libglade2'
require 'gtk2'

class MonAppli
  attr_reader :main_glade
  def initialize(file, root)
    @main_glade = GladeXML.new(file, root) {|handler| method(handler)}
    tree1 = @main_glade["tree"]
    renderer = Gtk::CellRendererText.new
    column = Gtk::TreeViewColumn.new("Carte", renderer, "text" => 0)
    tree1.append_column(column)
    store = Gtk::TreeStore.new (String)
    tree1.model = store
    
    @parent = store.append(nil)
    store.set_value(@parent, 0, "uCham")
    puts @main_glade["set_model_container"].class
    @main_glade["set_model_container"].pack_start = Gtk::ComboBox.new (true)
    combo = Gtk::ComboBox.new (true)
    @main_glade["select_model"] = combo
    @main_glade["select_model"].append_text("test")
     @main_glade["main"].show_all
  end 

  def on_add_card_clicked
    tree1 = @main_glade["tree"]
    store = tree1.model 
    list = Array.new
    list.push("Pin 0")

    list.each_with_index do |e, i|
      iter = store.append(@parent)
      store.set_value(iter, 0, list[i])
    end

    @main_glade["tree"].show_all
  
  end 

  def on_close_clicked
    Gtk.main_quit
  end 

  def on_assistant_add_device_close
    puts @main_glade["assistant_add_device"].class
    @main_glade["assistant_add_device"].close
  end


end 


Gtk.init
MonAppli.new("main.glade", nil)

Gtk.main
