var test;
$("#submit-btn").click(function (event) {
    event.preventDefault();
    console.log(JSON.stringify({
        inputUserName: $("#intputUsername").val(),
        inputPassword: $("#inputPassword").val()
    }));
    fetch('http://localhost/services/authentication.php', {
        method: 'POST',
        credentials: "include",
        headers: {
            "Content-type": "application/json"
        },
        body: JSON.stringify({
            inputUserName: $("#intputUsername").val(),
            inputPassword: $("#inputPassword").val()
        })
    })
        .then(response => response)
        .then(json => {
     
            switch (json.status) {
                case 200:
                    window.location = "http://localhost/public/mainpage/mainpage.html";
                    break;
                case 404:
                case 406:
                    $("#noti").text("Thông tin đăng nhập sai");
                    break;
            }

        })
});
