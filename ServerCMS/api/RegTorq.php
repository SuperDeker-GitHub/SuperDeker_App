<?php
 
 //Ejemplo de como se llama desde el web este restfull
 //https://ipaddress/RegTorq.php/id/dbid/type/readerID/reg_date_time
 
 
//RegTorq.php/id/dbid/type/readerID/reg_date_time

 
// get the HTTP method, path and body of the request


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


$method = $_SERVER['REQUEST_METHOD'];
$request = explode('/', trim($_SERVER['PATH_INFO'],'/'));
$ipaddress = $_SERVER['REMOTE_ADDR'];

$id = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$dbid = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$type = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$readerID = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$reg_date_time = filter_var(array_shift($request), FILTER_SANITIZE_STRING); //YYYYMMDDTHHMMSS

include 'dbconex.php';


if ($id=='' || $dbid=='' || $dbid=='' || $readerID =='' || $reg_date_time =='' || ($type!='I' && $type!='O') ){
		$retval=(object)[];
		echo json_encode($retval);
		exit;
}
else{
	$retval['id']=$id;
	$retval['dbid']=$dbid;
	$retval['type']=$type;
	$retval['readerID']=$readerID;
	$retval['reg_date_time']=$reg_date_time;
		
	//{"id":"234234","dbid":"5592454","type":"I","readerID":"T1","reg_date_time":"20200309T141522"} // "O" para salida

	// create SQL based on HTTP method
	
	$connectionInfo = array( "UID"=>$uid,                            
                         "PWD"=>$pwd,                            
                         "Database"=>$databaseName);
  
	/* Connect using SQL Server Authentication. */  
	$link = sqlsrv_connect( $serverName, $connectionInfo); 
	
	

	$sql = "	select distinct repciid from repciDcs ";
	$sql = $sql."	where ";
	$sql = $sql."	repciid in ";
	$sql = $sql."	 (select repciid from repciDCTuplas,repcidcs where value1='Cedula' and value2='".$dbid."' and repcidcs.id=repciDCTuplas.idDC and repcidcs.DCType='Acceso' and status=0 and when_date is not null and year(when_date)=".(int)date("Y")." and month(when_date) = ".(int)date("m")." and day(when_date)=".(int)date("d").") ";
	$sql = $sql."	and repciid not in ";
	if ($type=='I'){
		$sql = $sql."	 (select repciid from repciDCTuplas,repcidcs where value1='Cedula' and value2='".$dbid."' and repcidcs.id=repciDCTuplas.idDC and repcidcs.DCType='Ingreso' and status=0 and when_date is not null and year(when_date)=".(int)date("Y")." and month(when_date) = ".(int)date("m")." and day(when_date)=".(int)date("d")." ) ";
	}
	if ($type=='O'){
		$sql = $sql."	 (select repciid from repciDCTuplas,repcidcs where value1='Cedula' and value2='".$dbid."' and repcidcs.id=repciDCTuplas.idDC and repcidcs.DCType='Salida' and status=0 and when_date is not null and year(when_date)=".(int)date("Y")." and month(when_date) = ".(int)date("m")." and day(when_date)=".(int)date("d")." ) ";
	}
		
	//echo '<BR>'.$sql.'<BR>';
	// excecute SQL statement
	$result =  sqlsrv_query($link,$sql);
	if (!$result) {
	  http_response_code(404);
	  die(sqlsrv_errors());
	}
	switch ($method) {
	  case 'GET':
			header('Content-type: application/json; Charset=UTF-8');
			header('Access-Control-Allow-Origin: *');
			$repciid='';
			$cant = 0;
			if (!sqlsrv_has_rows($result)){
				$repciid='';
			}
			else {
				$metaData = sqlsrv_field_metadata($result);
				while( sqlsrv_fetch( $result )) {
				   // Iterate through the fields of each row.
				   $cant++;
				   $repciid = mb_convert_encoding(sqlsrv_get_field($result, 0), "UTF-8", "HTML-ENTITIES");
				}
			}
			$Tuplas=[];
			$Tuple=[];
			$Head=[];
			$JsonObj=[];
			if ($cant!=1 || $repciid==''){
				//crear novedad, porque hay que investigar es decir o no hay nadie con esa cedula hoy.
				$toktok='666123';
				$Tuple["V1"]="Novedad";
				if ($type=='I'){
					$Tuple["V2"]=$dbid.' ingreso por torniquete '.$readerID.' a las '.$reg_date_time;
				}
				else{
					$Tuple["V2"]=$dbid.' salio por torniquete '.$readerID.' a las '.$reg_date_time;
				}
				$Tuplas[]=$Tuple;
				$Tuple["V1"]="TipoNovedad";
				$Tuple["V2"]='Acceso a deshora';
				$Tuplas[]=$Tuple;
				$Tuple["V1"]="Referencia";
				$Tuple["V2"]=$dbid;
				
				$Head["titulo"]="Acceso irregular Id:".$dbid;
				$Head["filename"]="";
				$Head["Comment"]="";
				$Head["repciID"]="";
				$Head["user"]=$readerID; 
				$Head["DCWebId"]='';
				$Head["PrevDC"]='';
				$Head["NeExtDC"]='';
				$Head["DCType"]='Novedad';
				$Head["when_date"]= date('Y-m-d H:i:s');
				$Head["longitud"]=-66.8249;
				$Head["latitud"]=10.4658;
				$Head["IP"]=$ipaddress;
				$Head["GPSOrg"]='Torq';
				$Head["CopyToRexs"]=[]; 
				$Head["grupo"]="185";
				$Head["notift"]="0";
				$Head["repcitype"]="0";
				$Head["Totales"]=[];
				
				$JsonObj['token']= $toktok;
				$JsonObj['head']= $Head;
				$JsonObj['tuple']= $Tuplas;
			}
			else{
				//Agregar un ingreso o una salida en este repciid
				$toktok='666123';
			
				$Tuple["V1"]="Cedula";
				$Tuple["V2"]=$dbid;
				$Tuplas[]=$Tuple;
				$Tuple["V1"]="IDTorniquete";
				$Tuple["V2"]=$readerID;
				$Tuplas[]=$Tuple;
				$Tuple["V1"]="Cant";
				$Tuple["V2"]="1";
				$Tuplas[]=$Tuple;
				$Tuple["V1"]="FechaHora";
				$Tuple["V2"]=$reg_date_time;
				$Tuplas[]=$Tuple;
			
				$Head["repciID"]=$repciid;
				$Head["user"]=$readerID; 
				$Head["DCWebId"]='';
				$Head["PrevDC"]='';
				$Head["NeExtDC"]='';
				if ($type=='I'){
					$Head["DCType"]='Ingreso';
				}
				else{
					$Head["DCType"]='Salida';
				}
				$Head["when_date"]= date('Y-m-d H:i:s');
				$Head["longitud"]=-66.8249;
				$Head["latitud"]=10.4658;
				$Head["IP"]=$ipaddress;
				$Head["GPSOrg"]='Torq';
				$Head["CopyToRexs"]=[]; 
				$Head["grupo"]="150";
				$Head["notift"]="0";
				$Head["repcitype"]="0";
				$Head["Totales"]=json_decode('[{"DC":"Balance","Calc":"Sum(Ingreso.Cant,-Salida.Cant)","rethead":"Balance"}]');
				
				$JsonObj['token']= $toktok;
				$JsonObj['head']= $Head;
				$JsonObj['tuple']= $Tuplas;
				
			}
			$Method="POST";
				
			//echo json_encode($JsonObj);				
			
			$get_data = callAPI('POST', 'api/saveDC-v132.php?', json_encode($JsonObj));
			$response = json_decode($get_data, true);
			$errors = $response['response']['errors'];
			$data = $response['response']['data'][0];
			
			//echo json_encode($response);	
			
			echo json_encode($retval);
			
			break;
	  case 'PUT':
		  
		  break;
	  case 'POST':      
		break;
	  case 'DELETE':
		break;
	} 
}

sqlsrv_free_stmt( $result); 
sqlsrv_close($link);


?>