var navShowing = false;

$(function() {
  $("button").click(function() {
    var button = $(this);
    var section_id = this.getAttribute("section_id");
    button.hide();
    if(button.hasClass("show")) {
      button.next().show();
      $("#content_" + section_id).show()
      $("#back_to_top_for_" + section_id).show()
    } else {
      $("#content_" + section_id).hide()
      $("#back_to_top_for_" + section_id).hide()
      button.prev().show();
    }
  })
  
  $("#logo").click(function() {
    $("#nav").toggle();
  })
  
  $("#clearButton").click(clearText)
});

var clearText = function() {
  document.getElementById("searchField").value = "";
  $("#searchField").val("").focus();
}