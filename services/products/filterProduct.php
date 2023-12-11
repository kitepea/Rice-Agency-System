<?php
include '../../models/db.model.php';
include '../../models/product.model.php';
include '../../config/httpConfig.config.php';

global $connect;

$product = new Product();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $results = $product->filterProducts($input['filter-type'], $input['sort']);

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
}

http_response_code($data['status_code']);
echo json_encode($data, JSON_UNESCAPED_UNICODE);