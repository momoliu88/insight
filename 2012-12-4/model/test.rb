get '/home' do
  @name = 'Random User'
  erb :home
end
Example 2-19. Accessing instance variables in a view
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Using instance variables</title>
</head>
<body>
  <h1>Hello, <%= @name %>!</h1>
</body>
</html>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Using instance variables</title>
</head>
<body>
  <% @users.each do |user| %>
    <p><%= user %></p>
  <% end %>
</body>
</html>
