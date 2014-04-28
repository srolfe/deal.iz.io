<?php
// Items for inclusion:
// Graphs - Graph the past 24 hours for:
// - Users
// - Filters created
// - Overall usage

$action=isset($_GET['act'])?$_GET['act']:"def";

switch ($action){
	case "def":{
		// This is the main screen... We're not doing anything here yet...
	}break;
	case "updateGraphs":{
		// All graph updating will be done here...
	}break;
}