<?php
include '../../models/db.model.php';
include '../../models/product.model.php';
global $connect;

$product = new Product();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $details = $product->deleteProduct($_POST['id_product']);
    echo $details;
}
