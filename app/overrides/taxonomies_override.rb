Deface::Override.new(:virtual_path => "spree/shared/_taxonomies", 
                     :name => "taxonomies_override", 
                     :replace => "h4.taxonomy-root", 
                     :text => "<h1 class='taxonomy-root'><%= Spree.t(:shop_by_taxonomy, :taxonomy => taxonomy.name) %></h1>")