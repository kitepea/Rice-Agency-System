<?php
include 'db.model.php';

class Product
{
    var $product_db;

    function __construct()
    {
        global $connect;
        $this->product_db = $connect;
    }

    function getAllProducts()
    {
        $stmt = sqlsrv_query($this->product_db, "EXEC getAllProducts");

        if ($stmt === false) {
            die(print_r(sqlsrv_errors(), true));
        }


        $ret_object = array();
        while ($result = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
            array_push($ret_object, $result);
        }

        return $ret_object;
    }
}
