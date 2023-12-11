<?php
include '../../models/db.model.php';
include '../../models/product.model.php';
global $connect;

$product = new Product();

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $details = $product->deleteProduct($_GET['id_product']);
    echo $details;
    header('Location: ../../public/mainpage/mainpage.html');
}
