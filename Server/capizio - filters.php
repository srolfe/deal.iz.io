<?php
$mysql_user='dealizio';
$mysql_pass='eN66srafW7P7AQ2x';
$mysql_db='dealizio';

$mysql=mysql_connect('localhost',$mysql_user,$mysql_pass);
mysql_select_db($mysql_db,$mysql);

$sql="SELECT * FROM filters";
$res=mysql_query($sql,$mysql);

while ($row=mysql_fetch_row($res)){
	foreach (explode("|",$row[4]) as $key){
		$key_list[strtolower($key)][]=$row[0];
	}
}

$ii=0;
$keys=array_keys($key_list);
foreach ($key_list as $kk){
	echo '"'.$keys[$ii].'" - '.count($kk)."<br>";
	$ii++;
}
?>