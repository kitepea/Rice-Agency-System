<?php
session_start();

if (isset($_SESSION['auth']) && $_SESSION['auth'] == true) {
    header("Location: /public/mainpage/mainpage.html");
} else {
    header("Location: /public/login/index.html");
}

