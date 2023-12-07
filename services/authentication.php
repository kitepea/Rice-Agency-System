<?php

session_start();
include '../config/httpConfig.config.php';

if (!empty($_POST)) {
    // do authentication
    echo "Success";
} else {
    // require user to provide infomation
    echo "Failed";
}