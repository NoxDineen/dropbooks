var Dashboard = {
  check: function(userId) {
    var $userId = userId;
    $.getJSON("/users/"+$userId+".json", function(user) {
      console.log(user.status);
      if (user.status == "running") {
        $("#finished").hide();
        $("#running").show();
      } else {
        $("#running").hide();
        $("#finished").show();
        $("#finished .time_ago").text($.timeago(user.updated_at));
        $("#finished .how_many").text(user.total_number_of_invoices);
      }
      setTimeout(function() { Dashboard.check($userId) }, 5000);
    });
  }
}