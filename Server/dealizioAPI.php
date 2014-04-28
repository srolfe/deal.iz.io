<?php
// deal.iz.io/feed/api.php
//
// +-----------------------+
// | deal.iz.io Server API |
// +-----------------------+
// deal.iz.io/api/api.php?udid=1&req=feed
//

$mysql_user='dealizio';
$mysql_pass='eN66srafW7P7AQ2x';
$mysql_db='dealizio';

$article_limit=20;


header("Content-Type: application/xml; charset=ISO-8859-1"); 
$xmlhead=<<<'XML'
<?xml version="1.0" encoding="ISO-8859-1" ?> 
<rss version="2.0"> 
<channel>
XML;

$xmlfoot=<<<'XML'

</channel>
</rss>
XML;

$xmlmid="";

$mysql=mysql_connect('localhost',$mysql_user,$mysql_pass);
mysql_select_db($mysql_db,$mysql);

function trimAll($input,$val) {
    $input = trim($input);
    $output="";
    for($i=0;$i<strlen($input);$i++) {
        if(substr($input, $i, 1) != " ") {
            $output .= trim(substr($input, $i, 1),$val);
        } else {
            $output .= " ";
        }
    }
    return $output;
}

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
	
	global $mysql;
	global $user;
	
	$ad=mysql_real_escape_string(json_encode($ad));
	
	$q="INSERT INTO capizio VALUES('',".$user['id'].",".$type.",'".$ad."','".time()."')";
	mysql_query($q,$mysql) or die(mysql_error());
}

// Let's do some UDID checking…
if (isset($_GET['udid'])){
	// We've got a UDID
	$query="SELECT * FROM users WHERE udid='".mysql_real_escape_string($_GET['udid'])."'";
	$r=mysql_query($query,$mysql);

	if ($rr=mysql_fetch_row($r)){
		// Cool! Let's save their info…
		$user=array('id'=>$rr[0],'udid'=>$_GET['udid'],'filters'=>$rr[2],'favorites'=>$rr[3]);
	}else{
		// No user. Add them…
		// Added <DeviceKey>
		$query="INSERT INTO users VALUES('','".mysql_real_escape_string($_GET['udid'])."','','','','')";
		mysql_query($query,$mysql);

		$query="SELECT * FROM users WHERE udid='".mysql_real_escape_string($_GET['udid'])."'";
		$r=mysql_query($query,$mysql);

		if ($rr=mysql_fetch_row($r)){
			$user=array('id'=>$rr[0],'udid'=>$_GET['udid'],'filters'=>$rr[2],'favorites'=>$rr[3]);
			
			date_default_timezone_set('UTC');
			
			mail("steve@iz.io, josh@iz.io", "User #".$user['id']." created","Figured I'd inform you that user #".$user['id']." created their account!\n\nIP Address: ".$_SERVER['REMOTE_ADDR']."\nTime: ".date('l jS \of F Y h:i:s A',time()-(60*60*6))." CST");
		}
	}
}

switch ($_GET['req']){
	case 'feed':{
		$query="SELECT * FROM feed ";

		$tmpInd=false;
		// Fetch ONLY our favorites
		if (isset($_GET['fav']) && $user['favorites']!=""){
			$t=false;
			$favs=explode(",",$user['favorites']);
			foreach ($favs as $fav){
				$query.=$t?" OR ":"WHERE (";
				$query.="id='".$fav."'";
				$t=true;
				$tmpInd=true;
			}

			$query.=") ";
		}

		if (isset($_GET['fav']) && $user['favorites']==""){
			$xmlmid.=<<<XML

		<error>No favorites</error>
XML;
			die($xmlhead.$xmlmid.$xmlfoot);
		}
			
		
		// FILTERS?!
		$filters=isset($_GET['filtered'])?$_GET['filtered']:0;
		
		if (!$filters){
			// No filters
			$data=array(
				'page'=>(isset($_GET['p'])?$_GET['p']:0),
				'fav'=>(isset($_GET['fav'])?$_GET['fav']:-1)
				);
				
			reportAnalytic(0,$data);
			unset($data);
		}else{
			$data=array(
				'sites'=>(isset($_GET['sites'])?$_GET['sites']:-1),
				'keys'=>(isset($_GET['keys'])?$_GET['keys']:-1),
				'filter'=>(isset($_GET['filterId'])?$_GET['filterId']:-1),
				'page'=>(isset($_GET['p'])?$_GET['p']:0),
				'fav'=>(isset($_GET['fav'])?$_GET['fav']:-1)
				);
				
			reportAnalytic(1,$data);
			unset($data);
		}

		if ($filters){
			if (isset($_GET['filterId'])){
				$q="SELECT * FROM filters WHERE id='".mysql_real_escape_string($_GET['filterId'])."'";
				$r=mysql_query($q,$mysql);

				if ($rr=mysql_fetch_row($r)){
					$_GET['sites']=$rr[3];
					$_GET['keys']=$_GET['keys'].$rr[4];

					$q="UPDATE filters SET last_updated='".time()."' WHERE id='".mysql_real_escape_string($_GET['filterId'])."'";
					mysql_query($q,$mysql);
				}
			}

			// Sites first
			$sites=isset($_GET['sites'])?$_GET['sites']:"0";
			$keywords=isset($_GET['keys'])?$_GET['keys']:"0";

			if ($sites!="0"){
			$sites=explode("|",$sites);
			
			if (count($sites)>0){
				//$query.="WHERE ";
				// Ok. Filter some sites. GOT IT
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
			// Boolean keywords
			if (count($keywords)>0){
				// This is an AMAZINGLY ballin' feature
				//$query.="WHERE ";
				//if (isset($_GET['adv'])){
				// SELECT * FROM feed WHERE MATCH(title) AGAINST ('xbox') OR MATCH(title) AGAINST ('icing') ORDER BY date DESC
				//if ($_GET['adv']=="A"){
				// Simple AND indicator
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
									
		}

		// We need to ensure we filter out disabled sites - I really hate you for forcing this inclusion Josh!
		if (!isset($_GET['sites'])){
			$q="SELECT disabled_sites FROM users WHERE udid='".mysql_real_escape_string($_GET['udid'])."'";
			$r=mysql_query($q,$mysql);

			if ($rr=mysql_fetch_row($r)){
				$disabledSites=explode(",",$rr[0]);
			}

			$tmp=false;
			foreach ($disabledSites as $dSite){
				if (strlen($dSite)>0){
					if (!$tmpInd){
						$query.="WHERE (";
						$tmpInd=true;
					}else if (!$tmp){
						$query.="AND (";
					}

					$query.=$tmp?" AND ":"";
					$query.="site!='".$dSite."'";
					$tmp=true;
				}
			}

			if ($tmp){
				$query.=") ";
			}
		}

		$query.="ORDER BY date DESC";
		$p=isset($_GET['p'])?$_GET['p']:0;
		$query.=" LIMIT ".($p*$article_limit).",".$article_limit;

		//die($query);

		$res=mysql_query($query,$mysql) or die(mysql_error());

		while ($row=mysql_fetch_row($res)){
			$row[0]=utf8_decode(trimAll($row[0],"&\t\n\r\0\x0B"));
			$row[1]=utf8_decode(trimAll($row[1],"&\t\n\r\0\x0B"));
			$row[2]=utf8_decode(trimAll($row[2],"&\t\n\r\0\x0B"));
			$row[3]=utf8_decode(trimAll($row[3],"&\t\n\r\0\x0B"));
			$row[4]=utf8_decode(trimAll(nl2br($row[4]),"&\t\n\r\0\x0B"));
			$row[5]=utf8_decode(trimAll($row[5],"&\t\n\r\0\x0B"));
			$row[6]=utf8_decode(trimAll($row[6],"&\t\n\r\0\x0B"));
			$row[7]=utf8_decode(trimAll($row[7],"&\t\n\r\0\x0B"));

			// We need to fix FatWallet deals
			$row[4]=str_replace("?","'",$row[4]);
			$row[3]=str_replace("?","'",$row[3]);

			// FatWallet crap remover
			if ($row[1]==3){
				$row[4]=preg_replace("/(Rating)(:)(\\s+)(\\d+)(\\s+)(Posted)(\\s+)(By)(:)(\\s+)((?:[a-z][a-z]*[0-9]+[a-z0-9]*))(\\s+)(Views)(:)(\\s+)(\\d+)(\\s+)(Replies)(:)(\\s+)(\\d+)(\\s+)/is","",$row[4]);
			}

			// Price finder - Fuck you Josh
			if (preg_match("/(\\$[0-9]+(?:\\.[0-9][0-9])?)(?![\\d])/is",$row[3],$matches)>0){
				// Well… We've got a price lol
				if (is_array($matches)){
					$dollars=$matches[0];
				}else{
					$dollars=$matches;
				}
			}else{
				// Well… No price… Let's nab a percent?
				if (preg_match("/(\\d+)(%)/is",$row[3],$matches)>0){
					if (is_array($matches)){
						$dollars=$matches[0];
					}else{
						$dollars=$matches;
					}
				}else{
					// ANY FREE IN THERE?!
					if (stripos($row[3],"free")!==FALSE){
						$dollars="free";
					}else{
						// Lol nothing…
						$dollars="";
					}
				}
			}

			$favs=explode(",",$user['favorites']);
			$final="false";
			foreach ($favs as $fav){
				if ($fav==$row[0]){
					$final="true";
				}
			}

			// Link fix! We're modifying each link to get the mobilized version of the site…
			switch ($row[1]){
				case 3:{
					// FatWallet mod
					$parts=explode("/",$row[5]);
					$bit=$parts[count($parts)-1];
					//$row[5]="http://m.fatwallet.com/forums/hot-deals/".$bit."/";
					$row[5]="<![CDATA[http://m.fatwallet.com/forums/topic.php?catid=18&threadid=".$bit."]]>";
				}break;
				case 4:{
					// Deals Plus
					$row[5]=str_replace("http://","http://m.",$row[5]);
				}break;
				case 5:{
					// Fuck you techbargains…
					// http://www.techbargains.com/news_displayItem.cfm/238811
					$row[5]=str_replace("http://www.","http://m.",$row[2]);
				}break;
			}

			$row[4]=htmlspecialchars($row[4]);

			$xmlmid.=<<<XML

	<item>
		<guid>$row[0]</guid>
		<siteid>$row[1]</siteid>
		<siteguid>$row[2]</siteguid>
		<favorite>$final</favorite>
		<title>$row[3]</title>
		<price>$dollars</price>
		<description>$row[4]</description>
		<link>$row[5]</link>
		<thumbnail>$row[6]</thumbnail>
		<pubDate>$row[7]</pubDate>
	</item>
XML;
		}

	}break;

	case "saveFav":{
		if (isset($_GET['fav'])){
			$_GET['fav']=trim($_GET['fav']," \t\n\r\0\x0B");
			
			
			$data=array(
				'fav'=>$_GET['fav']
				);
				
			reportAnalytic(2,$data);
			unset($data);
			
			// Ok, let's update the favorites column!*/
			$query="SELECT favorites FROM users WHERE udid='".mysql_real_escape_string($_GET['udid'])."'";
			$res=mysql_query($query,$mysql);

			if ($r=mysql_fetch_row($res)){
				if ($r[0]=="" || $r[0]==NULL){
					$query="UPDATE users SET favorites='".mysql_real_escape_string($_GET['fav'])."' WHERE udid='".mysql_real_escape_string($_GET['udid'])."'";
					mysql_query($query,$mysql);
				}else{
					$query="UPDATE users SET favorites='".$r[0].",".mysql_real_escape_string($_GET['fav'])."' WHERE udid='".mysql_real_escape_string($_GET['udid'])."'";
					mysql_query($query,$mysql);
				}
			}
		}
	}break;

	case "removeFav":{
		if (isset($_GET['fav'])){
			// Ok, let's update the favorites column!*/
			$query="SELECT favorites FROM users WHERE udid='".mysql_real_escape_string($_GET['udid'])."'";
			$res=mysql_query($query,$mysql);
			
			$_GET['fav']=trimAll($_GET['fav'],"&\t\n\r\0\x0B");
			
			$data=array(
				'fav'=>$_GET['fav']
				);
				
			reportAnalytic(3,$data);
			unset($data);
			
			if ($r=mysql_fetch_row($res)){
				if ($r[0]=="" || $r[0]==NULL){
				}else{
					$favs=explode(",",$r[0]);
					$final="";
					foreach ($favs as $fav){
						if ($fav!=$_GET['fav']){
							$final.=($final==""?"":",").$fav;
						}
					}

					$query="UPDATE users SET favorites='".$final."' WHERE udid='".mysql_real_escape_string($_GET['udid'])."'";
					mysql_query($query,$mysql);
				}
			}
		}
	}break;

	case "siteFetch":{
		$q="SELECT disabled_sites FROM users WHERE udid='".mysql_real_escape_string($_GET['udid'])."'";
		$r=mysql_query($q,$mysql);

		if ($rr=mysql_fetch_row($r)){
			$disabledSites=explode(",",$rr[0]);
		}

		$query="SELECT * FROM rss_configuration";
		$res=mysql_query($query,$mysql);

		while ($row=mysql_fetch_row($res)){
			$enabled="true";
			foreach ($disabledSites as $dSite){
				if ($dSite==$row[0]){
					$enabled="false";
				}
			}

			$xmlmid.=<<<XML

	<item>
		<siteid>$row[0]</siteid>
		<title>$row[1]</title>
		<thumbnail>$row[3]</thumbnail>
		<description>$enabled</description>
	</item>
XML;
		}
	}break;

	case "disableSite":{
		
		$data=array(
			'sites'=>$_GET['siteId']
			);
			
		reportAnalytic(4,$data);
		unset($data);
		
		
		$q="SELECT disabled_sites FROM users WHERE udid='".mysql_real_escape_string($_GET['udid'])."'";
		$r=mysql_query($q,$mysql);

		if ($rr=mysql_fetch_row($r)){
			$disabledSites=explode(",",$rr[0]);
		}

		$tmp=false;
		foreach ($disabledSites as $dSite){
			if (strlen($dSite)>0){
				if ($dSite==$_GET['siteId']){
					$tmp=true;
				}
			}
		}

		if (!$tmp){
			$disabledSites[]=mysql_real_escape_string($_GET['siteId']);
			$ds=implode(",",$disabledSites);

			$q="UPDATE users SET disabled_sites='".$ds."' WHERE udid='".mysql_real_escape_string($_GET['udid'])."'";
			mysql_query($q,$mysql);
		}
	}break;

	case "enableSite":{
		$data=array(
			'sites'=>$_GET['siteId']
			);
			
		reportAnalytic(5,$data);
		unset($data);
		
		$q="SELECT disabled_sites FROM users WHERE udid='".mysql_real_escape_string($_GET['udid'])."'";
		$r=mysql_query($q,$mysql);

		if ($rr=mysql_fetch_row($r)){
			$disabledSites=explode(",",$rr[0]);
		}

		$tmp="";
		foreach ($disabledSites as $dSite){
			if (strlen($dSite)>0){
				if ($dSite!=$_GET['siteId']){
					$tmp.=($tmp==""?$dSite:",".$dSite);
				}
			}

		}

		$q="UPDATE users SET disabled_sites='".$tmp."' WHERE udid='".mysql_real_escape_string($_GET['udid'])."'";

		//die($q);
		mysql_query($q,$mysql);
	}break;

	case "saveFilter":{
		$pushed=isset($_GET['push'])?'true':'false';
		
		$data=array(
			'sites'=>(isset($_GET['sites'])?$_GET['sites']:-1),
			'keys'=>(isset($_GET['keywords'])?$_GET['keywords']:-1),
			'name'=>(isset($_GET['name'])?$_GET['name']:-1),
			'pushed'=>$pushed
			);
			
		reportAnalytic(6,$data);
		unset($data);
		
		$q="INSERT INTO filters VALUES('','".$user['id']."','".mysql_real_escape_string($_GET['name'])."','".mysql_real_escape_string($_GET['sites'])."','".mysql_real_escape_string($_GET['keywords'])."','0','".mysql_real_escape_string($pushed)."','".time()."')";
		mysql_query($q,$mysql);
	}break;
	
	case "editFilter":{
		$pushed=isset($_GET['push'])?'true':'false';
		
		$data=array(
			'sites'=>(isset($_GET['sites'])?$_GET['sites']:-1),
			'keys'=>(isset($_GET['keywords'])?$_GET['keywords']:-1),
			'filter'=>(isset($_GET['filterId'])?$_GET['filterId']:-1),
			'name'=>(isset($_GET['name'])?$_GET['name']:-1),
			'pushed'=>$pushed
			);
			
		reportAnalytic(7,$data);
		unset($data);
		
		$q="UPDATE filters SET name='".mysql_real_escape_string($_GET['name'])."', sites='".mysql_real_escape_string($_GET['sites'])."', keywords='".mysql_real_escape_string($_GET['keywords'])."', pushable='".mysql_real_escape_string($pushed)."' WHERE id='".mysql_real_escape_string($_GET['filterId'])."'";
		mysql_query($q,$mysql);
	}break;

	case "removeFilter":{
		$data=array(
			'filter'=>(isset($_GET['filterId'])?$_GET['filterId']:-1)
			);
			
		reportAnalytic(8,$data);
		unset($data);
		
		$sql="DELETE FROM filters WHERE id='".mysql_real_escape_string($_GET['filterId'])."'";
		mysql_query($sql,$mysql);
	}break;

	case "filterFetch":{
		// Grabs feeds and grabs deals matching filters since last visit
		$q="SELECT * FROM filters WHERE userId='".$user['id']."'";
		$r=mysql_query($q,$mysql);

		while ($row=mysql_fetch_row($r)){
			$filters[]=array("id"=>$row[0],"name"=>$row[2],"sites"=>$row[3],"keywords"=>$row[4],"lastUpdate"=>$row[5]);
		}

		foreach ($filters as $filter){
			$query="SELECT COUNT(*) FROM feed ";
			$tmpInd=false;
			$sites=$filter['sites'];
			$keywords=$filter['keywords'];
			if ($sites!="0"){
			$sites=explode("|",$sites);
			if (count($sites)>0){
				//$query.="WHERE ";
				// Ok. Filter some sites. GOT IT
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
			// Boolean keywords
			if (count($keywords)>0){
				// Simple AND indicator
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


			$cc=mysql_query($query,$mysql);
			$total2=mysql_fetch_row($cc);

			$query.="AND date>'".$filter['lastUpdate']."'";
			$count=mysql_query($query,$mysql);

			$total=mysql_fetch_row($count);

			//$filters[]=array("id"=>$row[0],"name"=>$row[2],"sites"=>$row[3],"keywords"=>$row[4],"lastUpdate"=>$row[5]);
			$si=$filter['sites'];
			$id=$filter['id'];
			$nm=$filter['name'];
			$ky=$filter['keywords'];

			$xmlmid.=<<<XML

	<item>
		<siteid>$si</siteid>
		<guid>$id</guid>
		<title>$nm</title>
		<description>$ky</description>
		<pubDate>$total[0]/$total2[0]</pubDate>
	</item>
XML;
		}
	}break;
	
	case "addPushToken":{
		
		$data=array();
			
		reportAnalytic(9,$data);
		unset($data);
		
		// Add our push-notification token. This allows us to start push notifying users ^_^.
		$q="UPDATE users SET deviceKey='".mysql_real_escape_string($_GET['token'])."' WHERE udid='".mysql_real_escape_string($_GET['udid'])."'";
		$r=mysql_query($q,$mysql);
	}break;

			
}

if (isset($_GET['json'])){
	echo = json_encode(new SimpleXMLElement($xml->asXML(), LIBXML_NOCDATA));
}
echo $xmlhead;
echo $xmlmid;
echo $xmlfoot;
mysql_close($mysql);
?>