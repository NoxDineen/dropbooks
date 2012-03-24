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
        $("#finished .time_ago").text(
          jQuery.timeago(data.user.updated_at)
        );
        $("#finished .how_many").text(data.user.total_number_of_invoices);
      }
      setTimeout(function() { Dashboard.check($userId) }, 1000);
    });
  }
}