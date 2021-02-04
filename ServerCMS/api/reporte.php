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
	echo json_encode($value);
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
$queryField = filter_var($input->QueryField,FILTER_SANITIZE_STRING);
$queryValue = filter_var($input->QueryValue,FILTER_SANITIZE_STRING);
$grupo = filter_var($input->grupo,FILTER_VALIDATE_INT);
$sello = filter_var($input->Sello,FILTER_VALIDATE_INT);
$dossierStatus=filter_var($input->DossierStatus,FILTER_VALIDATE_INT);
$expediente = filter_var($input->expediente,FILTER_SANITIZE_STRING);
$DCType = filter_var($input->DCType,FILTER_SANITIZE_STRING);
$fromUser = filter_var($input->fromUser,FILTER_SANITIZE_STRING);
$D1 = filter_var($input->d1,FILTER_SANITIZE_STRING);
$D2 =filter_var($input->d2,FILTER_SANITIZE_STRING);
$ted =filter_var($input->ted,FILTER_SANITIZE_STRING);
$CamposDC =$input->CamposDC;

if ($sello==''){ // para back compatibility
	$sello=0;
}
if($dossierStatus==''){
	$dossierStatus=1;
}

$StatusQuery =' repcis.status = 1';
switch ($dossierStatus) {
    case 1:
        $StatusQuery =' repcis.status = 1';
        break;
    case 2:
        $StatusQuery =' repcis.status = 2';
        break;
    case 3:
        $StatusQuery =' repcis.status >= 1';
        break;
}


for ($x = 0; $x < count($CamposDC); $x++) {
	$CamposDC[$x] = filter_var($CamposDC[$x],FILTER_SANITIZE_STRING);
}

	$text='';
	$NoVa = false;
	$NoVa= (!$token or $grupo=='' or $expediente=='' or $DCType=='');// or !$repciID
		
	if ($NoVa){
		header('Cache-Control: no-cache, must-revalidate');
		header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
		// headers to tell that result is JSON
		header('Content-type: application/json');	
		$Mess = "";
		if (!$token)
			$Mess = "por token";
		if ($grupo=='')
			$Mess = "por grupo";
		if ($expediente=='')
			$Mess = "por expediente";
		if ($expediente=='')
			$Mess = "por expediente";
		if ($DCType=='')
			$Mess = "por DCType";
		echo json_encode('No va '.$Mess);
		exit;
	}

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
		/*
		header('Cache-Control: no-cache, must-revalidate');
		header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
		// headers to tell that result is JSON
		header('Content-type: application/json');
	  	*/
		$sql='select distinct ';
		$from = 'from repcis,repciDcs DC ';
		$tedWhere= "";
		$TituloActive=false;
		for ($x = 0; $x < count($CamposDC); $x++) {
			$dumb = str_replace(" ","_",$CamposDC[$x]);// en caso de que alguien le ponga a un rethead un espacio en blanco
			$dumb = str_replace(".","_",$dumb);// en caso de que alguien le ponga a un rethead un punto
			$dumb = str_replace("-","_",$dumb);// en caso de que alguien le ponga a un rethead un menos
			$dumb = str_replace("(","_",$dumb);// en caso de que alguien le ponga a un rethead un menos
			$dumb = str_replace(")","_",$dumb);// en caso de que alguien le ponga a un rethead un menos
			if (is_numeric($dumb[0]))
					$dumb='N'.substr($dumb, 1);

			if ($dumb=='Titulo'){
				$sql .= " repcis.titulo as Titulo ";
				$TituloActive=true;
			}
			else{
				if ($dumb=='Fecha_DC'){
					$sql .= " CONVERT(VARCHAR(10), DC.when_date, 23) as Fecha_DC ";
				}
				else{
					if ($dumb=='Hora_DC'){
						$sql .= " CONVERT(VARCHAR(10), DC.when_date, 108) as Hora_DC ";
					}
					else{
						if ($dumb=='Usuario_DC'){
							$sql .= " DC.fromUser as Usuario_DC ";
						}
						else{ // es un campo de Tuplas
							$from .= " left join repciDcTuplas D".$x." on D".$x.".value1='".$CamposDC[$x]."' and D".$x.".idDC = DC.id ";
							$sql .= " D".$x.".value2 as ".$dumb;					
						}
					}						
				}
			}
					
			if ($x!=count($CamposDC)-1)
				$sql .= ", ";
		}
		if (count($CamposDC)==1){
			$sql .= ', count(*) as Cantidad';
			if ($CamposDC[0]=='Usuario_DC')
				$groupby = ' group by DC.fromUser ';
			else
				if ($CamposDC[0]=='Fecha_DC')
					$groupby = ' group by CONVERT(VARCHAR(10), DC.when_date, 23) ';
				else
					if ($CamposDC[0]=='Hora_DC')
						$groupby = ' group by CONVERT(VARCHAR(10), DC.when_date, 108) ';
					else
						if ($CamposDC[0]=='Titulo')
							$groupby = ' group by repcis.titulo ';
						else
							$groupby = ' group by D0.value2 ';
		}
		else
			$groupby = '';
		
		$FindTim="";
		
		if ($D1 != '') 
			$FindTim = " and (CAST(DC.when_date as date) BETWEEN '".$D1."' " ;
		if ($D2 != "")
			$FindTim = $FindTim." AND '".$D2."')";
		else
		    $FindTim = $FindTim." AND '".$D1."')";
			
		$userWhere="";
		if ($fromUser!="" && $fromUser!="T"){
			$userWhere = " and DC.fromUser='".Trim($fromUser)."' ";
		}
		
		if ($ted !=""){		
			$tedWhere= " and DC.id in ";	
			$tedWhere= $tedWhere."(";
			$tedWhere= $tedWhere."select repciDcs.id from repcis, repciDcs,repciDcTuplas where DCTYpe = '".$DCType."' and repciDcs.id = repciDcTuplas.idDC ";
			if ($TituloActive){
				$tedWhere= $tedWhere." and ( repcis.titulo like '%".$ted."%' or repciDcTuplas.value2 like '%".$ted."%') ";
			}
			else
				$tedWhere= $tedWhere." and repciDcTuplas.value2 like '%".$ted."%'";
			if ($D2=="")
				$D2=$D1;
			$tedWhere= $tedWhere." and (CAST(repciDcs.when_date as date) BETWEEN '".$D1."'  AND '".$D2."')";
			if ($fromUser!="" && $fromUser!="T")
				$tedWhere= $tedWhere." and fromUser='".trim($fromUser)."'";
			$tedWhere= $tedWhere." and repcis.repciId = repciDcs.repciId and ".$StatusQuery." )";
		}
		$where = "where ".$StatusQuery." and repcis.repciId = DC.repciId and DC.status = ".$sello." and DC.DCTYpe = '".$DCType."' and repcis.grupo='".$grupo."'".$userWhere.$FindTim.$tedWhere.$groupby;
		$sql = $sql.' '.$from.' '.$where;
		
		
		//echo json_encode($sql);
		//exit;
		$stmt = sqlsrv_query( $link, $sql);
		
		if( $stmt === false) {
			$errMsg='';
			if( ($errors = sqlsrv_errors() ) != null) {
				foreach( $errors as $error ) {
					$errMsg= "SQLSTATE: ".$error[ 'SQLSTATE']."\n";
					$errMsg .= "code: ".$error[ 'code']."\n";
					$errMsg.= "message: ".$error[ 'message']."\n";
				}
			}
			echo "No se pudo consultar";
			die(sqlsrv_errors());
			exit;
		}
		////echo("[");
		$cuenta=0;
		
		
		$DataArr = array();
		while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC) ) {
			$rowArr=array();
			////if ($cuenta!=0)
			////	echo(",");
			$cuenta++;
			////echo("{");
			
			if (count($CamposDC)==1){ // si solo estas buscando uno, quieres agruparlo
				$CamposDC[]='Cantidad';
			}
			
			for ($x = 0; $x < count($CamposDC); $x++) {
				$dumb = str_replace(" ","_",$CamposDC[$x]);// en caso de que alguien le ponga a un rethead un espacio en blanco
				$dumb = str_replace(".","_",$dumb);// en caso de que alguien le ponga a un rethead un punto
				$dumb = str_replace("-","_",$dumb);// en caso de que alguien le ponga a un rethead un menos
				$dumb = str_replace("(","_",$dumb);// en caso de que alguien le ponga a un rethead un menos
				$dumb = str_replace(")","_",$dumb);// en caso de que alguien le ponga a un rethead un menos
				if (is_numeric($dumb[0]))
					$dumb='N'.substr($dumb, 1);


				$txtIndex = $dumb;
				if ($dumb=='Fecha_DC')
					$content = $row[$txtIndex];
				else
					$content = mb_convert_encoding($row[$txtIndex], "UTF-8", "HTML-ENTITIES");
				if ($CamposDC[$x]=='Cantidad'){//(is_numeric($content)){
					$number = ($content == (int)$content) ? (int) $content : (float) $content;
					$rowArr[]=$number;
				}
				else{
					$pos = strpos($content,"dc(");
					if ($pos!=false)
						$content=substr($content,0,$pos);
					$rowArr[]=$content;
				}
			}
			////echo("}");
			
			$DataArr[]=$rowArr;
		}
		echo json_encode($DataArr);
		sqlsrv_free_stmt( $stmt);

	break;//"insert 
  
} 


// close mysql connection
sqlsrv_close($link);
?>