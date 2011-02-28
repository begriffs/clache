<?php
set_time_limit(0);
ini_set('memory_limit', '512M');
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
$u = cl_fr($db, $t, 10000);
$normal = cl_normal($db, $u);
header('X-Reductions: ' . (cl_distance($db, $t, $u) + 0));
header('X-Normal: ' . ($normal ? '1' : '0'));
if($normal) {
	header('Cache-Control: max-age=3155760000');
} else {
	header('HTTP/1.1 503 Service Temporarily Unavailable');
}
echo cl_serialize($u);
pg_close($db);
?>
