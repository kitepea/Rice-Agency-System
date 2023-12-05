$(document).ready(function() {
    $("#showpwd").click(function() {
        if($(this).is(":checked")) {
            $("#inputPassword").attr("type", "text");
        } else {
            $("#inputPassword").attr("type", "password");
        }
    });
});