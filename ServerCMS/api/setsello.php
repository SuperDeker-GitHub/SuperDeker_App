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
 
function CheckIfTotalsGo($formula,$TipoDC){
	return (strpos($formula,$TipoDC.".")!=false);
}
function GetTotalTuples($repciID,$formula,$link){
	$ArrTotales=[];
	$Formula = trim($formula);
	$posOpen = strpos($Formula,"(");
	$Funcion =substr($Formula,0,$posOpen);
	$Componentes = substr($Formula,$posOpen+1);
	$Componentes = substr($Componentes,0,strlen($Componentes)-1);
	$DCField = strtok($Componentes, ",");
	$offset = 0;
	$ArregloDcField=[];
	while ($DCField !== false){
		$DCField=trim($DCField);
		if (substr($DCField,0,1)=='-'){
			$signo = '-';
			$DCField=substr($DCField,1);
		}
		else{
			$signo = '';
		}
		$posPunto = strpos($DCField,".");
		$DC = substr($DCField,0,$posPunto);
		$Field = substr($DCField,$posPunto+1);
		$dcF = new DCField();
		$dcF->DC=$DC; 
		$dcF->Field=$Field;
		$dcF->Signo=$signo;
		
		$ArregloDcField[] =$dcF;
				
		$DCField = strtok(",");
		$offset = $offset +1;
	}
	$SqlTot = ArmaSQL($Funcion,$ArregloDcField,$repciID);
	$resTot = sqlsrv_query($link,$SqlTot);
	if (!$resTot) {
		return ([]);
		//echo json_encode('No totals');
		//exit;
	}
	if (!sqlsrv_has_rows($resTot)){
		return ([]);
		//echo json_encode('No result in totals');
		//exit;
	}
	else {
		$DCtype = '';
		$Cantidad = 0;
		$Tuplas = '';
		while( sqlsrv_fetch( $resTot )) {
			$DCtype=sqlsrv_get_field($resTot, 0);
			$Cantidad=sqlsrv_get_field($resTot, 1);
			$TotObj = new TotalesDCs();
			
			$TotObj->DCType = $DCtype;
			$TotObj->Cantidad = $Cantidad;
			$ArrTotales[] = $TotObj;
			
		}
		sqlsrv_free_stmt($resTot);	
	}
	return($ArrTotales);
}


class DCField
{
    public $DC;
    public $Field;
	public $Signo;
}

class TotalesDCs
{
    public $DCType;
    public $Cantidad;
}

function ArmaSQL($Operando,$Parametros,$rex){
	switch($Operando) {
		case 'Sum':
		$SqlRet ="select DCType, sum(convert(numeric(18,2),value2)) as value2 from (";
		for ($xx=0;$xx<count($Parametros);$xx++){
			if ($xx!=0)
				$SqlRet =$SqlRet." UNION ALL ";
			$SqlRet =$SqlRet."select DCType,";
			if ($Parametros[$xx]->Signo=='-')
				$SqlRet =$SqlRet."'-'+";
			$SqlRet =$SqlRet." value2";
			$SqlRet =$SqlRet." from repciDcTuplas, repciDcs " ;
			$SqlRet =$SqlRet." where repciDcs.id = idDC and repciDcs.repciid=".$rex;
			$SqlRet =$SqlRet." and DCType = '".$Parametros[$xx]->DC."' and value1='".$Parametros[$xx]->Field."' and repciDcs.status = 0 ";		
		}
		$SqlRet =$SqlRet." ) as RES group by DCType";		
		break;
	}
	return $SqlRet;
}

function AddTotales($rex,$Tuples,$commlink,$NombreDCTotal,$NombreretHeadTotal){
	if (count($Tuples)==0){
		return true;
	}
	$sqlInsertTotales = "INSERT INTO repciDCs (repciId, fromUser, when_date,DCType,longitud,latitud, status,filepath,PrevDC,IP,ServerTime,LocationOrigin,comment) VALUES (?, ?, ?, ?, ?, ?, ?, ?,?,?,GetDate(),?,?); SELECT SCOPE_IDENTITY() as last_ins_id";
	$paramsTotal = array( $rex, intchars($user),$when_date, $NombreDCTotal, $longitud,$latitud,0,'',0,$IP,$GPSOrg,$comment);
	$stmtTotal = sqlsrv_query( $commlink, $sqlInsertTotales, $paramsTotal);
	$last_Tots =0;
	if($stmtTotal){		
		$last_Tots =lastId($stmtTotal);
		$granTotal=0;
		foreach ($Tuples as $tup){
			$V1=$tup->DCType;				
			$V2=number_format($tup->Cantidad,2,'.',',');
			$granTotal=$granTotal+$tup->Cantidad;
			$V3="";$V4="";$V5="";
			$sqTotalTuples = "INSERT INTO repciDCTuplas (idDC, value1, value2, value3, value4, value5)
					  VALUES (?, ?, ?, ?, ?, ?)";
			$paramsTotsTuples = array( $last_Tots, $V1, $V2, $V3, $V4, $V5);
			$stmtTupTots = sqlsrv_query( $commlink, $sqTotalTuples, $paramsTotsTuples);
			if (!$stmtTupTots)
				break;
		}	
		if (!$stmtTupTots){ 
			sqlsrv_rollback( $commlink );
			//getout(-1);
			echo "Transaccion revertida no se pudieron grabar las tuplas de Totales";
			//http_response_code(404);
			die(sqlsrv_errors());
			exit;
		}
		else{
			$V1=$NombreretHeadTotal;
			$V2=number_format($granTotal,2,'.',',');
			$V3="";$V4="";$V5="";
			$sqTotalTuples = "INSERT INTO repciDCTuplas (idDC, value1, value2, value3, value4, value5)
					  VALUES (?, ?, ?, ?, ?, ?)";		
			$V3="";
			$V4="";
			$V5="";
			$paramsTotsTuples = array( $last_Tots, $V1, $V2, $V3, $V4, $V5);
			$stmtTupTots = sqlsrv_query( $commlink, $sqTotalTuples, $paramsTotsTuples);
		}
		if (!$stmtTupTots){
			sqlsrv_rollback( $commlink );
			//getout(-1);
			echo "Transaccion revertida no se pudo grabar el gran Total";
			//http_response_code(404);
			die(sqlsrv_errors());
			exit;
		}
		$sqlUpdate ="update repciDcs set comment = ? where id=?";	
		$paramsUpdate = array($V2,$last_Tots);
		$stmtUpdates = sqlsrv_query( $commlink, $sqlUpdate, $paramsUpdate);
		
		return ($stmtTupTots);
	}
	else{
		sqlsrv_rollback( $commlink );
		//getout(-1);
		echo "Transaccion revertida no se pudo grabar encabezado de Totales";
		//http_response_code(404);
		die(sqlsrv_errors());
		exit;
	}
} 

function callAPI($method, $url, $data){
	$curl = curl_init();
	switch ($method){
		case "POST":
			curl_setopt($curl, CURLOPT_POST, 1);
			if ($data)
				curl_setopt($curl, CURLOPT_POSTFIELDS, $data);
			break;
		case "PUT":
			curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "PUT");
			if ($data)
				curl_setopt($curl, CURLOPT_POSTFIELDS, $data);			 					
			break;
		default:
			if ($data)
				$url = sprintf("%s?%s", $url, http_build_query($data));
	}
	// OPTIONS:
	curl_setopt($curl, CURLOPT_URL, $url);
	curl_setopt($curl, CURLOPT_HTTPHEADER, array(
	//'APIKEY: 111111111111111111111',
	'Content-Type: application/json',
	));
	curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($curl, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
	// EXECUTE:
	$result = curl_exec($curl);
	if(!$result){die("Connection Failure");}
	curl_close($curl);
	return $result;
}

 include 'prepost.php';
 
 
// get the HTTP method, path and body of the request
$method = $_SERVER['REQUEST_METHOD'];

$jsonPayload = file_get_contents('php://input');

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
$dcid = filter_var($input->dcid,FILTER_VALIDATE_INT);
$dctype = filter_var($input->dctype,FILTER_SANITIZE_STRING);
$when_date = filter_var($input->when_date,FILTER_SANITIZE_STRING);
$longitud = filter_var($input->longitud,FILTER_VALIDATE_FLOAT);
$longitud = $longitud + 0.0;
$latitud = filter_var($input->latitud,FILTER_VALIDATE_FLOAT);
$latitud = $latitud + 0.0;
$fromUser = filter_var($input->fromUser,FILTER_SANITIZE_STRING);
$newStatus = filter_var($input->newStatus,FILTER_VALIDATE_INT);
$ip = $_SERVER['REMOTE_ADDR'];
$LocationOrigin =filter_var($input->LocationOrigin,FILTER_SANITIZE_STRING);
$SelloComment = intchars(filter_var($input->SelloComment,FILTER_SANITIZE_STRING));
$SelloImage = filter_var($input->SelloImage,FILTER_SANITIZE_STRING);

if (!$rexid || !$dcid || !$newStatus || !$token || !$fromUser || !$when_date ){
	http_response_code(501);
	exit(501);
}
//to check if after setting the stamp, there are extra actions to do
$rexidCheckActions=$rexid;
$dctypeCheckActions=$dctype;
$newStatusCheckActions=$newStatus;

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
	echo "No se pudo conectar Error: ".$errMsg;
	die(sqlsrv_errors());
	exit;
 }
 
 
$input=SelloPrecheck($input,$link);
 
// create SQL based on HTTP method
switch ($method) {
  case 'POST':
		if ( sqlsrv_begin_transaction( $link ) === false ) {
		 die( print_r( sqlsrv_errors(), true ));
		 exit;
		}
		$sql1 = "INSERT INTO repciDCs (repciId, fromUser, when_date,DCType,longitud,latitud, status,filepath,PrevDC,IP,ServerTime,LocationOrigin,comment,SelloImage)
				  Select repciId, ? as fromUser, ? as when_date,DCType,? as longitud,? as latitud,? as status,filepath,? as PrevDC,? as IP,GetDate() as ServerTime,? as LocationOrigin,? as comment, ? as SelloImage from repciDcs where id = ? ; SELECT SCOPE_IDENTITY() as last_ins_id";
		$params1 = array( intchars($fromUser),$when_date, $longitud,$latitud,$newStatus,$dcid,$ip,$LocationOrigin,$SelloComment,$SelloImage,$dcid);
		$stmt1 = sqlsrv_query( $link, $sql1, $params1);
		$last_id =0;
		if($stmt1){
			$last_id =lastId($stmt1);
			$sql2 = "UPDATE repciDCs SET status=(status * -1)-1,NextDC=? where id=?";
			$params2 = array($last_id,$dcid);
			$stmt2 = sqlsrv_query( $link, $sql2, $params2);
			if (!$stmt2){
				sqlsrv_rollback( $link );
				echo "Transaccion revertida en actualizacion con DC ".$dcid;
				//http_response_code(404);
				die(sqlsrv_errors());
				exit;				
			}
			
			$sql3 = "INSERT INTO repciDcTuplas (idDC, value1, value2, value3, value4, value5)
			         SELECT ? as idDC, value1, value2, value3, value4, value5 from repciDcTuplas where idDC = ?";
			$params3 = array($last_id,$dcid);
			
			
			$stmt3 = sqlsrv_query( $link, $sql3, $params3);
			if ($stmt3){
				if ($newStatus<0){ // si el sello hace que el status del dc sea menor que cero, es posible que se necesite recalcular
					//averiguar el grupo del por el rexid, leer la estructura de grupo, verificar en la formula si hay un calculo asociado al dctype del dc y si es asi recalcular los totales
					$GetGroupSQL="select grupo,dctype,repcis.repciid,repcidcs.id from repcis,repcidcs where repcis.repciid = repcidcs.repciid and repcidcs.id=?";
					$paramsgroup = array($dcid); 
					$stmtgroup = sqlsrv_query( $link, $GetGroupSQL, $paramsgroup);
					if ($stmtgroup){
						//sqlsrv_next_result($stmtgroup);
						sqlsrv_fetch($stmtgroup);
						$gr=sqlsrv_get_field($stmtgroup, 0);
						$dctype=sqlsrv_get_field($stmtgroup, 1);
						$rid = sqlsrv_get_field($stmtgroup, 2);
						$JsonFile="../grupos/".$gr.".json";					
						$strJsonFileContents = file_get_contents($JsonFile);
						$JsonGrupo=json_decode($strJsonFileContents, true);
						$formula=$JsonGrupo['Totales'][0]['Calc'];
						$NombreDCTotales = $JsonGrupo['Totales'][0]['DC'];
						$retHeadTotal = $JsonGrupo['Totales'][0]['rethead'];
						if(CheckIfTotalsGo($formula,$dctype)!=false){
							$TotTuples = GetTotalTuples($rexid,$formula,$link);
							//change status of the actual TotalDC and add the new one
							$ChangeStatusTotalSQL = "update repciDcs set status = -1 where DCType ='".$NombreDCTotales."' and status = 0 and repciId = ?" ;
							$paramChange = array($rexid);
							$ChangeStmt = sqlsrv_query( $link, $ChangeStatusTotalSQL, $paramChange);
							$OperTotales = AddTotales($rexid,$TotTuples,$link,$NombreDCTotales,$retHeadTotal);
						}
					}
					else{
						sqlsrv_rollback( $link );
						//getout(-1);
						echo "Transaccion revertida no se pudo leer el grupo del Dossier donde se corrige la copia";
						//http_response_code(404);
						die(sqlsrv_errors());
						exit;
					}
					//verificar si este que acabas de borrar tiene copias, deber anular dichas copias y recalcular sus totales
					//SE ASUME QUE SOLO HAY UNA COPIA POR DC (QUIZAS EN UNA VERSION FUTURA SE PUEDAN TENER VARIAS)
					$GetGroupSQL="select grupo,dctype,repcis.repciid,repcidcs.id from repcis,repcidcs where repcis.repciid = repcidcs.repciid and repcidcs.originalDC=?";
					$paramsgroup = array($dcid);
					$stmtgroup = sqlsrv_query( $link, $GetGroupSQL, $paramsgroup);
					if ($stmtgroup){
						//sqlsrv_next_result($stmtgroup);
						sqlsrv_fetch($stmtgroup);
						$gr=sqlsrv_get_field($stmtgroup, 0);
						$dctype=sqlsrv_get_field($stmtgroup, 1);
						$rid = sqlsrv_get_field($stmtgroup, 2);
						$idDC = sqlsrv_get_field($stmtgroup, 3);
						$sql4 = "UPDATE repciDCs SET status=-1 where id=?";
						$params4 = array($idDC);
						$stmt4 = sqlsrv_query( $link, $sql4, $params4);
						if (!$stmt4){
							sqlsrv_rollback( $link );
							echo "Transaccion revertida en actualizacion con DC de copia ".$dcid;
							//http_response_code(404);
							die(sqlsrv_errors());
							exit;				
						}
						
						$JsonFile="../grupos/".$gr.".json";					
						$strJsonFileContents = file_get_contents($JsonFile);
						$JsonGrupo=json_decode($strJsonFileContents, true);
						$formula=$JsonGrupo['Totales'][0]['Calc'];
						$NombreDCTotales = $JsonGrupo['Totales'][0]['DC'];
						$retHeadTotal = $JsonGrupo['Totales'][0]['rethead'];
						if(CheckIfTotalsGo($formula,$dctype)!=false){
							$TotTuples = GetTotalTuples($rid,$formula,$link);
							//change status of the actual TotalDC and add the new one
							$ChangeStatusTotalSQL = "update repciDcs set status = -1 where DCType ='".$NombreDCTotales."' and status = 0 and repciId = ?" ;
							$paramChange = array($rid);
							$ChangeStmt = sqlsrv_query( $link, $ChangeStatusTotalSQL, $paramChange);
							$OperTotales = AddTotales($rid,$TotTuples,$link,$NombreDCTotales,$retHeadTotal);
						}
					}
					else{
						sqlsrv_rollback( $link );
						//getout(-1);
						echo "Transaccion revertida no se pudo leer el grupo del Dossier donde se corrige la copia";
						//http_response_code(404);
						die(sqlsrv_errors());
						exit;
					}
				}
				sqlsrv_commit( $link );
				// check if ther are actions to do on this setting
				if ($dctypeCheckActions="Approval" && $newStatusCheckActions = "1") { // Aproved so do actions
					$statusBody=[];
					$get_data = callAPI('GET', 'https://dossierplus-srv.com/superdeker/api/SDApproval.php/'.$rexidCheckActions, json_encode($statusBody));
					$response = json_decode($get_data, true);
					$errors = $response['response']['errors'];
					$data = $response['response']['data'][0];

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
				echo "No se pudo registrar Error: ".$errMsg."\n";//.serialize($params1)."\n".$jsonPayload;
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
			echo "No se pudo registrar Error: ".$errMsg."\n";//.serialize($params1)."\n".$jsonPayload;
			//http_response_code(404);
			die(sqlsrv_errors());
			exit;
		}
		$retval=[];
		$retval['rexid']=$rexid;
		$retval['old']=$dcid;
		$retval['new']= $last_id;
		
		break;
  case 'PUT':
    $sql = "";break;//"update `$table` set $set where id=$key"; break;
  case 'POST':      
    $sql = "";break;//"insert `$table` where id=$key"; break;
  case 'DELETE':
    $sql = "";break;//"delete `$table` where id=$key"; break;
} 
 
if ($method == 'POST') {
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
sqlsrv_free_stmt($stmt3); 
sqlsrv_close($link);

?>