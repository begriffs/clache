<?php 
function cl_fr($db, $t, $m, $d) {
	if($d > $m || is_string($t) || cl_normal($db, $t)) {
		return $t;
	}
	/////////////////////////////////////////////////////
	//// if t is not on the frontier, get out there! ////
	$u = cl_current_fr($db, $t);
	if($u) {
		echo "jump: " . cl_serialize($u) . "\n";
		return cl_fr($db, $u, $m, $d);
	}
	/////////////////////////////////////////////////////
	////    check for reduction by basic rules       ////
	if($t['l'] == 'i') {
		$u = $t['r'];
	} else if(!is_string($t['l']) && $t['l']['l'] == 'k') {
		$u = $t['l']['r'];
	} else if(!is_string($t['l']) &&
	          !is_string($t['l']['l']) &&
	          $t['l']['l']['l'] == 's') {
		$u = array(
			'l' => array('l' => $t['l']['l']['r'], 'r' => $t['r']),
			'r' => array('l' => $t['l']['r'],      'r' => $t['r'])
		);
	}
	/////////////////////////////////////////////////////
	////          if reduces by basic rules          ////
	if($u) {
		echo 'memo: ' . cl_serialize($t) . '  ####  ' . cl_serialize($u) . "\n";
		cl_memoize($db, $t, $u, 1);
		return cl_fr($db, $u, $m, $d + 1);
	}

	/////////////////////////////////////////////////////
	////          leftmost, outermost first          ////
	$l = $t['l'];
	$l2 = cl_fr($db, $l, $m, $d + 1);
	$e = cl_distance($db, $l, $l2);
	if($e > 0) {
		$t2 = array('l' => $l2, 'r' => $t['r']);
		echo 'memo: ' . cl_serialize($t) . '  ####  ' . cl_serialize($t2) . "\n";
		cl_memoize($db, $t, $t2, $e);
		return cl_fr($db, $t2, $m, $d + $e);
	}
	/////////////////////////////////////////////////////
	////             then the other side             ////
	$r = $t['r'];
	$r2 = cl_fr($db, $r, $m, $d + 1);
	$e = cl_distance($db, $r, $r2);
	if($e > 0) {
		$t2 = array('l' => $l, 'r' => $r2);
		echo 'memo: ' . cl_serialize($t) . '  ####  ' . cl_serialize($t2) . "\n";
		cl_memoize($db, $t, $t2, $e);
		return cl_fr($db, $t2, $m, $d + $e);
	}
	if(cl_normal($db, $l) && cl_normal($db, $r)) {
		echo 'norm: ' . cl_serialize($t) . "\n";
		cl_mark_normal($db, $t);
	}
	return $t;
}

function cl_init($db) {
	pg_prepare($db, 'normal', 'SELECT proved_normal FROM term WHERE cl = $1');
	pg_prepare($db, 'memoize', 'SELECT memoize($1, $2, $3)');
	pg_prepare($db, 'curfr', 'SELECT id_cl(reduct) AS reduct FROM f WHERE redex = cl_id($1)');
	pg_prepare($db, 'dist', 'SELECT d FROM f WHERE redex = cl_id($1) AND reduct = cl_id($2)');
	pg_prepare($db, 'marknormal', 'SELECT mark_normal($1)');
}

function cl_normal($db, $t) {
	$r = pg_fetch_array(pg_execute($db, 'normal', array(cl_serialize($t))),
	                    null, PGSQL_ASSOC);
	return $r['proved_normal'] == 't';
}

function cl_mark_normal($db, $t) {
	pg_execute($db, 'marknormal', array(cl_serialize($t)));
}

function cl_memoize($db, $a, $b, $d) {
	pg_execute($db, 'memoize', array(cl_serialize($a), cl_serialize($b), $d));
}

function cl_distance($db, $a, $b) {
	$r = pg_fetch_array(
		pg_execute($db, 'dist', array(cl_serialize($a), cl_serialize($b))),
		null, PGSQL_ASSOC);
	return $r['d'];
}

function cl_current_fr($db, $t) {
	$r = pg_fetch_array(pg_execute($db, 'curfr', array(cl_serialize($t))),
	                    null, PGSQL_ASSOC);
	return $r ? cl_parse($r['reduct']) : FALSE;
}
?>