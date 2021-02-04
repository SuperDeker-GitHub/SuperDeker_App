<?php

$method = $_SERVER['REQUEST_METHOD'];
$request = explode('/', trim($_SERVER['PATH_INFO'],'/'));
$hash = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
//$dctype = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
//$sello = filter_var(array_shift($request), FILTER_SANITIZE_STRING);


if ($hash==''){
	header('Cache-Control: no-cache, must-revalidate');
    header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
    // headers to tell that result is JSON
    header('Content-type: txt');
    echo 'There was a problem with your verification, please try again';
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
	header('Content-type: txt');

switch ($method) {
  case 'GET':
		$sql = "update SDCreds set verified = 1 where hash='".$hash."'"; 
		//echo $sql;
    break;
  default:
  echo 'There was a problem with your verification, please try again';
		exit;
	break;
}
// excecute SQL statement
$result =  sqlsrv_query($link,$sql);
 
// die if SQL statement failed

if (!$result){
    //echo "No result";
    echo 'Not able to verify your email';
    //exit;
}
else{
        echo 'Thank you for verifying your email. Please continue with your profile information.';
}

sqlsrv_free_stmt($result); 
sqlsrv_close($link);
 	
?>
