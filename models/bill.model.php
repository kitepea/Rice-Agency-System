<?php

include 'db.model.php';


class Bill
{
    var $bill_db;

    function __construct()
    {
        global $connect;
        $this->bill_db = $connect;
    }

    function getAllRiceNameHasBeenSold()
    {
        // prepare statement
        $stmt = sqlsrv_query($this->bill_db, "EXEC getAllPnameHasBeenSold");

        if ($stmt === false) {
            die(print_r(sqlsrv_errors(), true));
        }

        // Get all record from return result
        $set_result = array();
        while ($result = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
            array_push($set_result, $result);
        }

        return $set_result;
    }
}
