<% (['production'] + [@environment]).uniq.each do |env| -%>
<%= env %>:
    host: <%= @redis[:host] %>
    port: <%= @redis[:port] %>
<% end %>
