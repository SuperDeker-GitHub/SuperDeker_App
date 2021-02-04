<?php
  
 //Ejemplo de como se llama desde el web este restfull con un POST y el cuerpo es userid, pwd y newpwd
 //cuerpo es asi {"userid":"usuario","pwd":"clave", "newpwd":"nuevaclave"}
 //https://www.tuapoyo.net/Dossier2/api/cambioclave.php
 
// get the HTTP method, path and body of the request


function intchars($value){
		$Val = utf8_decode($value);
		$Val = iconv('UTF-8', 'ISO-8859-1',$Val);
		return $Val;
}

$method = $_SERVER['REQUEST_METHOD'];
//$request = explode('/', trim($_SERVER['PATH_INFO'],'/'));
$jsonPayload = file_get_contents('php://input');

//echo json_encode($jsonPayload);
//		exit;

$jsonPayload = utf8_encode($jsonPayload);
$input = json_decode($jsonPayload);
switch(json_last_error()) {
        case JSON_ERROR_NONE:
            //echo ' - Sin errores';
        break;
        case JSON_ERROR_DEPTH:
            echo ' - Excedido tamaño máximo de la pila';
        break;
        case JSON_ERROR_STATE_MISMATCH:
            echo ' - Desbordamiento de buffer o los modos no coinciden';
        break;
        case JSON_ERROR_CTRL_CHAR:
            echo ' - Encontrado carácter de control no esperado';
        break;
        case JSON_ERROR_SYNTAX:
            echo ' - Error de sintaxis, JSON mal formado';
        break;
        case JSON_ERROR_UTF8:
            echo ' - Caracteres UTF-8 malformados, posiblemente codificados de forma incorrecta';
        break;
        default:
            echo ' - Error desconocido';
        break;
    }


$token=filter_var($input->token,FILTER_VALIDATE_INT);
$userid = filter_var($input->userid,FILTER_SANITIZE_STRING);
$password = filter_var($input->pwd,FILTER_SANITIZE_STRING);
$newpassword = filter_var($input->newpwd,FILTER_SANITIZE_STRING);
$IPRA = $_SERVER['REMOTE_ADDR'];
$IPXFF = $_SERVER['HTTP_X_FORWARDED_FOR'];
$IPCLI = $_SERVER['HTTP_CLIENT_IP'];

$token['type'] = 'token';
$token['usuario']=$userid;

include 'dbconex.php';

$connectionInfo = array( "UID"=>$uid,                            
                         "PWD"=>$pwd,                            
                         "Database"=>$databaseName); 
  
/* Connect using SQL Server Authentication. */  
$link = sqlsrv_connect( $serverName, $connectionInfo);  
 
 header('Cache-Control: no-cache, must-revalidate');
	header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
	// headers to tell that result is JSON
	header('Content-type: application/json');
 
 if (!link){
	$errMsg='';
	if( ($errors = sqlsrv_errors() ) != null) {
		foreach( $errors as $error ) {
			$errMsg= "SQLSTATE: ".$error[ 'SQLSTATE']."\n";
			$errMsg .= "code: ".$error[ 'code']."\n";
			$errMsg.= "message: ".$error[ 'message']."\n";
		}
	}
	$token['type'] = 'error';
	$token['msg'] = "No se pudo conectar Error: ".$errMsg;
	echo json_encode($token);
	sqlsrv_free_stmt( $stmt);
	exit;
 }
 
// create SQL based on HTTP method
switch ($method) {
  case 'GET':
    $sql = "";break;//"insert `$table` where id=$key"; break;
  case 'POST':		
		//$hashedPWD = password_hash($password, PASSWORD_DEFAULT);
		//$userid
		$sql='select pwd from DossierCreds where userid=?';
		$param = array($userid);
		//echo json_encode($sql);
		//exit;
		$stmt = sqlsrv_query( $link, $sql,$param);
		if( $stmt === false) {
			$errMsg='';
			if( ($errors = sqlsrv_errors() ) != null) {
				foreach( $errors as $error ) {
					$errMsg= "SQLSTATE: ".$error[ 'SQLSTATE']."\n";
					$errMsg .= "code: ".$error[ 'code']."\n";
					$errMsg.= "message: ".$error[ 'message']."\n";
				}
			}
			$token['type'] = 'error';
			$token['msg'] = "No se pudo verificar Credenciales Error: ".$errMsg;
			echo json_encode($token);
			sqlsrv_free_stmt( $stmt);
			sqlsrv_close($link);
			exit;
		}
		sqlsrv_fetch($stmt);
		$hashedPWD = sqlsrv_get_field($stmt, 0);		
		if (password_verify($password, $hashedPWD)) {
			$pwd = filter_var($newpassword,FILTER_SANITIZE_STRING);
			$pwd=password_hash($pwd, PASSWORD_DEFAULT);
			
			$USql ="update DossierCreds set pwd = ? where userid=?";			
			$paramsU = array($pwd, $userid);
			$UStmt = sqlsrv_query($link,$USql,$paramsU);
			if( $UStmt === false) {
				$errMsg='';
				if( ($errors = sqlsrv_errors() ) != null) {
					foreach( $errors as $error ) {
						$errMsg= "SQLSTATE: ".$error[ 'SQLSTATE']."\n";
						$errMsg .= "code: ".$error[ 'code']."\n";
						$errMsg.= "message: ".$error[ 'message']."\n";
					}
				}
				$token['type'] = 'error';
				$token['msg'] = "No se pudo Obtener el perfil del usuario: ".$errMsg;
				echo json_encode($token);
				sqlsrv_free_stmt($stmt);
				sqlsrv_close($link);
				exit;
			}			
			$token['type'] = 'token';
			$token['usuario']=$userid;
			
            $jsonEncodedReturnArray = json_encode($token, JSON_PRETTY_PRINT);
            echo $jsonEncodedReturnArray;
			sqlsrv_free_stmt( $UStmt);
			sqlsrv_free_stmt( $stmt);
			sqlsrv_close($link);
			exit;
		}
		else {
			$token['type'] = 'error';
			$token['msg'] = "No autorizado";
			echo json_encode($token);
			sqlsrv_free_stmt( $stmt);
			sqlsrv_close($link);
			exit;
		}
	break;//"insert 
} 

// close mysql connection
sqlsrv_close($link);
?>