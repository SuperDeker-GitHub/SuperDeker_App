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
$pass = filter_var(array_shift($request), FILTER_SANITIZE_STRING);

$IPRA = $_SERVER['REMOTE_ADDR'];
$IPXFF = $_SERVER['HTTP_X_FORWARDED_FOR'];
$IPCLI = $_SERVER['HTTP_CLIENT_IP'];

//echo 'Nick is :'.$nick.'<br>';
//echo 'pwd es :'.$pass.'<br>';


if ($nick==''){
	header('Cache-Control: no-cache, must-revalidate');
    header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
    // headers to tell that result is JSON
    header('Content-type: application/json');
    $token['tipo'] = 'error';
    $token['usuario']=$nick;
    $token['ipra']='';
    $token['ipxff']='';
    $token['ipcli']='';
    $token['jwt']='';
    
    $token['err']="No nick";
    echo json_encode($token);
	exit;
}


if ($pass==''){
	header('Cache-Control: no-cache, must-revalidate');
    header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
    // headers to tell that result is JSON
    header('Content-type: application/json');
    $token['tipo'] = 'error';
    $token['usuario']=$nick;
    $token['ipra']='';
    $token['ipxff']='';
    $token['ipcli']='';
    $token['jwt']='';
    
    $token['err']="No pass";
    echo json_encode($token);
	exit;
}

include 'dbconex.php';
$connectionInfo = array( "UID"=>$uid,                            
                         "PWD"=>$pwd,                            
                         "Database"=>$databaseName);  
/* Connect using SQL Server Authentication. */  
$link = sqlsrv_connect( $serverName, $connectionInfo);  

if (!Slink){
	$errMsg='';
	if( ($errors = sqlsrv_errors() ) != null) {
		foreach( $errors as $error ) {
			$errMsg= "SQLSTATE: ".$error[ 'SQLSTATE']."\n";
			$errMsg .= "code: ".$error[ 'code']."\n";
			$errMsg.= "message: ".$error[ 'message']."\n";
		}
	}
	$token['tipo'] = 'error';
    $token['usuario']=$nick;
    $token['ipra']='';
    $token['ipxff']='';
    $token['ipcli']='';
    $token['jwt']='';
    
    $token['err']="No se pudo conectar Error: ".$errMsg;
    echo json_encode($token);
	sqlsrv_free_stmt( $stmt);
	exit;
 }

// create SQL based on HTTP method
	header('Cache-Control: no-cache, must-revalidate');
	header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
	// headers to tell that result is JSON
	header('Content-type: application/json');

switch ($method) {
  case 'GET':      
    $hash = md5( rand(0,1000) );  
    $sql='select pass,verified from SDCreds where userid=?';
	$params = array($nick);
	//echo $sql;
   $stmt = sqlsrv_query( $link, $sql, $params);
    
   if($stmt){
        if( $stmt === false) {
			$errMsg='';
			if( ($errors = sqlsrv_errors() ) != null) {
				foreach( $errors as $error ) {
					$errMsg= "SQLSTATE: ".$error[ 'SQLSTATE']."\n";
					$errMsg .= "code: ".$error[ 'code']."\n";
					$errMsg.= "message: ".$error[ 'message']."\n";
				}
			}
            $token['tipo'] = 'error';
            $token['usuario']=$nick;
            $token['ipra']='';
            $token['ipxff']='';
            $token['ipcli']='';
            $token['jwt']='';
			$token['err'] = "Could not verify credentials: ".$errMsg;
			echo json_encode($token);
			sqlsrv_free_stmt( $stmt);
			exit;
		}
        sqlsrv_fetch($stmt);
        
        $hashedPWD = sqlsrv_get_field($stmt, 0);
        $verified = sqlsrv_get_field($stmt, 1);

        if ($pass == $hashedPWD) {
        //if (password_verify($password, $hashedPWD)) {
            if ($verified == 1){
			
                $token['tipo'] = 'token';
                $token['usuario']=$nick;
                $token['ipra']=$IPRA;
                $token['ipxff']=$IPXFF;
                $token['ipcli']="";
                require_once('jwt.php');
                $serverKey = '$2y$10$gWvhpQsmumkw2JsgA1Rui.Es3l.5pHr7V5HWUhdv9mTwB5RFzayeC';
                
                $jwttoken = JWT::encode($token, $serverKey);
                $token['jwt']=$jwttoken;
                
                $token['err']="";
                
                $jsonEncodedReturnArray = json_encode($token, JSON_PRETTY_PRINT);
                echo $jsonEncodedReturnArray;
                sqlsrv_free_stmt( $ProfileStmt);
                sqlsrv_free_stmt( $stmt);
                exit;
            }
            else{ // todavia no esta verificado el email
                $token['tipo'] = 'error';
                $token['usuario']=$nick;
                $token['ipra']=$IPRA;
                $token['ipxff']=$IPXFF;
                $token['ipcli']="";
                $token['jwt']='';
                
                $token['err']="email not verified yet";
                
                $jsonEncodedReturnArray = json_encode($token, JSON_PRETTY_PRINT);
                echo $jsonEncodedReturnArray;
                sqlsrv_free_stmt( $ProfileStmt);
                sqlsrv_free_stmt( $stmt);
                exit;
            }
		}
		else {
            $token['tipo'] = 'error';
            $token['usuario']=$nick;
            $token['ipra']='';
            $token['ipxff']='';
            $token['ipcli']='';
            $token['jwt']='';
			$token['err'] = "Not autorized";
			echo json_encode($token);
			sqlsrv_free_stmt( $stmt);
			exit;
		}
  
    } 
    else{
        echo "There was a problem";
    }
   
    break;
  default:
		echo json_encode([]);
	break;
}

sqlsrv_free_stmt($stmt); 
sqlsrv_close($link);
 	
?>
