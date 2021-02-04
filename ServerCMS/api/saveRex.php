<?php
  
 //Ejemplo de como se llama desde el web este restfull
 //https://www.tuapoyo.net/Dossier2/api/saveDC.php
 
// get the HTTP method, path and body of the request

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
	$retStruct['LocalRexID']=0;
	$retStruct['repciID']=0;
	$retStruct['error']='No va '.$value;
	$retStruct['Dcs']=[];					
	echo json_encode($retStruct);
	exit;
}

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
	
	$token=filter_var($input->token,FILTER_VALIDATE_INT);
	$repciID = filter_var($input->repciID,FILTER_VALIDATE_INT);
	$creator = filter_var($input->creator,FILTER_SANITIZE_STRING);
	$when_date = filter_var($input->when_date,FILTER_SANITIZE_STRING);
	$when_date = substr("$when_date",0,4).'-'.substr("$when_date",4,2).'-'.substr("$when_date",6,2).' '.substr("$when_date",9,2).':'.substr("$when_date",11,2).':00';
	$longitud = filter_var($input->longitud,FILTER_VALIDATE_FLOAT);
	$longitud = $longitud + 0.0;
	$latitud = filter_var($input->latitud,FILTER_VALIDATE_FLOAT);
	$latitud = $latitud + 0.0;
	$Images = filter_var($input->Images,FILTER_SANITIZE_STRING); // or image.jpg
	$titulo = filter_var($input->titulo,FILTER_SANITIZE_STRING);
	$grupo = filter_var($input->grupo,FILTER_VALIDATE_INT);
	$repcitype = filter_var($input->repcitype,FILTER_SANITIZE_STRING);
	$notift = filter_var($input->notift,FILTER_VALIDATE_INT);
	$LocalRexID = filter_var($input->id,FILTER_VALIDATE_INT);

	$text='';
	$NoVa = false;
	$NoVa= (!$token);// or !$repciID
	$NoVa=$NoVa or ($creator=='' or $repcitype=='' or $when_date=='');
	

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
		
		getout('-1 '.$text);
	}

	foreach ($input->Dcs as $dc){
		if ($dc->DCType =='' or $dc->GPSOrg =='' or $dc->fromUser =='' or $dc->id =='' ){
			getout('Dc malformado');
		}		
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
			$retStruct['LocalRexID']=$LocalRexID;
			if ($repciID==""){//Se debe crear el Dossier que apadrina el DC que viene si este non existe.	
				
				$sql0 = "insert into repcis (titulo,when_date,longitud,latitud,accuracy,provider,owner,creator,repcitype,NotificationType,status,mod_date, grupo,q_attached,IP,ServerTime,LocationOrigin) 
				VALUES (?, ?, ?, ?, ?, ?, ?, ?,?,?,?,?,?,?,?,GetDate(),?); SELECT SCOPE_IDENTITY() as last_ins_id";
				$titulo=filter_var($titulo,FILTER_SANITIZE_STRING);
						$titulo = utf8_decode($titulo);
						$titulo = iconv('UTF-8', 'ISO-8859-1',$titulo);
				$params0 = array( $titulo, $when_date, $longitud,$latitud,0,'',$creator,$creator,$repcitype,$notift,1,$when_date,$grupo,0,$IP,$GPSOrg);
				
				$stmt0 = sqlsrv_query( $link, $sql0, $params0);
				$last_id =0;
				if($stmt0){
					$repciID =lastId($stmt0);
					$retStruct['repciID']=$repciID;		
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
					//getout(-4);
					getout("No se pudo registrar Rex, Error: ".$errMsg."\n");
					
				}
			}
			$DcsArr = array();
			foreach ($input->Dcs as $dc){
				$DCWebId = filter_var($dc->DCWebId,FILTER_VALIDATE_INT);
				$DCType =filter_var($dc->DCType,FILTER_SANITIZE_STRING);
				$when_date = filter_var($dc->when_date,FILTER_SANITIZE_STRING);
				$when_date = substr($when_date, 0, -2).'00';
				//$when_date = substr("$when_date",0,4).'-'.substr("$when_date",4,2).'-'.substr("$when_date",6,2).' '.substr("$when_date",9,2).':'.substr("$when_date",11,2).':'.substr("$when_date",13,2);
				$longitud = filter_var($dc->longitud,FILTER_VALIDATE_FLOAT);
				$latitud = filter_var($dc->latitud,FILTER_VALIDATE_FLOAT);
				$IP = filter_var($dc->IP,FILTER_SANITIZE_STRING);
				if ($IP=="")
					$IP=$_SERVER['REMOTE_ADDR'];
				$GPSOrg = filter_var($dc->GPSOrg,FILTER_SANITIZE_STRING);
				try{
					$filepath = filter_var($dc->filename,FILTER_SANITIZE_STRING); // or image.jpg
					if ($filepath==null)
						$filepath="";
					
				}
				catch(Exception $e){
							$filepath ="";
						}
				$comment = filter_var($dc->comment,FILTER_SANITIZE_STRING);
				$comment = utf8_decode($comment);
				$comment = iconv('UTF-8', 'ISO-8859-1',$comment);
				$fromUser = filter_var($dc->fromUser,FILTER_SANITIZE_STRING);
				$LocalDcID = filter_var($dc->id,FILTER_VALIDATE_INT);
				$PrevDC=0;
				$sql1 = "INSERT INTO repciDCs (repciId, fromUser, when_date,DCType,longitud,latitud, status,filepath,PrevDC,IP,ServerTime,LocationOrigin,comment)
					  VALUES (?, ?, ?, ?, ?, ?, ?, ?,?,?,GetDate(),?,?); SELECT SCOPE_IDENTITY() as last_ins_id";//, ?, ?); //;//,ip, iporg)
				$params1 = array( $repciID, intchars($fromUser),$when_date, intchars($DCType), $longitud,$latitud,0,$filepath,$PrevDC,$IP,$GPSOrg,$comment);
				$stmt1 = sqlsrv_query( $link, $sql1, $params1);
				$last_id =0;
				$Dc['LocalDcID'] = $LocalDcID;
				if($stmt1){	
							
					$last_id =lastId($stmt1);
					$Dc['idDC'] = $last_id;
					
					$DcsArr[]=$Dc;
					
					$EstatusRobot = '';
					$operadoraRobot = '';
					$numeroRobot = '';
					$cedulaRobot = '';
					
					foreach ($dc->Tuplas as $tup){
						$V1=filter_var($tup->value1,FILTER_SANITIZE_STRING);
						$V1 = utf8_decode($V1);
						$V1 = iconv('UTF-8', 'ISO-8859-1',$V1);
						
						$V2=filter_var($tup->value2,FILTER_SANITIZE_STRING);
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
						}
						$V3="";$V4="";$V5="";
						$sql2 = "INSERT INTO repciDCTuplas (idDC, value1, value2, value3, value4, value5)
								  VALUES (?, ?, ?, ?, ?, ?)";
						try{
							$V3=filter_var($tup->value3,FILTER_SANITIZE_STRING);
							$V3 = utf8_decode($V3);
							$V3 = iconv('UTF-8', 'ISO-8859-1',$V3);

						}
						catch(Exception $e){
							$V3="";
						}
						try{
							$V4=filter_var($tup->value4,FILTER_SANITIZE_STRING);
							$V4 = utf8_decode($V4);
							$V4 = iconv('UTF-8', 'ISO-8859-1',$V4);
						}
						catch(Exception $e){
							$V4="";
						}
						try{
							$V5=filter_var($tup->value5,FILTER_SANITIZE_STRING);
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
						if ($filepath!==''){
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
						
						// here you can detect if type is png or jpg if you want
						// Save the image in a defined path
						if ($filepath!=='' && strlen($dc->base64img)!==0){ // es longitud 0 si ya esta grabado
							$filepath='../DCImages/'.$filepath;
							$baseFromJavascript = $dc->base64img; //your data in base64 'data:image/png....';
							// We need to remove the "data:image/png;base64,"
							$base_to_php = explode(',', $baseFromJavascript);
							// the 2nd item in the base_to_php array contains the content of the image
							$data = base64_decode($base_to_php[1]);
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
					$errMsg.="SQL:".$sql1."\n";
					$errMsg.="Params:".json_encode($params1)."\n";
					getout($errMsg);					
					die(sqlsrv_errors());
					exit;
				}
			}
			sqlsrv_commit( $link );
			$PerRepciID = $repciID; 
			$repciID = filter_var($input->repciID,FILTER_VALIDATE_INT);
			$titulo=filter_var($titulo,FILTER_SANITIZE_STRING);
			if ($repciID !="" && $titulo !=""){ // es viejo pero se edito el titulo, hay que sustituirlo.
				$titulo = utf8_decode($titulo);
				$titulo = iconv('UTF-8', 'ISO-8859-1',$titulo);
				$sql4 = "UPDATE repcis SET titulo=? where repciid=?;";
				$params4 = array($titulo,$repciID);
				$stmt4 = sqlsrv_query( $link, $sql4, $params4);
			}
			$retStruct['Dcs']=$DcsArr;			
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
		echo json_encode($retStruct);
		//$retStruct->repciID = $PerRepciID;
		//$retStruct->DcID = $last_id;
		//$echo json_encode($retStruct);
	}
	// close mysql connection
	sqlsrv_free_stmt($stmt1); 
	sqlsrv_free_stmt($stmt2); 
	sqlsrv_close($link);
exit;
?>