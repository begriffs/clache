<?php
set_time_limit(0);
include('parse.php');
include('reduce.php');
header("Content-Type: text/plain");
header("X-Powered-By: clache");
$db = pg_connect("host=localhost dbname=clweb user=postgres password=password")
    or die('Could not connect: ' . pg_last_error());
cl_init($db);
$t = cl_parse($_GET['cl']);
if(!$t) {
	header('HTTP/1.1 400 Bad Request');
?>URL is not a well-formed combinatory logic term<?php
	die();
}
cl_fr($db, cl_parse($_GET['cl']), 500, 1);
pg_close($db);
?>
