<?php
include '../../models/db.model.php';
include '../../models/product.model.php';
global $connect;

$product = new Product();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $details = $product->updateProduct($_POST['id_product'], $_POST['product_name'], $_POST['desc'], $_POST['featured'], $_POST['origin'], $_POST['picture'], $_POST['cname'], $_POST['type'], $_POST['price']);
    echo $details;
}
