// This javascript code is for the text part of a lesson.  It highlights the
// current paragraph being read.
$(document).ready( hash_changed);

$(window).bind( 'hashchange', hash_changed);

function hash_changed(e) {
  var hash = window.location.hash;
  console.log("Highlighting "+hash);
  if( $(hash + "-on").size() > 0 ) {
    $(".page_on").hide();         // all other markers.
    $(".page_off").show();
    $(hash + "-on").show();
    $(hash + "-off").hide();
  }
}
