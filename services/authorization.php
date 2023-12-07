<?php

session_start();
include '../config/httpConfig.config.php';

if (!isset($_SESSION['id'])) {
    $data = array(
        "status_code" => 401,
        "status_message" => getStatusCode(401)
    );
    // header('Location: /public/login/index.html');
} else {
    $data = array(
        "status_code" => 200,
        "status_message" => getStatusCode(200)
    );
}

echo json_encode($data);