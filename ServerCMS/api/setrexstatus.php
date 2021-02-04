<?php
 
 //Ejemplo de como se llama desde el web este restfull
 //https://www.tuapoyo.net/dossier2/setsello.php/RexId/DCid/valor/SecToken
 
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
 
 
// get the HTTP method, path and body of the request
$method = $_SERVER['REQUEST_METHOD'];

$jsonPayload = file_get_contents('php://input');

//echo json_encode($jsonPayload);
//exit;

$jsonPayload = utf8_encode($jsonPayload);
$input = json_decode($jsonPayload);

header('Cache-Control: no-cache, must-revalidate');
header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
header('Content-type: application/json');



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


$request = explode('/', trim($_SERVER['PATH_INFO'],'/'));
$token = filter_var(array_shift($request), FILTER_SANITIZE_STRING);

$input = (array)$input;
$input["token"]=$token;
$input = (object)$input;


$rexid = filter_var($input->rexid,FILTER_VALIDATE_INT);
$newStatus = filter_var($input->newStatus,FILTER_VALIDATE_INT);
$when_date = filter_var($input->when_date,FILTER_SANITIZE_STRING);
$longitud = filter_var($input->longitud,FILTER_VALIDATE_FLOAT);
//$longitud = $longitud + 0.0;
$latitud = filter_var($input->latitud,FILTER_VALIDATE_FLOAT);
//$latitud = $latitud + 0.0;
$fromUser = filter_var($input->fromUser,FILTER_SANITIZE_STRING);
$ip = $_SERVER['REMOTE_ADDR'];
$LocationOrigin =filter_var($input->LocationOrigin,FILTER_SANITIZE_STRING);


$DCWebId = 0;
$DCType ='Cambio_Estado';
$filepath = ''; // or image.jpg
$notift = '0';
$comment = 'A nuevo estado:'.$newStatus;

if (!$rexid || !$token || !$fromUser || !$when_date ){
	http_response_code(501);
	exit(501);
}
include 'prepost.php';

include 'dbconex.php';

$connectionInfo = array( "UID"=>$uid,                            
                         "PWD"=>$pwd,                            
                         "Database"=>$databaseName);
  
/* Connect using SQL Server Authentication. */  
$link = sqlsrv_connect( $serverName, $connectionInfo);
 
// create SQL based on HTTP method
$retval=[];
switch ($method) {
  case 'POST':
		if ( sqlsrv_begin_transaction( $link ) === false ) {
		 die( print_r( sqlsrv_errors(), true ));
		 exit;
		}
		$input=CambioStatusPrecheck($input,$link);
		
		$sql1 = "update repcis set status = ? where repciId=?";
		$params1 = array( $newStatus,$rexid);
		$stmt1 = sqlsrv_query( $link, $sql1, $params1);
		if($stmt1){
			$retval['rexid']=$rexid;
			$sql2 = "INSERT INTO repciDCs (repciId, fromUser, when_date,DCType,longitud,latitud, status,filepath,PrevDC,IP,ServerTime,LocationOrigin,comment)  VALUES (?, ?, ?, ?, ?, ?, ?, ?,?,?,GetDate(),?,?)";
 		    $params2 = array( $rexid, intchars($fromUser),$when_date, intchars($DCType), $longitud,$latitud,0,$filepath,$DCWebId,$ip,$LocationOrigin,$comment);
			//echo json_encode($params2);
			//exit;
			$stmt2 = sqlsrv_query( $link, $sql2, $params2);
			if($stmt2){
				sqlsrv_commit( $link );
				header('Cache-Control: no-cache, must-revalidate');
				header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
				// headers to tell that result is JSON
				header('Content-type: application/json');
				//$metaData = sqlsrv_field_metadata($result);
				echo json_encode($retval);
				sqlsrv_free_stmt($stmt1); 
				sqlsrv_free_stmt($stmt2); 
				sqlsrv_close($link);
				exit;
			}
			else{
				$errMsg=''; 
				if( ($errors = sqlsrv_errors() ) != null) {
					foreach( $errors as $error ) {
						$errMsg= "SQLSTATE: ".$error[ 'SQLSTATE']."\n";
						$errMsg .= "code: ".$error[ 'code']."\n";
						$errMsg.= "message: ".$error[ 'message']."\n";
					}
				}
				sqlsrv_rollback( $link );
				echo "No se pudo registrar El cambio de estado: ".$errMsg."\n";//.serialize($params1)."\n".$jsonPayload;
				//http_response_code(404);
				die(sqlsrv_errors());
				exit;
			}		
		}
		else{
			$errMsg=''; 
			if( ($errors = sqlsrv_errors() ) != null) {
				foreach( $errors as $error ) {
					$errMsg= "SQLSTATE: ".$error[ 'SQLSTATE']."\n";
					$errMsg .= "code: ".$error[ 'code']."\n";
					$errMsg.= "message: ".$error[ 'message']."\n";
				}
			}
			sqlsrv_rollback( $link );
			echo "No se pudo registrar el cambio de estado: ".$errMsg."\n";//.serialize($params1)."\n".$jsonPayload;
			//http_response_code(404);
			die(sqlsrv_errors());
			exit;
		}
		break;
  case 'PUT':
    $sql = "";break;//"update `$table` set $set where id=$key"; break;
  case 'GET':      
    $sql = "";break;//"insert `$table` where id=$key"; break;
  case 'DELETE':
    $sql = "";break;//"delete `$table` where id=$key"; break;
} 
 
if ($method == 'POST') {
	sqlsrv_commit( $link );
	header('Cache-Control: no-cache, must-revalidate');
	header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
	// headers to tell that result is JSON
	header('Content-type: application/json');
	//$metaData = sqlsrv_field_metadata($result);
	echo json_encode($retval);
} 

// close mysql connection

sqlsrv_free_stmt($stmt1); 
sqlsrv_free_stmt($stmt2); 
sqlsrv_close($link);

?>