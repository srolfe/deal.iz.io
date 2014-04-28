<?php
$mysql_user='dealizio';
$mysql_pass='eN66srafW7P7AQ2x';
$mysql_db='dealizio';

/*
function reportAnalytic($type,$ad){
	// What we should save:
	// User ID, type, additional, timestamp
	// Types
	// 0 - fetch feed (ad per page)
	// 1 - filtered feed
	// 2 - saveFav
	// 3 - removeFav
	// 4 - disSite
	// 5 - enSite
	// 6 - saveFit
	// 7 - editFit
	// 8 - removeFit
	// 9 - addPushToken (app launched)
	
	$ad=mysql_real_escape_string(json_encode($ad));
	
	$q="INSERT into capizio VALUES('','".$user['id']."','".$type."','".$ad."','".time()."')";
	mysql_query($q,$mysql);
}
*/

$choices=array(
	'Load feed',
	'Load filtered feed',
	'Save favorite',
	'Remove favorite',
	'Disable site',
	'Enable site',
	'Save filter',
	'Edit filter',
	'Remove filter',
	'Opened app'
);


$mysql=mysql_connect('localhost',$mysql_user,$mysql_pass);
mysql_select_db($mysql_db,$mysql);

$d=isset($_GET['d'])?$_GET['d']:1;
$h=isset($_GET['h'])?$_GET['h']:24;

$q="SELECT * FROM capizio WHERE timestamp>=".(time()-(60*60*$h*$d))." ORDER BY timestamp DESC";
$res=mysql_query($q,$mysql) or die(mysql_error());

$ii=0;
$users=array();
while ($row=mysql_fetch_row($res)){
	if (!isset($user[$row[1]])){
		$user[$row[1]]=1;
	}
	
	echo date('D M j G:i:s T',$row[4])." - ".$row[1]." - ".$choices[$row[2]]." - [ARGS] - ".$row[3]."<br>";
	$ii++;
}

$dd=0;
foreach ($user as $uu){
	$dd++;
}

echo "<br><br>TOTAL QUERIES: ".$ii;
echo "<br>TOTAL USERS ACTIVE: ".$dd;
echo "<br>QUERIES PER USER: ".($ii/$dd);
?>