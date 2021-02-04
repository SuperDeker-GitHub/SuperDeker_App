<?php
 
$method = $_SERVER['REQUEST_METHOD'];

 
$token=filter_var($_GET["t"],FILTER_SANITIZE_STRING);
$userid=filter_var($_GET["u"],FILTER_SANITIZE_STRING);

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
		$sql = "select repciDcs.repciId, repciDcTuplas.idDC, repciDcTuplas.value1,repciDcTuplas.value2 from repciDcTuplas,repciDcs,repcis where repciDcs.repciid=repcis.repciid and repcis.status=1  and  (repciDcTuplas.value1='FechaCita' ) and repciDCTuplas.idDC = repciDcs.id and repciDcTuplas.idDC in ";		
		
		$subsql = "( select ";
		$subsql =$subsql." repciDcs.id ";
		$subsql =$subsql." from ";
		$subsql =$subsql." 	repciDcs,repciDCTuplas ";
		$subsql =$subsql." where ";
		$subsql =$subsql." 	repciDcs.status=0 and ";
		$subsql =$subsql." 	repciDcs.fromUser='$userid' and ";
		$subsql =$subsql." 	repciDcs.id=repciDcTuplas.idDC and ";
		$subsql =$subsql." 	repciDcs.DcType = 'Cita' and ";
		$subsql =$subsql." 	repciDcTuplas.value1='FechaCita' and ";
		$subsql =$subsql." 	repciDcTuplas.value2<='$end' ";
		$subsql=$subsql." INTERSECT ";
		$subsql =$subsql."select repciDcs.id from repciDcs,repciDCTuplas where repciDcs.status=0 and repciDcs.id=repciDcTuplas.idDC)";// and repciDcTuplas.value1='Estado' and repciDcTuplas.value2='Activo')";
		

		
		/*$subsql = "( select repciDcs.id from repciDcs,repciDCTuplas where repciDcs.status=0 and repciDcs.id=repciDcTuplas.idDC and repciDcTuplas.value1='Estado' and repciDcTuplas.value2>='Activa'";
		if ($start!==""){
			$subsql =$subsql." INTERSECT select repciDcs.id from repciDcs,repciDCTuplas where repciDcs.status=0 and repciDcs.id=repciDcTuplas.idDC and repciDcTuplas.value1='FechaTarea' and repciDcTuplas.value2>='$start'";
		}
		if ($end!==""){
			$subsql=$subsql." INTERSECT ";
			$subsql =$subsql."select repciDcs.id from repciDcs,repciDCTuplas where repciDcs.status=0 and repciDcs.id=repciDcTuplas.idDC and repciDcTuplas.value1='FechaTarea' and repciDcTuplas.value2<='$end'";
		}
		if ($userid!==''){
			$subsql=$subsql." INTERSECT ";
			$subsql =$subsql."select repciDcs.id from repciDcs,repciDCTuplas where repciDcs.status=0 and repciDcs.id=repciDcTuplas.idDC and repciDcTuplas.value1='EjecutorTarea' and repciDcTuplas.value2='$userid'";
		}*/
		$sql=$sql.$subsql." order by idDC;";
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
				echo'{"repciId":"'.$repciId.'", "idDC":"'.$dummDC.'",';
		   $desc = sqlsrv_get_field($result, 2);
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