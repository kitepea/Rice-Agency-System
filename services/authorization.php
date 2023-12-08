<?php

session_start();
include '../config/httpConfig.config.php';

if (!isset($_SESSION['id'])) {
    $data = array(
        "status_code" => 401,
        "status_message" => "Not Authorized, must go back to login"
    );
    // header('Location: /public/login/index.html');
} else {
    $data = array(
        "status_code" => 200,
        "status_message" => "Authorized, can redirect to next page"
    );
}

http_response_code($data['status_code']);
echo json_encode($data);