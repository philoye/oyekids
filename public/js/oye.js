$(document).ready(function() {

  target = $(".container");
  
  current_width = target.width();
  num_columns = Math.floor((current_width - 4) / 79);
  new_width = (num_columns * 79);
  
  target.width(new_width);
  
});
