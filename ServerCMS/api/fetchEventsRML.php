<?php
 


$method = $_SERVER['REQUEST_METHOD'];

 
$token=filter_var($_GET["t"],FILTER_SANITIZE_STRING);
$userid=filter_var($_GET["u"],FILTER_SANITIZE_STRING);
$userid=strtolower($userid);

$start=filter_var($_GET["start"],FILTER_SANITIZE_STRING);
$end=filter_var($_GET["end"],FILTER_SANITIZE_STRING);

	$NoVa = false;
	$NoVa= (!$token && !$userid);
	if ($NoVa){
		header('Cache-Control: no-cache, must-revalidate');
		header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
		// headers to tell that result is JSON
		header('Content-type: application/json');
		echo json_encode([]);
		exit;
	}

$GruposDeUsuarios=[];

include 'CurrentCalendarLanguage.php';

include 'GrupoDeUsuarios.php';
	
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
		$sql = "select repciDcs.repciId, repciDcTuplas.idDC, repciDcTuplas.value1,repciDcTuplas.value2 from repciDcTuplas,repciDcs,repcis where  repciDcs.DCType='".$langtext["Recordatorio"]."' and repciDCTuplas.idDC = repciDcs.id ";
		$sql = $sql." and repciDcs.status=0 and repciDcs.repciId = repcis.repciId and repcis.status = 1 ";
		$sqlGrupo = "";
		if ($userid!==''){
			$sql=$sql." and repciDcs.fromUser='$userid' ";// go solo
		}
		if ($start!=="" || $end!==""){
			$sql = $sql." and repciDcTuplas.idDC in (";
			if ($start!==""){
				$subsql = " select repciDcs.id from repciDcs,repciDCTuplas where repciDcs.id=repciDcTuplas.idDC and repciDcTuplas.value1='".$langtext["FechaRecordatorio"]."' and repciDcTuplas.value2>='$start'";
			}
			if ($end!==""){
				if ($start!==""){
					$subsql=$subsql." INTERSECT ";
				}
				$subsql = $subsql." select repciDcs.id from repciDcs,repciDCTuplas where repciDcs.id=repciDcTuplas.idDC and repciDcTuplas.value1='".$langtext["FechaRecordatorio"]."' and repciDcTuplas.value2<='$end'";
			}
		}
		$sql=$sql.$subsql;
		if ($start!=="" || $end!==""){
			$sql=$sql.")";
		}
		$sql=$sql." order by idDC;";
		//echo $sql."<BR>";
    break;
  default:
		echo json_encode([]);
		exit;
	break;
}
// excecute SQL statement
$result =  sqlsrv_query($link,$sql);
 
// die if SQL statement failed
if (!$result) {
	echo json_encode([]);
	exit;
}
if (!sqlsrv_has_rows($result)){
		echo json_encode([]);
		exit;
	}
	else {
		$metaData = sqlsrv_field_metadata($result);
		$numFields = sqlsrv_num_fields( $result );
		echo "[\n";
		$first_row=TRUE;
		$grupo='';
		$idDC='';
		while( sqlsrv_fetch( $result )) {
		   $repciId = mb_convert_encoding(sqlsrv_get_field($result, 0), "UTF-8", "HTML-ENTITIES");	   
		   $dummDC=mb_convert_encoding(sqlsrv_get_field($result, 1), "UTF-8", "HTML-ENTITIES");
		   if ($idDC !== $dummDC && $idDC!==''){
				echo "}";
			}
			if (!$first_row){
				echo",";
			}
			
		   if ($idDC !== $dummDC)
				echo'{"id":"'.$repciId.'", "idDC":"'.$dummDC.'",';
		   $desc = sqlsrv_get_field($result, 2);
		   if ($desc==$langtext["ObsRecordatorio"]){
			   $desc='title';			   
		   }
		   if ($desc==$langtext["FechaRecordatorio"]){
			   $desc='start';			   
		   }
		   $value = mb_convert_encoding(sqlsrv_get_field($result, 3), "UTF-8", "HTML-ENTITIES");
			echo '"'.$desc . '":"'.$value.'"';
		   
			$idDC = $dummDC;
			
			$first_row=FALSE;			
		}
		//echo"\t}\n";
		echo"}]\n";
	}		
		
// close mysql connection
sqlsrv_free_stmt($result); 
sqlsrv_close($link);
 	
?>