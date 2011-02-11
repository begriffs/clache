<?php
set_time_limit(0);
include('parse.php');
include('reduce.php');
$db = pg_connect("host=localhost dbname=clweb user=postgres password=password")
    or die('Could not connect: ' . pg_last_error());
cl_init($db);
?>
<pre><?php cl_fr($db, cl_parse($_GET['cl']), 500, 1); ?></pre>
<?php
pg_close($db);
?>
