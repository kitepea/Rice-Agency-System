<?php
include '../models/product.model.php';

include '../config/httpConfig.config.php';

header('Access-Control-Allow-Method: GET');


if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $product = new Product();
    $results = $product->getAllProducts();

    if (!empty($results)) {
        $data = array(
            "status_code" => 200,
            "status_message" => "Fetched all products successfully",
            "data" => $results
        );
    } else {
        $data = array(
            "status_code" => 404,
            "status_message" => "Not found any products"
        );
    }
} else {
    $data = array(
        "status_code" => 405,
        "status_message" => "Method Not Allowed"
    );
}


http_response_code($data['status_code']);
echo json_encode($data, JSON_UNESCAPED_UNICODE);
