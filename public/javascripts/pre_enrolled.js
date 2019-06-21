$('#main-button').click( function() {
    var min_date = document.getElementById("min_date").value;
    var max_date = document.getElementById("max_date").value;

    if(min_date && max_date){
      if(min_date > max_date){
        alert("Minimum date can't be bigger than maximum date!")
      }else{
        $.ajax({
          method: "POST",
          url: "/profile/" + window.location.pathname.split("/")[2] + "/plugin/fga_internship/index_pre_enrolled_students_filter_by_date/",
          data: { min_date: min_date, max_date: max_date }
        })
        .done(function(data){

          var old_tbody = document.getElementById("main-tbody")
          var new_tbody = document.createElement('tbody');
          new_tbody.id = "main-tbody"

          for (var x in data){
            var tr = document.createElement('tr');
            var td1 = document.createElement('td');
            var td2 = document.createElement('td');
            var td3 = document.createElement('td');
            var td4 = document.createElement('td');
            td1.appendChild(document.createTextNode(data[x].name))
            td2.appendChild(document.createTextNode(data[x].email))
            td3.appendChild(document.createTextNode(data[x].date))
            td4.appendChild(document.createTextNode(data[x].time))
            tr.appendChild(td1)
            tr.appendChild(td2)
            tr.appendChild(td3)
            tr.appendChild(td4)
            new_tbody.appendChild(tr)
          }

          old_tbody.parentNode.replaceChild(new_tbody, old_tbody)
        })
      }
    }else{
      alert("Fill in all fields to filter!")
    }
});
