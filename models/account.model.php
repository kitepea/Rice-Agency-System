<?php

include __DIR__ . '/db.model.php';

class Account
{
    var $account_db;
    function __construct()
    {
        global $connect;
        $this->account_db = $connect;
    }

    function findUserName($username_input)
    {
        $stmt = sqlsrv_query($this->account_db, "select * from findUserWith('$username_input')");

        if ($stmt === false) {
            die(print_r(sqlsrv_errors(), true));
        }

        $result = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC);
        if ($result) {
            return array(
                "Username" => $result['Username'],
                "Password" => $result['Password']
            );
        } else {
            return null;
        }
    }
}

