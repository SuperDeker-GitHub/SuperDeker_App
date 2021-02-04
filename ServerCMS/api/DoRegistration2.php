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
$email = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$pass = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$dob = filter_var(array_shift($request), FILTER_SANITIZE_STRING);

//echo 'Nick is :'.$nick.'<br>';
//echo 'email es :'.$email.'<br>';
//echo 'pwd es :'.$pass.'<br>';
//echo 'dob es :'.$dob.'<br>';
if ($email==''){
	header('Cache-Control: no-cache, must-revalidate');
    header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
    // headers to tell that result is JSON
    header('Content-type: application/json');
    echo '{"email":"","used":false}';
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
    $sqlInsert = "INSERT INTO SDCreds (authby, created,dob,email,pass,userid,verified)  VALUES ('SD', GetDate(), ?, ?, ?, ?, 0); SELECT SCOPE_IDENTITY() as last_ins_id";
	$params = array($dob, $email, $pass, intchars($nick));
	$stmt = sqlsrv_query( $link, $sqlInsert, $params);
    $last_id = 0;
    if($stmt){
        $last_id =lastId($stmt);
        echo '{"id":'.$last_id.',"err":"no"}';
    }
    else{
        echo '{"id":0,"err":"Cannot register user"}';
	}    
    break;
  default:
		echo json_encode([]);
	break;
}

sqlsrv_free_stmt($stmt); 
sqlsrv_close($link);
 	
?>
