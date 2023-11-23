$(this).ready(function () {
  $.get("/components/header.html", function (data) {
    $("body").prepend(data);
    $(".book-upload").css("display", "none");
  });

  $.get("/components/footer.html", function (data) {
    $("body").append(data);
  });

  $(".list-image").css("height", $(".preview-image").height());

  $(".demo").click(function () {
    $(".preview-image").css(
      "background-image",
      $("." + this.classList[1]).css("background-image")
    );
  });

  //demo image function
  $(".product-image").ready(function () {
    var n = $(".demo-image .demo").length;
    for (let i = 1; i <= n; i++) {
      var url = 'url("/assets/images/book-1-' + i + '.png")';
      var select = ".demo-image .demo-" + i;
      $(select).css("background-image", url);
    }
    $(".show-image").css(
      "background-image",
      $(".demo-image .demo-1").css("background-image")
    );
    $(".demo-image .demo").click(function () {
      $(".show-image").css("background-image", $(this).css("background-image"));
    });
  });
  //quantity increase and reduce function
  $("#increase").click(function () {
    $("#quantity").val(Number($("#quantity").val()) + 1);
  });
  $("#reduce").click(function () {
    $("#quantity").val(function () {
      if (Number($("#quantity").val()) < 2) return 1;
      else return Number($("#quantity").val()) - 1;
    });
  });

  $(".view-seller-page").click(function (e) { 
    e.preventDefault();
      location.href = "/pages/user/info/seller-information (buyer)"
  });
});
