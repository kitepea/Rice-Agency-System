<?php

include 'db.model.php';


class Product {
    var $product_db;

    function __construct()
    {
        global $connect;
        $this->product_db = $connect;
    }

    function getProductDetails($id_product, $type) {
        $sql = "SELECT * FROM GetProductDetails(?, ?)";
        $stmt = sqlsrv_query($this->product_db, $sql, array($id_product, $type));
        
        if ($stmt) {
            $row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC);
            return json_encode($row, JSON_UNESCAPED_UNICODE);
        } else {
            die(print_r(sqlsrv_errors(SQLSRV_ERR_ERRORS)));
        }
    }
}
