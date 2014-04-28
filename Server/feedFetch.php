<?php
// Deal Fetcher v2
// > This script runs every 5 minutes, collecting the freshest deals from everywhere.
// > Grabs our feeds from MySQL and delegates them to the appropriate class.
// -- Created By Steve Rolfe --

//require "./includes/config.php";

date_default_timezone_set("UTC");

$mysql_username="dealizio";
$mysql_password="eN66srafW7P7AQ2x";
$mysql_host="localhost";
$mysql_db="dealizio";

$db=mysql_connect($mysql_host,$mysql_username,$mysql_password);
mysql_select_db($mysql_db,$db);

$query="SELECT * FROM rss_configuration";
$res=mysql_query($query,$db);

while ($row=mysql_fetch_row($res)){
	$feeds[]=$row;

	$xml=simplexml_load_file($row[2],'SimpleXMLElement',LIBXML_NOCDATA);

	// We've got a feed. Bitch.
	switch ($row[0]){
		case 1:{
			// Deals.woot Parser
			foreach ($xml->channel->item as $it){
				// We've gots an items
				$site=1;
				$site_id=mysql_real_escape_string((String)$it->guid);
				$title=mysql_real_escape_string((String)$it->title);
				$description=mysql_real_escape_string((String)$it->description);
				$link=mysql_real_escape_string((String)$it->link);
				$th=$it->thumbnail->attributes();
				$thumbnail=mysql_real_escape_string($th['url']);
				$date=strToTime((String)$it->pubDate);

				// Deals.Woot wants to be 6 hours ahead. Let's fix 'em
				//$d=new DateTime();
				//$d->setTimestamp($date);
				//$d->modify("-6 hours");
				//$date=$d->getTimestamp();
				// Contacting Deals.woot fixed this issue. It's been disabled.

				$rr=mysql_query("SELECT * FROM feed WHERE site='".$site."' AND site_id='".$site_id."'",$db);
				if (!$r=mysql_fetch_row($rr)){
					$query=sprintf("INSERT INTO feed VALUES('','%s','%s','%s','%s','%s','%s','%s')",$site,$site_id,$title,$description,$link,$thumbnail,$date);
					mysql_query($query,$db);
				}
			}
		}break;

		case 2:{
			// DealNews Parser
			foreach ($xml->channel->item as $it){
				// We've gots an items
				$site=2;
				$site_id=mysql_real_escape_string((String)$it->guid); //GUID IS LINK! NEEDS PARSE
				$title=mysql_real_escape_string((String)$it->title);
				$description=mysql_real_escape_string(strip_tags((String)$it->description));
				$link=mysql_real_escape_string((String)$it->guid);
				$date=strToTime((String)$it->pubDate." -0500");

				$doc=new DOMDocument();
				$doc->loadHTML($it->description);
				$tParse=simplexml_import_dom($doc);
				$im=$tParse->xpath('//img');
				$thumbnail=mysql_real_escape_string($im[0]['src']);

				$rr=mysql_query("SELECT * FROM feed WHERE site='".$site."' AND site_id='".$site_id."'",$db);
				if (!$r=mysql_fetch_row($rr)){
					$query=sprintf("INSERT INTO feed VALUES('','%s','%s','%s','%s','%s','%s','%s')",$site,$site_id,$title,$description,$link,$thumbnail,$date);
					mysql_query($query,$db);
				}
			}
		}break;

		case 3:{
			// FatWallet Parser
			foreach ($xml->channel->item as $it){
				$site=3;
				$title=mysql_real_escape_string((String)$it->title);
				$site_id=mysql_real_escape_string((String)$it->guid);
				$description=mysql_real_escape_string(strip_tags((String)$it->description));
				$link=mysql_real_escape_string((String)$it->guid);
				$date=strToTime((String)$it->pubDate);

				$rr=mysql_query("SELECT * FROM feed WHERE site='".$site."' AND site_id='".$site_id."'",$db);
				if (!$r=mysql_fetch_row($rr)){
					// I have to parse a FUCKING HTML DOC to get the thumbnail. ARE THEY SERIOUS?!
					// I REFUSE to parse this if I don't need it. So, let's make sure first.
					$doc=new DOMDocument();
					$doc->loadHTMLFile($link);
					$tParse=simplexml_import_dom($doc);
					$im=$tParse->xpath('//div//a/img');
					$thumbnail="";
					foreach ($im as $imm){
						$src=(String)$imm['src'];
						if (strpos($src,"/attachments/thumbnails/")>0){
							$thumbnail="http://www.fatwallet.com".$src;
						}
					}

					$query=sprintf("INSERT INTO feed VALUES('','%s','%s','%s','%s','%s','%s','%s')",$site,$site_id,$title,$description,$link,$thumbnail,$date);
					mysql_query($query,$db);
				}
			}
		}break;

		case 4:{
			// Dealspl.us Parser
			foreach ($xml->channel->item as $it){
				$site=4;
				$link2=$it->xpath('.//feedburner:origLink');
				$site_id=mysql_real_escape_string((String)$it->link); // No guid. We'll just use the link
				$title=mysql_real_escape_string((String)$it->title);
				$description="See site for more information";
				$link=mysql_real_escape_string((String)$link2[0]);
				$date=strToTime((String)$it->pubDate);

				$doc=new DOMDocument();
				$doc->loadHTML($it->description);
				$tParse=simplexml_import_dom($doc);
				$im=$tParse->xpath('//img');
				$thumbnail=mysql_real_escape_string($im[0]['src']);

				$rr=mysql_query("SELECT * FROM feed WHERE site='".$site."' AND site_id='".$site_id."'",$db);
				if (!$r=mysql_fetch_row($rr)){
					$query=sprintf("INSERT INTO feed VALUES('','%s','%s','%s','%s','%s','%s','%s')",$site,$site_id,$title,$description,$link,$thumbnail,$date);
					mysql_query($query,$db);
				}
			}
		}break;

		case 5:{
			// TechBargains
			foreach ($xml->channel->item as $it){
				$site=5;
				$site_id=mysql_real_escape_string((String)$it->guid);
				$title=mysql_real_escape_string((String)$it->title);
				$description="See site for more information";
				$link=mysql_real_escape_string((String)$it->link);
				$thumbnail=mysql_real_escape_string((String)$it->imageLink);
				$date=strToTime((String)$it->pubDate);

				$rr=mysql_query("SELECT * FROM feed WHERE site='".$site."' AND site_id='".$site_id."'",$db);
				if (!$r=mysql_fetch_row($rr)){
					$query=sprintf("INSERT INTO feed VALUES('','%s','%s','%s','%s','%s','%s','%s')",$site,$site_id,$title,$description,$link,$thumbnail,$date);
					mysql_query($query,$db);
				}
			}
		}break;

		case 6:{
			// SlickDeals
			foreach ($xml->channel->item as $it){
				$site=6;
				$site_id=mysql_real_escape_string((String)$it->guid);
				$title=mysql_real_escape_string((String)$it->title);
				$items=$it->xpath(".//content:encoded");
				$description=mysql_real_escape_string(strip_tags((String)$items[0]));
				$link=mysql_real_escape_string((String)$it->guid);
				$thumbnail="";
				$date=strToTime((String)$it->pubDate);


				$rr=mysql_query("SELECT * FROM feed WHERE site='".$site."' AND site_id='".$site_id."'",$db);
				if (!$r=mysql_fetch_row($rr)){
					$query=sprintf("INSERT INTO feed VALUES('','%s','%s','%s','%s','%s','%s','%s')",$site,$site_id,$title,$description,$link,$thumbnail,$date);
					mysql_query($query,$db);
				}
			}
		}break;	
	}
}

mysql_close($db);
?>