<?php

include './db.model.php';

class Admin{
    var $admin_db;
    function __construct()
    {
        global $connect;
        $this->admin_db = $connect; 
    }
    
}