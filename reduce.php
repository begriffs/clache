<?php 
function cl_fr($db, $t, $tether, $maxsz) {
	if($tether < 1 || $t[0] != '`' || strlen($t) > $maxsz || cl_normal($db, $t)) {
		return $t;
	}
	/////////////////////////////////////////////////////
	//// if t is not on the frontier, get out there! ////
	$u = cl_current_fr($db, $t);
	if($u) {
    $e = cl_distance($db, $t, $u);
    return cl_fr($db, $u, $tether - $e, $maxsz);
	}
	/////////////////////////////////////////////////////
	////    check for reduction by basic rules       ////
	if(strncmp($t, '`i', 2) === 0) {
		$u = substr($t, 2);
	} else if(strncmp($t, '``k', 3) === 0) {
		$u = substr($t, 3, cl_eot($t, 3));
	} else if(strncmp($t, '```s', 4) === 0) {
		$len_x = cl_eot($t, 4);
		$len_y = cl_eot($t, 4+$len_x);
		$len_z = cl_eot($t, 4+$len_x+$len_y);
		$x     = substr($t, 4, $len_x);
		$y     = substr($t, 4+$len_x, $len_y);
		$z     = substr($t, 4+$len_x+$len_y, $len_z);
		$u = "``$x$z`$y$z";
	}

	/////////////////////////////////////////////////////
	////          if reduces by basic rules          ////
	if($u) {
		cl_memoize($db, $t, $u, 1);
		return cl_fr($db, $u, $tether - 1, $maxsz);
	}

	$split = cl_eot($t, 1);
	$l = substr($t, 1, $split);
	$r = substr($t, $split+1);
	/////////////////////////////////////////////////////
	////          leftmost, outermost first          ////
	$l2 = cl_fr($db, $l, $tether, $maxsz);
	$e = cl_distance($db, $l, $l2);
	if($e > 0) {
		$t2 = "`$l2$r";
		cl_memoize($db, $t, $t2, $e);
		return cl_fr($db, $t2, $tether - $e, $maxsz);
	}
	/////////////////////////////////////////////////////
	////             then the other side             ////
	$r2 = cl_fr($db, $r, $tether, $maxsz);
	$e = cl_distance($db, $r, $r2);
	if($e > 0) {
		$t2 = "`$l$r2";
		cl_memoize($db, $t, $t2, $e);
		return cl_fr($db, $t2, $tether - $e, $maxsz);
	}
	if(cl_normal($db, $l) && cl_normal($db, $r)) {
		cl_mark_normal($db, $t);
	}
	return $t;
}


function cl_eot($t, $offset) {
	$balance = 1;
	$length = 0;
	do {
		$balance += ($t[$offset+$length] == '`' ? 1 : -1);
		$length++;
	} while($balance > 0);
	return $length;
}

function cl_init($db) {
	pg_prepare($db, 'normal', 'SELECT normal FROM term WHERE cl = $1');
	pg_prepare($db, 'memoize', 'SELECT memoize($1, $2, $3)');
	pg_prepare($db, 'curfr', 'SELECT b AS reduct FROM f WHERE a = $1');
	pg_prepare($db, 'dist', 'SELECT d FROM f WHERE a = $1 AND b = $2');
	pg_prepare($db, 'marknormal', 'SELECT mark_normal($1)');
	pg_prepare($db, 'short', 'SELECT shortest($1)');
}

function cl_normal($db, $t) {
	$r = pg_fetch_array(pg_execute($db, 'normal', array($t)),
	                    null, PGSQL_ASSOC);
	return isset($r) ? $r['normal'] == 't' : FALSE;
}

function cl_mark_normal($db, $t) {
	pg_execute($db, 'marknormal', array($t));
}

function cl_memoize($db, $a, $b, $d) {
	pg_execute($db, 'memoize', array($a, $b, $d));
}

function cl_distance($db, $a, $b) {
	$r = pg_fetch_array(
		pg_execute($db, 'dist', array($a, $b)),
		null, PGSQL_ASSOC);
	return $r['d'];
}

function cl_current_fr($db, $t) {
	$r = pg_fetch_array(pg_execute($db, 'curfr', array($t)),
	                    null, PGSQL_ASSOC);
	return $r ? $r['reduct'] : FALSE;
}

function cl_shortest($db, $t) {
	$r = pg_fetch_array(pg_execute($db, 'short', array($t)),
	                    null, PGSQL_ASSOC);
	return $r ? $r['shortest'] : FALSE;
}
?>
