Deface::Override.new(:virtual_path => "spree/shared/_header", 
                     :name => "header_override", 
                     :insert_before => "figure#logo", 
                     :text => "<div class='top-menu'><a href="">Меню</a></div>")

Deface::Override.new(:virtual_path => "spree/shared/_header", 
					 :name => "change_figure_class",
                     :set_attributes => "figure#logo", 
                     :attributes => {:class => 'main-logo'})

Deface::Override.new(:virtual_path => "spree/shared/_header", 
                     :name => "remove_main_navbar_container", 
                     :remove => "header#header + .container")
