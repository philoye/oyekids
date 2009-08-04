$(document).ready(function() {

  target = $(".container");
  
  current_width = target.width();
  num_columns = Math.floor((current_width - 4) / 79);
  new_width = (num_columns * 79);
  
  target.width(new_width);
  
});


// var resizeTimer = null;
// $(window).bind('resize', function() {
//     if (resizeTimer) clearTimeout(resizeTimer);
//     resizeTimer = setTimeout(doSomething, 100);
// });

// function resizeStuff() {
//  //Time consuming resize stuff here
// }
// var TO = false;
// $(window).resize(function(){
//  if(TO !== false)
//     clearTimeout(TO);
//  TO = setTimeout(resizeStuff, 200); //200 is time in miliseconds
// });