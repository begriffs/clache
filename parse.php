<?php
function cl_parse($cl) {
	$ar = preg_split('//', $cl, -1, PREG_SPLIT_NO_EMPTY);
	$ret = _parse($ar);
	return count($ar) > 0 ? false : $ret;
}

function _parse(&$a) {
	$t = array_shift($a);
	if(in_array($t, array('s', 'k', 'i'))) {
		return $t;
	} else if($t == '`') {
		$l = _parse($a);
		$r = _parse($a);
		if(!$l or !$r) { return false; }
		return array('l' => $l, 'r' => $r);
	} else {
		return false;
	}
}

function cl_serialize($t) {
	if(is_string($t)) {
		return $t;
	}
	return '`' . cl_serialize($t['l']) . cl_serialize($t['r']);
}
?>
