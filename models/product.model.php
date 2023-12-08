<?php

include 'db.model.php';


class Product {
    var $product_db;

    function __construct()
    {
        global $connect;
        $this->product_db = $connect;
    }


}
