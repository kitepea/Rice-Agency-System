$(this).ready(function () {

  $(".signin").click(function (e) {
    e.preventDefault();
    location.href = "../signin/";
  });

  $(".login-btn").click(function (e) { 
    e.preventDefault();
  });

  $(".show-pwd").click(function (e) {
    e.preventDefault();
    $(this).css("display", "none");
    $(".hide-pwd").css("display", "block");
    $("#pwd")[0].type = "text";
  });

  $(".hide-pwd").click(function (e) {
    e.preventDefault();
    $(this).css("display", "none");
    $(".show-pwd").css("display", "block");
    $("#pwd")[0].type = "password";
  });
});
