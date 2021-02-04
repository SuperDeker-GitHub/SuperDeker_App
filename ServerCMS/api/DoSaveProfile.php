<?php

function lastId($queryID) {
    sqlsrv_next_result($queryID);
    sqlsrv_fetch($queryID);
    return sqlsrv_get_field($queryID, 0);
}

function intchars($value){
		$Val = utf8_decode($value);
		$Val = iconv('UTF-8', 'ISO-8859-1',$Val);
		return $Val;
}

$method = $_SERVER['REQUEST_METHOD'];
$request = explode('/', trim($_SERVER['PATH_INFO'],'/'));
$nick = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$country = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$state = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$city = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$zipcode = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$gender = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$stickhand = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$playerlevel = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$distance = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$feets = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$inches = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$weight = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$lbs = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$stickbrand = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$stickprodline = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$gloves = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$glovesprodline = filter_var(array_shift($request), FILTER_SANITIZE_STRING);



if ($nick==''){
	header('Cache-Control: no-cache, must-revalidate');
    header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
    // headers to tell that result is JSON
    header('Content-type: application/json');
    echo '{"id":0,"err":"Empty Nick"}';
	exit;
}
include 'dbconex.php';
$connectionInfo = array( "UID"=>$uid,                            
                         "PWD"=>$pwd,                            
                         "Database"=>$databaseName);  
/* Connect using SQL Server Authentication. */  

$link = sqlsrv_connect( $serverName, $connectionInfo);  
// create SQL based on HTTP method
	header('Cache-Control: no-cache, must-revalidate');
	header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
	// headers to tell that result is JSON
	header('Content-type: application/json');

switch ($method) {
  case 'GET':      
    $sqlInsert = "INSERT INTO SDProfiles (nickname, country,state,city,zipcode,gender,stickhand,playerlevel,distance,feets,inches,weight,lbs,stickbrand,stick,glovebrand,glove)  VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?); SELECT SCOPE_IDENTITY() as last_ins_id";
	$params = array($nick,$country,$state,$city,$zipcode,$gender,$stickhand,$playerlevel,$distance,$feets,$inches,$weight,$lbs,$stickbrand,$stickprodline,$gloves,$glovesprodline);
    $stmt = sqlsrv_query( $link, $sqlInsert, $params);
    $last_id = 0;
    if($stmt){
        $last_id =lastId($stmt);
        echo '{"id":'.$last_id.',"err":"no"}';
    }
    else{
        echo '{"id":0,"err":"Cannot register profile"}';
	}    
    break;
  default:
		echo '{"id":0,"err":"Only Get"}';
	break;
}

sqlsrv_free_stmt($stmt); 
sqlsrv_close($link);
 	
?>
