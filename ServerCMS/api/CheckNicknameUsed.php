<?php

$method = $_SERVER['REQUEST_METHOD'];
$request = explode('/', trim($_SERVER['PATH_INFO'],'/'));
$nick = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
//$dctype = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
//$sello = filter_var(array_shift($request), FILTER_SANITIZE_STRING);

//echo 'Nick is :'.$nick.'<br>';
//echo 'DCType es :'.$dctype.'<br>';
//echo 'Sello es :'.$sello.'<br>';

if ($nick==''){
	header('Cache-Control: no-cache, must-revalidate');
    header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
    // headers to tell that result is JSON
    header('Content-type: application/json');
    echo '{"nicksaved":"","used":false}';
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
		$sql = "select userid from SDCreds where userid='".$nick."'"; 
		//echo $sql;
    break;
  default:
		echo json_encode([]);
		exit;
	break;
}
// excecute SQL statement
$result =  sqlsrv_query($link,$sql);
 
// die if SQL statement failed

if (!$result){
    //echo "No result";
    echo '{"nicksaved":"","used":false}';
    //exit;
}
else{
    if (!sqlsrv_has_rows($result)){
        //echo "No rows" ;
        echo '{"nicksaved":"","used":false}';
        //exit;
    }
    else {
        if ( sqlsrv_fetch( $result )) {
        //echo "should return something";
        $nicksaved = mb_convert_encoding(sqlsrv_get_field($result, 0), "UTF-8", "HTML-ENTITIES");	   
        echo '{"nicksaved":"'.$nicksaved.'","used":true}';
        }
    }		
}

sqlsrv_free_stmt($result); 
sqlsrv_close($link);
 	
?>
