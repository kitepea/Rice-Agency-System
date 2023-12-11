<?php

session_start();
include '../config/httpConfig.config.php';
include '../models/account.model.php';

function validateInput($body)
{
    return true;
}

$input = file_get_contents("php://input");
$input = json_decode($input,true);


if ($input) {
    if (validateInput($input)) {
        $account = new Account();
        $result = $account->findUserName($input['inputUsername']);

        if ($result) {
    
            $password_db = $result['Password'];

            if (password_verify($input['inputPassword'], $password_db)) {
                $_SESSION["auth"] = true;
                $data = array(
                    "status_code" => 200,
                    "status_message" => "Đăng nhập thành công"
                );
            } else {
                $data = array(
                    "status_code" => 406,
                    "status_message" => "Thông tin đăng nhập sai"
                );
            }
        } else {
            $data = array(
                "status_code" => 404,
                "status_message" => "Không tìm thấy tài khoản"
            );
        }
    }
} else {
    // require user to provide infomation
    $data = array(
        "status_code" => 400,
        "status_message" => "Vui lòng nhập thông tin đăng nhập"
    );
}

http_response_code($data['status_code']);
echo json_encode($data);
