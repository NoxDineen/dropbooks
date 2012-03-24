var Dashboard = {
  check: function(userId) {
    var $userId = userId;
    $.getJSON("/users/"+$userId+".json", function(data) {
      console.log(data.user.status);
      if (data.user.status == "running") {
        $("#finished").hide();
        $("#running").show();
      } else {
        $("#running").hide();
        $("#finished").show();
      }
      setTimeout(function() { Dashboard.check($userId) }, 1000);
    });
  }
}