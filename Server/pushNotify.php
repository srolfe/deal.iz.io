<?php
// Push config
$apnsHost="gateway.push.apple.com";
$apnsPost=2195;
chdir("/var/www/html/dealizio/server_scripts");
$apnsCert="apns-dev.pem";

// MySQL config
$mysql_user='dealizio';
$mysql_pass='eN66srafW7P7AQ2x';
$mysql_db='dealizio';

// Open up our connection to MySQL
$mysql=mysql_connect('localhost',$mysql_user,$mysql_pass);
mysql_select_db($mysql_db,$mysql);

// Which filters need updating?
$q="SELECT * FROM filters WHERE pushable='true'";
$r=mysql_query($q,$mysql);

while ($row=mysql_fetch_row($r)){
	$q2="SELECT * FROM users WHERE id='".$row[1]."'";
	$rr=mysql_query($q2,$mysql);
	
	if ($ro=mysql_fetch_row($rr)){
		if ($ro[5]!=''){
			$filters[]=array("id"=>$row[0],"name"=>$row[2],"sites"=>$row[3],"keywords"=>$row[4],"lastUpdate"=>$row[5],"lastPushed"=>$row[7],"deviceKey"=>$ro[5]);
		}
	}
}

foreach ($filters as $filter){
	$query="SELECT COUNT(*) FROM feed ";
	$tmpInd=false;
	$sites=$filter['sites'];
	$keywords=$filter['keywords'];
	if ($sites!="0"){
		$sites=explode("|",$sites);
		if (count($sites)>0){
			$tmp=false;
			foreach ($sites as $site){
				if (strlen($site)>0){
					if (!$tmpInd){
						$query.="WHERE (";
						$tmpInd=true;
					}else if (!$tmp){
						$query.="AND (";
					}

					$query.=$tmp?" OR ":"";
					$query.="site=".mysql_real_escape_string($site)."";
					$tmp=true;
				}
			}

			if ($tmp){
				$query.=") ";
			}
		}
	}

			
	if ($keywords!="0"){
		$keywords=explode("|",$keywords);
		if (count($keywords)>0){
			$tmp=false;
			foreach ($keywords as $key){
				if (strlen($key)>0){
					if (!$tmpInd){
						$query.="WHERE ";
						$query.="MATCH(title, description) AGAINST('";
						$tmpInd=true;
					}else if (!$tmp){
						$query.="AND MATCH(title, description) AGAINST('";
					}
					$query.=$tmp?" ":"";
					$query.="+".mysql_real_escape_string($key);
					$tmp=true;
				}
			}
			if ($tmp){
				$query.="' IN BOOLEAN MODE) ";
			}
		}
	}

	$query.="AND date>'".$filter['lastPushed']."'";
	$count=mysql_query($query,$mysql);

	$total=mysql_fetch_row($count);
	$total=$total[0];
	
	if ($total>0){
		if (!isset($streamContext)){
			// Open our connection to APNS
			$streamContext=stream_context_create();
			stream_context_set_option($streamContext,'ssl','local_cert',$apnsCert);

			$apns=stream_socket_client('ssl://'.$apnsHost.':'.$apnsPost,$error,$errorString,2,STREAM_CLIENT_CONNECT,$streamContext);
		}
		
		// Send the payload
		$payload['aps']=array('alert'=>"Your filter, ".$filter['name'].", had a new deal posted!","sound"=>"dealPush.aiff");
		$payload=json_encode($payload);
		//echo $payload."<br>";
		$message=chr(0).chr(0).chr(32).pack('H*',str_replace(' ','',$filter['deviceKey'])).chr(0).chr(strlen($payload)).$payload;
		fwrite($apns,$message);
		
		//unset($payload['aps']);
		unset($payload);
		
		// Update our database
		$sqlStat="UPDATE filters SET lastPushed='".time()."' WHERE id='".$filter['id']."'";
		mysql_query($sqlStat,$mysql);
	}
}

// Close everything =)
mysql_close($mysql);
socket_close($apns);
fclose($apns);
?>
