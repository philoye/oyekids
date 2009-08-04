$(document).ready(function() {

  function resizeContainer() {
    var window_width = $(window).width();
    var num_columns = Math.floor((window_width - 50) / 79);
    var new_width = (num_columns * 79);
    $(".container").width(new_width);
  }

  var resizeTimer = null;
  $(window).resize(function() {
      if (resizeTimer) clearTimeout(resizeTimer);
      resizeTimer = setTimeout(resizeContainer, 100);
  });
  
  resizeContainer();
  
});
