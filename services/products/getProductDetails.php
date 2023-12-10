<?php
include '../../models/db.model.php';
include '../../models/product.model.php';
global $connect;

$product = new Product();

if ($_SERVER['REQUEST_METHOD'] = 'GET') {
    $details = $product->getProductDetails($_GET['id_product'], $_GET['type']);
    echo $details;
}

?>