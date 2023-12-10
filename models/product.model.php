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
        $stmt = sqlsrv_prepare($this->product_db, $sql, array($id_product, $type));
        
        if ($stmt) {
            while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
                $result[] = $row;
            }
            return json_encode($result, JSON_UNESCAPED_UNICODE);
        } else {
            die(print_r(sqlsrv_errors(), true));
        }
    }
}
