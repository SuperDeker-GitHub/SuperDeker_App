<?php
  
 //Ejemplo de como se llama desde el web este restfull
 //https://www.tuapoyo.net/Dossier2/api/saveDC.php
 
// get the HTTP method, path and body of the request

//Esta version es la V.125
//Agrega la grabacion de totales, tanto cuando se modifica el dataclip, si el rex de copia tiene calculo o el rex del cual se ha quitado una copia de un DC cuando se corrige un spin con source
 
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
function getout($value){
	header('Cache-Control: no-cache, must-revalidate');
	header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
	// headers to tell that result is JSON
	header('Content-type: application/json');
	echo json_encode($value);
}

function GetDossierStatus($conn,$rex){
	// VERIFICAR SI ESTAN CERRADAS, BORRADAS, NO DISPONIBLES U OK
	if (strlen($rex)!=0){
		$sqlSt = "select status from repcis where repciId = ".$rex;
		//$paramSql = array($rex);
		$Stmt = sqlsrv_query( $conn, $sqlSt);//, $paramSql);
		if ($Stmt==false){
			echo "No se pudo verificar status de Dossier a Copiar dc--: ".$rex."\n";
			if( ($errors = sqlsrv_errors() ) != null) {
					foreach( $errors as $error ) {
						echo "SQLSTATE: ".$error[ 'SQLSTATE']."<br />";
						echo "code: ".$error[ 'code']."<br />";
						echo "message: ".$error[ 'message']."<br />";
					}
				}
			sqlsrv_rollback( $conn );
			getout(-4);
			
			//http_response_code(404);
			die(sqlsrv_errors());
			exit;
		}
		if (sqlsrv_fetch($Stmt)==true){
			//sqlsrv_fetch($Stmt);
			$Status = sqlsrv_get_field($Stmt, 0);
			if ($Status==1){
				$retval='OK';
			}
			else{
				if ($Status==0){
					$retval='Deleted';
				}
				else{
					if ($Status==2){
						$retval='Closed';
					}
				}
			}
			return $retval;
		}
		else{
			echo "1-".$rex."\n";
			sqlsrv_rollback( $conn );
			getout(-4);
			
			//http_response_code(404);
			die(sqlsrv_errors());
			exit;
			return 'Not Found';
		}
	}
	else{
		echo "2-".$rex."\n";
		
		sqlsrv_rollback( $conn );
		getout(-4);
		
		die(sqlsrv_errors());
		exit;
		return 'Not Found';
	}
}

function GetDossierStatusByDc($conn,$DcId){
	if (strlen($DcId)!=0){
		$sqlSt = "select repcis.status from repcis,repciDcs where repcis.repciId = repciDcs.repciId and repciDcs.id = ?";
		$paramSql = array($DcId);
		$Stmt = sqlsrv_query( $conn, $sqlSt, $paramSql);
		if (!$Stmt){
			sqlsrv_rollback( $conn );
			getout(-4);
			echo "No se pudo verificar status de Dossier de DC Copiado: ".$errMsg."\n";
			//http_response_code(404);
			die(sqlsrv_errors());
			exit;
		}
		if (sqlsrv_next_result($Stmt)==true){
			sqlsrv_fetch($Stmt);
			$Status = sqlsrv_get_field($Stmt, 0);
			if ($Status==1){
				$retval='OK';
			}
			else{
				if ($Status==0){
					$retval='Deleted';
				}
				else{
					if ($Status==2){
						$retval='Closed';
					}
				}
			}
			return $retval;
		}
		else
			return 'Not Found';
	}
	else
		return 'Not Found';
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

function AddTotales($rex,$Tuples,$commlink,$NombreDCTotal,$NombreretHeadTotal,$Params){
	if (count($Tuples)==0){
		return true;
	}
	$sqlInsertTotales = "INSERT INTO repciDCs (repciId, fromUser, when_date,DCType,longitud,latitud, status,filepath,PrevDC,IP,ServerTime,LocationOrigin,comment) VALUES (?, ?, GetDate(), ?, ?, ?, ?, ?,?,?,GetDate(),?,?); SELECT SCOPE_IDENTITY() as last_ins_id";
	$paramsTotal = array( $rex, intchars($Params['user']), $NombreDCTotal, $Params['longitud'],$Params['latitud'],0,'',0,$Params['IP'],$Params['GPSOrg'],$Params['comment']);
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

include 'prepost.php';

			
$method = $_SERVER['REQUEST_METHOD'];
//$request = explode('/', trim($_SERVER['PATH_INFO'],'/'));
$jsonPayload = file_get_contents('php://input');

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

include 'dbconex.php';	

//"Data Source=tcp:s07.everleap.com;Initial Catalog=DB_4666_tuapoyo;User ID=DB_4666_tuapoyo_user;Password=******;Integrated Security=False;"


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
 


$input=precheck($input,$link);

$token=filter_var($input->token,FILTER_VALIDATE_INT);
$repciID = filter_var($input->head->repciID,FILTER_VALIDATE_INT);
$user = filter_var($input->head->user,FILTER_SANITIZE_STRING);
$DCWebId = filter_var($input->head->DCWebId,FILTER_VALIDATE_INT);
$DCType =filter_var($input->head->DCType,FILTER_SANITIZE_STRING);
$when_date = filter_var($input->head->when_date,FILTER_SANITIZE_STRING);
$longitud = filter_var($input->head->longitud,FILTER_VALIDATE_FLOAT);
$latitud = filter_var($input->head->latitud,FILTER_VALIDATE_FLOAT);
$IP = filter_var($input->head->IP,FILTER_SANITIZE_STRING);
//if ($IP=='')
if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
       $IP = $_SERVER['HTTP_CLIENT_IP'];
} elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
       $IP = $_SERVER['HTTP_X_FORWARDED_FOR'];
} else {
       $IP = $_SERVER['REMOTE_ADDR'];
}	
$GPSOrg = filter_var($input->head->GPSOrg,FILTER_SANITIZE_STRING);
$filepath = filter_var($input->head->filename,FILTER_SANITIZE_STRING); // or image.jpg
$titulo = filter_var($input->head->titulo,FILTER_SANITIZE_STRING);
$grupo = filter_var($input->head->grupo,FILTER_VALIDATE_INT);
$notift = filter_var($input->head->notift,FILTER_VALIDATE_INT);
$CopyRexArray = $input->head->CopyToRexs;// filter_var($input->head->CopyToRexs, FILTER_SANITIZE_STRING);
$comment = filter_var($input->head->Comment,FILTER_SANITIZE_STRING);
$comment = utf8_decode($comment);
$comment = iconv('UTF-8', 'ISO-8859-1',$comment);
$totales = $input->head->Totales;



	$text='';
	$NoVa = false;
	$NoVa= (!$token);// or !$longitud or !$latitud);// or !$repciID
	$NoVa=$NoVa or ($user=='' or $DCType=='' or $when_date=='' or $IP=='' or $GPSOrg=='');
	if (!$NoVa)
		foreach ($input->tuple as $tup){
			if (filter_var($tup->V1,FILTER_SANITIZE_STRING)==''){
				$NoVa=true;
				$text = "V1 is ".$tup->V1."Not Sanitized";
				break;
			}
		}	

/*
	if ($DCWebId!=="" && $method=="POST" )
		$NoVa==true;
	if ($DCWebId=="" && $method=="PUT" )
		$NoVa==true;
*/		
	
		
	if ($NoVa){
		header('Cache-Control: no-cache, must-revalidate');
		header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
		// headers to tell that result is JSON
		header('Content-type: application/json');
		$metaData = sqlsrv_field_metadata($result);
		if (!$token)
			$text.="No token - ";
		if (!repciID)
			$text.="No repciID - ";
		//if (!$longitud)
		//	$text.="No longitud - ";
		//if (!$latitud)
		//	$text.="No latitud - ";
		if ($DCWebId!="" && $method=="POST" )
			$text.="DCId predefinido en creacion, -".$DCWebId."-";
		if ($DCWebId=="" && $method=="PUT" )
			$text.="No DCID para update";	
		echo json_encode('No va'.'-1 '.$text);
		exit;
	}
	 
 
 
 
 
// create SQL based on HTTP method
switch ($method) {
  case 'GET':
    $sql = "";break;//"insert `$table` where id=$key"; break;
  case 'POST':
	  if ( sqlsrv_begin_transaction( $link ) === false ) {
		 getout(-2);
		 die( print_r( sqlsrv_errors(), true ));
		 exit;
		}
		//verificar si ya este registro que estamos por grabar ya está registrado, esto pasa poco frecuente, pero a veces pasa
		$sql0 = "select id from repciDcs where comment=? and fromUser=? and when_date =? and DCType=? and IP=? ";
		$params0 = array($comment, intchars($user),$when_date, intchars($DCType), $IP);
		$stmt0 = sqlsrv_query( $link, $sql0, $params0);
		
		
		if (!$stmt0) {
		  header('Cache-Control: no-cache, must-revalidate');
			header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
			// headers to tell that result is JSON
			header('Content-type: application/json');
			//$metaData = sqlsrv_field_metadata($result);
			echo json_encode('');
			exit;
		}
		if (sqlsrv_has_rows($stmt0)){
			if (sqlsrv_fetch($stmt0)){
				$repciDC_id=sqlsrv_get_field($stmt0, 0);	
				echo json_encode($repciDC_id);// es un duplicado, se retorna el valor previo sin grabar
				sqlsrv_free_stmt($stmt0);
				exit;
			}
		}
		sqlsrv_free_stmt($stmt0);
		

		//Verificar si hay un campo unique y verificar que no se ha creado un dataclip con ese valor de ese Dctype
		if (strlen($DCWebId)==0){ // es nuevo		
			$campounico ='';
			$campovalor='';
			foreach ($input->tuple as $tup){
				if ($tup->unique=='true'){
					$campounico=$tup->V1;
					$campovalor=filter_var($tup->V2,FILTER_SANITIZE_STRING);//$tup->V2;
					break;
				}
			}
			if ($campounico!=''){
				// se considera que si el dataclip tiene un status < 0 quiere decir que esta anulado de alguna forma y si el status del repci es > 0 entonces esta activo o historico
				$sql0 = "select repciDcs.id from repciDcs,repciDCTuplas,repcis where repciDcs.id=repciDcTuplas.idDC and repcis.repciid = repciDcs.repciid and DCType=? and value1=? and value2=? and repciDcs.status >=0 and repcis.status > 0";
				$params0 = array(intchars($DCType), $campounico,$campovalor);
				$stmt0 = sqlsrv_query( $link, $sql0, $params0);
				//echo $sql10;
				//echo json_encode($param0);
				//exit;
					
					
				if (!$stmt0) {
				  header('Cache-Control: no-cache, must-revalidate');
					header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
					// headers to tell that result is JSON
					header('Content-type: application/json');
					//$metaData = sqlsrv_field_metadata($result);
					echo json_encode('');
					exit;
				}
				if (sqlsrv_has_rows($stmt0)){
					echo json_encode('Ya esta registrado un '.$campounico.' con valor '.$campovalor);// es un duplicado, se retorna el valor previo sin grabar
					sqlsrv_free_stmt($stmt0);
					exit;
				}
				sqlsrv_free_stmt($stmt0);
			}
		}
		
		precheck(); // correr dentro de la transaccion cualquier registro o verificacion en la base de datos
		if ($repciID==""){//Se debe crear el Dossier que apadrina el DC que viene si este non existe.
			$sql0 = "insert into repcis (titulo,when_date,longitud,latitud,accuracy,provider,owner,creator,repcitype,NotificationType,status,mod_date, grupo,q_attached,IP,ServerTime,LocationOrigin) 
			VALUES (?, ?, ?, ?, ?, ?, ?, ?,?,?,?,?,?,?,?,GetDate(),?); SELECT SCOPE_IDENTITY() as last_ins_id";
			$titulo=filter_var($titulo,FILTER_SANITIZE_STRING);
			$titulo = utf8_decode($titulo);
			$titulo = iconv('UTF-8', 'ISO-8859-1',$titulo);
			$params0 = array( $titulo, $when_date, $longitud,$latitud,0,'',$user,$user,0,$notift,1,$when_date,$grupo,0,$IP,$GPSOrg);
			$stmt0 = sqlsrv_query( $link, $sql0, $params0);
			$last_id =0;
			if($stmt0)	
				$repciID =lastId($stmt0);
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
				getout(-4);
				echo "No se pudo registrar Rex, Error: ".$errMsg."\n";
				die(sqlsrv_errors());
				exit;
			}
		}
		$sql1 = "INSERT INTO repciDCs (repciId, fromUser, when_date,DCType,longitud,latitud, status,filepath,PrevDC,IP,ServerTime,LocationOrigin,comment)
				  VALUES (?, ?, ?, ?, ?, ?, ?, ?,?,?,GetDate(),?,?); SELECT SCOPE_IDENTITY() as last_ins_id";//, ?, ?); //;//,ip, iporg)
		$params1 = array( $repciID, intchars($user),$when_date, intchars($DCType), $longitud,$latitud,0,$filepath,$DCWebId,$IP,$GPSOrg,$comment);
		$stmt1 = sqlsrv_query( $link, $sql1, $params1);
		$last_id =0;
		if($stmt1){		
			$last_id =lastId($stmt1);
			//if ($last_id !=''){
				$EstatusRobot = '';
				$operadoraRobot = '';
				$numeroRobot = '';
				$cedulaRobot = '';
				foreach ($input->tuple as $tup){
					$V1=filter_var($tup->V1,FILTER_SANITIZE_STRING);
					$V1 = utf8_decode($V1);
					$V1 = iconv('UTF-8', 'ISO-8859-1',$V1);
					
					$V2=filter_var($tup->V2,FILTER_SANITIZE_STRING);
					$V2 = utf8_decode($V2);
					$V2 = iconv('UTF-8', 'ISO-8859-1',$V2);
					
					if ($V1=='EstatusRobot'){
						$EstatusRobot = $V2;
					}
					if ($V1=='OperadoraRobot'){ 
						$operadoraRobot = $V2;
					}
					if ($V1=='CelularRobot'){
						$numeroRobot = $V2;
					}
					if ($V1=='Cedula'){
						$cedulaRobot = $V2;			
					}
					if ($EstatusRobot!='' && $operadoraRobot!='' &&  $numeroRobot!='' && $cedulaRobot!=''){
						$smslink='http://www.sistema.massivamovil.com/webservices/SendSms?usuario=enmas@sagcit.com&clave=5m5.123&telefonos=58'.$operadoraRobot.$numeroRobot.'&texto=Estimado%20portador%20de%20la%20cedula%20'.$cedulaRobot.',%20su%20pasaporte%20esta%20en%20'.$EstatusRobot; 
						$contents = file_get_contents($smslink);					
						$smslink='http://www.tuapoyo.net/Dossier2/api/robot.php/'.$operadoraRobot.'/'.$numeroRobot.'/'.$EstatusRobot.'/'.$cedulaRobot; 
						//echo $smslink;
						$contents = file_get_contents($smslink);  
						//echo $contents;
						//echo '-CONTENTS ARE '.$contents;
						/*$ch = curl_init($smslink);
						curl_exec ($ch);
						curl_close ($ch);*/
						
						//exit;
					}
					$V3="";$V4="";$V5="";
					$sql2 = "INSERT INTO repciDCTuplas (idDC, value1, value2, value3, value4, value5)
							  VALUES (?, ?, ?, ?, ?, ?)";
					try{
						$V3=filter_var($tup->V3,FILTER_SANITIZE_STRING);
						$V3 = utf8_decode($V3);
						$V3 = iconv('UTF-8', 'ISO-8859-1',$V3);

					}
					catch(Exception $e){
						$V3="";
					}
					try{
						$V4=filter_var($tup->V4,FILTER_SANITIZE_STRING);
						$V4 = utf8_decode($V4);
						$V4 = iconv('UTF-8', 'ISO-8859-1',$V4);
					}
					catch(Exception $e){
						$V4="";
					}
					try{
						$V5=filter_var($tup->V5,FILTER_SANITIZE_STRING);
						$V5 = utf8_decode($V5);
						$V5 = iconv('UTF-8', 'ISO-8859-1',$V5);

					}
					catch(Exception $e){
						$V5="";
					}
					$params2 = array( $last_id, $V1, $V2, $V3, $V4, $V5);
					$stmt2 = sqlsrv_query( $link, $sql2, $params2);
					if (!$stmt2)
						break;
				}	
			//}
			if ($stmt2){ // Chequear si es una actualizacion
				if (strlen($DCWebId)!=0){
					$sql3 = "UPDATE repciDCs SET status=?,NextDC=? where id=?";
					$params3 = array( -1,$last_id,$DCWebId);
					$stmt3 = sqlsrv_query( $link, $sql3, $params3);
					if (!$stmt3){
						sqlsrv_rollback( $link );
						getout(-1);
						echo "Transaccion revertida en actualizacion con DC ".$DCWebId;
						//http_response_code(404);
						die(sqlsrv_errors());
						exit;				
					}
				}
				/*if ($filepath!==''){
					$sql4 = "UPDATE repcis SET Images=CONCAT(Images,?) where repciid=? and Images<>'' and (CHARINDEX(?, Images)=0);UPDATE repcis SET Images=? where repciid=? and Images IS NULL; ";
					$params4 = array(",".$filepath,$repciID,$filepath,$filepath,$repciID);
					$stmt4 = sqlsrv_query( $link, $sql4, $params4);
					if (!$stmt4){
						sqlsrv_rollback( $link );
						getout(-1);
						echo "Transaccion revertida agregando Imagen a rex  ".$repciID;
						//http_response_code(404);
						die(sqlsrv_errors());
						exit;				
					}
				}
				*/
				// here you can detect if type is png or jpg if you want
				// Save the image in a defined path
				if ($filepath!=='' && strlen($input->head->base64img)!==0){ // es longitud 0 si ya esta grabado
					$filepath='../DCImages/'.$filepath;
					$baseFromJavascript = $input->head->base64img; //your data in base64 'data:image/png....';
					// We need to remove the "data:image/png;base64, if is an image if it is a pdf not"
					if (substr($filepath,-4)!='.pdf'){
						$base_to_php = explode(',', $baseFromJavascript);
						// the 2nd item in the base_to_php array contains the content of the image
						$data = base64_decode($base_to_php[1]);
					}
					else
						$data = base64_decode($baseFromJavascript);
					file_put_contents($filepath,$data);
				}
			}
			else{
				sqlsrv_rollback( $link );
				getout(-1);
				echo "Transaccion revertida no se pudieron grabar las tuplas";
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
			getout(-3);
			echo "No se pudo registrar Error: ".$errMsg."\n";//.serialize($params1)."\n".$jsonPayload;
			//http_response_code(404);
			die(sqlsrv_errors());
			exit;
		}
		$repciID = filter_var($input->head->repciID,FILTER_VALIDATE_INT);
		$titulo=filter_var($titulo,FILTER_SANITIZE_STRING);
		if ($repciID !="" && $titulo !=""){ // es viejo pero se edito el titulo, hay que sustituirlo.
			$titulo = utf8_decode($titulo);
			$titulo = iconv('UTF-8', 'ISO-8859-1',$titulo);
			$sql4 = "UPDATE repcis SET titulo=? where repciid=?;";
			$params4 = array($titulo,$repciID);
			$stmt4 = sqlsrv_query( $link, $sql4, $params4);
		}
		// Hacer las copias de $CopyRexArray aqui y mover el commit despues de las copias
		// si hay una copia y la carpeta está "cerrada" o si se debe borrar de un DC de una carpeta "cerrada" para escribir en otra o en ella misma no se hace la operación y se hace rollback 
		/*sqlsrv_rollback( $link );
		echo json_encode("CopyRexArray:".json_encode($CopyRexArray)."\n");
		//getout(-4);
		die(sqlsrv_errors());
		exit;
		*/
		
		while (!empty($CopyRexArray) ){
			$rexToCopy = array_pop($CopyRexArray);
			$DossierStatus = GetDossierStatus($link,$rexToCopy);
			if ($DossierStatus=='Not Found' || $DossierStatus=='Closed' || $DossierStatus=='Deleted'){
				sqlsrv_rollback( $link );
				getout(-4);
				echo "No se pudo copiar el DC con status: ".$DossierStatus.$errMsg."\n";
				//http_response_code(404);
				die(sqlsrv_errors());
				exit;
			}
			//Se debe buscar donde estan las copias del rex actual (antes de este momento) si se esta editando.
			// y si esa carpeta esta cerrada,borrada,o no se encuentra,  no se puede grabar nada.
			// Si se puede proceder, se deben borrar donde está la copia de ese DC y luego hacer la grabacion
			// Se supone que esto pasa cuando alguien se equivoca escogiendo el spin que copia a source y luego lo corrige.
			if (strlen($DCWebId)!=0){
				//Hay que borrar la copia de donde está y ponerla donde debe estar. Es decir buscar si en si $DCWebID está en algun OriginalDC , si está borrarlo y ponerlo en el nuevo
				$DossierStatus = GetDossierStatusByDc($link,$DCWebId);
				if ($DossierStatus=='Closed' || $DossierStatus=='Deleted'){
					sqlsrv_rollback( $link );
					getout(-4);
					echo "No se pudo copiar el DC porque el Dossier de referencia está cerrado o borrado: ".$errMsg."\n";
					//http_response_code(404);
					die(sqlsrv_errors());
					exit;
				}
				$sqlDel = "Select repciId,DCtype from repciDcs where OriginalDC=?;delete from repciDcs where OriginalDC = ?;";
				$paramDel = array($DCWebId,$DCWebId);
				$DelStmt = sqlsrv_query( $link, $sqlDel, $paramDel);
				if (!$DelStmt){
					sqlsrv_rollback( $link );
					getout(-4);
					echo "No se pudo borrar el DC de referencia anterior: ".$errMsg."\n";
					//http_response_code(404);
					die(sqlsrv_errors());
					exit;
				}
				//rex a recalcular esta aqui
				sqlsrv_fetch($DelStmt);
				$rexid=sqlsrv_get_field($DelStmt, 0);
				$dctype = sqlsrv_get_field($DelStmt, 1);
				
				//Verificar si el rex que tiene la copia borrada se debe hacer un recalculo de totales, Mosca
				
				//Aqui verificamos si hay que hacer totales de la copia borrada, Mosca
				// verifica si este $rexToCopy con este 'Copia $DCType' se debe recalcular, para ello hay que leer el grupo de este rex y verificar en el Calc.
				$GetGroupSQL="select grupo,repcis.repciId from repcis where repciid = ?";
				$paramsgroup = array($rexid); 
				$stmtgroup = sqlsrv_query( $link, $GetGroupSQL, $paramsgroup);
				if ($stmtgroup){
					//sqlsrv_next_result($stmtgroup);
					sqlsrv_fetch($stmtgroup);
					$gr=sqlsrv_get_field($stmtgroup, 0);
					$rexId = sqlsrv_get_field($stmtgroup, 1);
					$dct = $dctype;
					$JsonFile="../grupos/".$gr.".json";					
					$strJsonFileContents = file_get_contents($JsonFile);
					$JsonGrupo=json_decode($strJsonFileContents, true);
					$formula=$JsonGrupo['Totales'][0]['Calc'];
					$NombreDCTotales = $JsonGrupo['Totales'][0]['DC'];
					$retHeadTotal = $JsonGrupo['Totales'][0]['rethead'];
					if(CheckIfTotalsGo($formula,$dct)!=false){
						$TotTuples = GetTotalTuples($rexId,$formula,$link);
						//change status of the actual TotalDC and add the new one
						$ChangeStatusTotalSQL = "update repciDcs set status = -1 where DCType ='".$NombreDCTotales."' and status = 0 and repciId = ?" ;
						$paramChange = array($rexId);
						$ChangeStmt = sqlsrv_query( $link, $ChangeStatusTotalSQL, $paramChange);
						$TotalParams['user']=$user;
						$TotalParams['longitud']=$longitud;
						$TotalParams['latitud']=$latitud;
						$TotalParams['IP']=$IP;
						$TotalParams['GPSOrg']=$GPSOrg;
						$TotalParams['comment']=$comment;
						$OperTotales = AddTotales($rexId,$TotTuples,$link,$NombreDCTotales,$retHeadTotal,$TotalParams);
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
				
				
				//////////////////////
			}
			/////////////////////////////////////////////////////////////
			$sql1 = "INSERT INTO repciDCs (repciId, fromUser, when_date,DCType,longitud,latitud, status,filepath,PrevDC,IP,ServerTime,LocationOrigin,comment,OriginalDC)
				  VALUES (?, ?, ?, ?, ?, ?, ?, ?,?,?,GetDate(),?,?,?); SELECT SCOPE_IDENTITY() as last_ins_id";//, ?, ?); //;//,ip, iporg)
			$params1 = array($rexToCopy, intchars($user),$when_date, intchars('Copia '.$DCType), $longitud,$latitud,0,$filepath,0,$IP,$GPSOrg,$comment,$last_id); // $DCWebId no tiene nada que ver con copias, pero si con actualizaciones de copias
			$stmt1 = sqlsrv_query( $link, $sql1, $params1);
			$last_idCopy =0;
			if($stmt1){		
				$last_idCopy =lastId($stmt1);
					$cedulaRobot = '';
					foreach ($input->tuple as $tup){
						$V1=filter_var($tup->V1,FILTER_SANITIZE_STRING);
						$V1 = utf8_decode($V1);
						$V1 = iconv('UTF-8', 'ISO-8859-1',$V1);
						
						$V2=filter_var($tup->V2,FILTER_SANITIZE_STRING);
						$V2 = utf8_decode($V2);
						$V2 = iconv('UTF-8', 'ISO-8859-1',$V2);
						$V3="";$V4="";$V5="";
						$sql2 = "INSERT INTO repciDCTuplas (idDC, value1, value2, value3, value4, value5)
								  VALUES (?, ?, ?, ?, ?, ?)";
						try{
							$V3=filter_var($tup->V3,FILTER_SANITIZE_STRING);
							$V3 = utf8_decode($V3);
							$V3 = iconv('UTF-8', 'ISO-8859-1',$V3);

						}
						catch(Exception $e){
							$V3="";
						}
						try{
							$V4=filter_var($tup->V4,FILTER_SANITIZE_STRING);
							$V4 = utf8_decode($V4);
							$V4 = iconv('UTF-8', 'ISO-8859-1',$V4);
						}
						catch(Exception $e){
							$V4="";
						}
						try{
							$V5=filter_var($tup->V5,FILTER_SANITIZE_STRING);
							$V5 = utf8_decode($V5);
							$V5 = iconv('UTF-8', 'ISO-8859-1',$V5);

						}
						catch(Exception $e){
							$V5="";
						}
						$params2 = array( $last_idCopy, $V1, $V2, $V3, $V4, $V5);
						$stmt2 = sqlsrv_query( $link, $sql2, $params2);
						if (!$stmt2)
							break;
					}	
				//}
				if (!$stmt2){ 
					sqlsrv_rollback( $link );
					getout(-1);
					echo "Transaccion revertida no se pudieron grabar las tuplas de la copia";
					//http_response_code(404);
					die(sqlsrv_errors());
					exit;
				}
				//Aqui verificamos si hay que hacer totales de la copia, Mosca
				// verifica si este $rexToCopy con este 'Copia $DCType' se debe recalcular, para ello hay que leer el grupo de este rex y verificar en el Calc.
				$GetGroupSQL="select grupo from repcis where repciId = ?";
				$paramsgroup = array($rexToCopy); 
				$stmtgroup = sqlsrv_query( $link, $GetGroupSQL, $paramsgroup);
				if ($stmtgroup){
					//sqlsrv_next_result($stmtgroup);
					sqlsrv_fetch($stmtgroup);
					$JsonFile="../grupos/".sqlsrv_get_field($stmtgroup, 0).".json";					
					$strJsonFileContents = file_get_contents($JsonFile);
					$JsonGrupo=json_decode($strJsonFileContents, true);
					$formula=$JsonGrupo['Totales'][0]['Calc'];
					$NombreDCTotales = $JsonGrupo['Totales'][0]['DC'];
					$retHeadTotal = $JsonGrupo['Totales'][0]['rethead'];
					
					if(CheckIfTotalsGo($formula,'Copia '.$DCType)!=false){
						$TotTuples = GetTotalTuples($rexToCopy,$formula,$link);
						//change status of the actual TotalDC and add the new one
						$ChangeStatusTotalSQL = "update repciDcs set status = -1 where DCType ='".$NombreDCTotales."' and status = 0 and repciId = ?" ;
						$paramChange = array($rexToCopy);
						$ChangeStmt = sqlsrv_query( $link, $ChangeStatusTotalSQL, $paramChange);
						$TotalParams['user']=$user;
						$TotalParams['longitud']=$longitud;
						$TotalParams['latitud']=$latitud;
						$TotalParams['IP']=$IP;
						$TotalParams['GPSOrg']=$GPSOrg;
						$TotalParams['comment']=$comment;
						$OperTotales = AddTotales($rexToCopy,$TotTuples,$link,$NombreDCTotales,$retHeadTotal,$TotalParams);
					}
				}
				else{
					sqlsrv_rollback( $link );
					//getout(-1);
					echo "Transaccion revertida no se pudo leer el grupo del Dossier donde se copia";
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
				getout(-3);
				echo "No se pudo registrar DC Copia Error: ".$errMsg."\n";
				//http_response_code(404);
				die(sqlsrv_errors());
				exit;
			}
				
			//Es posible que este dataclip modifique el dataclip de totales de el rex en donde se copio.
			
			// Hay que ver el grupo de este dataclip, leer totales, ver si este dataclip afecta el rex y si es asi
			// hacer totales nuevo.
			
			////////////////////////////////////////////////////////////
	
		}
		
		//aqui vemos si tenemos que agregar totales
		if(CheckIfTotalsGo($totales[0]->Calc,$DCType)!=false){
			$NombreDCTotales = $totales[0]->DC;
			$retHeadTotal = $totales[0]->rethead;
					
			$TotTuples = GetTotalTuples($repciID,$totales[0]->Calc,$link);
			//change status of the actual TotalDC and add the new one
			$ChangeStatusTotalSQL = "update repciDcs set status = -1 where DCType ='".$NombreDCTotales."' and status = 0 and repciId = ?" ;
			$paramChange = array($repciID);
			$ChangeStmt = sqlsrv_query( $link, $ChangeStatusTotalSQL, $paramChange);
			$TotalParams['user']=$user;
			$TotalParams['longitud']=$longitud;
			$TotalParams['latitud']=$latitud;
			$TotalParams['IP']=$IP;
			$TotalParams['GPSOrg']=$GPSOrg;
			$TotalParams['comment']=$comment;
			$OperTotales = AddTotales($repciID,$TotTuples,$link,$NombreDCTotales,$retHeadTotal,$TotalParams);
		}
		postcheck($input,$link);// cualquier tarea propia de la solucion como grabar o verificar dentro de la transaccion.
		sqlsrv_commit( $link );
		
	break;//"insert 
  
  case 'DELETE':
    $sql = "";break;//"delete `$table` where id=$key"; break;
} 
 

 
// print results, insert id or affected row count
if ($method == 'POST') {
	header('Cache-Control: no-cache, must-revalidate');
	header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
	// headers to tell that result is JSON
	header('Content-type: application/json');
	//$metaData = sqlsrv_field_metadata($result);
	echo json_encode($last_id);
}
// close mysql connection
sqlsrv_free_stmt($stmt1); 
sqlsrv_free_stmt($stmt2); 
sqlsrv_free_stmt($stmtgroup); 
sqlsrv_free_stmt($stmtUpdates);
sqlsrv_close($link);
?>