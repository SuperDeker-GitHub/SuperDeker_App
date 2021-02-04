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

$GruposDeUsuarios=[];

include 'CurrentCalendarLanguage.php';

include 'GrupoDeUsuarios.php';

//echo json_encode(count($GruposDeUsuarios));
	
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
// se sacan las que tienen OriginalDc para que las copias no aparezca, ya que el original está en la lista
switch ($method) {
  case 'GET':
		$sql = "select repciDcs.repciId, repciDcTuplas.idDC, repciDcTuplas.value1,repciDcTuplas.value2, repciDcs.comment as title, repcis.titulo as rextit from repciDcTuplas,repciDcs,repcis where  repciDCTuplas.idDC = repciDcs.id and repciDcs.OriginalDC is Null ";
		$sql = $sql." and repciDcs.status=0 and repciDcs.repciid=repcis.repciid and repcis.status=1 ";
		$sqlGrupo = "";
		if (count($GruposDeUsuarios)>0){
			$clave = array_search($userid, $GruposDeUsuarios[$x]);
			if ($clave!==false){ // este usuario pertenece a un grupo que comparte el calendario
				$sqlGrupo=$sqlGrupo." and ( ";
				for ($x = 0; $x < count($GruposDeUsuarios); $x++) {
					if ($sqlGrupo!==" and ( ")
						$sqlGrupo = $sqlGrupo." or ";
					$sqlGrupo=$sqlGrupo." repciDcs.fromUser='".$GruposDeUsuarios[$x]."' "; 
				}
				$sqlGrupo=$sqlGrupo." )";
			}
			if ($sqlGrupo!=="")
				$sql=$sql.$sqlGrupo;
			else
				$sql=$sql." and repciDcs.fromUser='$userid' ";// go solo
		}
		if ($start!=="" || $end!==""){
			$sql = $sql." and repciDcTuplas.idDC in (";
			if ($start!==""){
				$subsql = " select repciDcs.id from repciDcs,repciDCTuplas,repcis where repciDcs.id=repciDcTuplas.idDC  and repciDcs.repciid=repcis.repciid and repcis.status=1  and repciDcs.OriginalDC is Null and (repciDcTuplas.value1='".$langtext["FechaCompromiso"]."') and repciDcTuplas.value2>='$start'";
			}
			if ($end!==""){
				if ($start!==""){
					$subsql=$subsql." INTERSECT ";
				}
				$subsql = $subsql." select repciDcs.id from repciDcs,repciDCTuplas,repcis where repciDcs.id=repciDcTuplas.idDC  and repciDcs.repciid=repcis.repciid and repcis.status=1 and repciDcs.OriginalDC is Null and (repciDcTuplas.value1='".$langtext["FechaCompromiso"]."') and repciDcTuplas.value2<='$end'";
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
		$title='';
		$entry='';
		$rextit='';
		while( sqlsrv_fetch( $result )) {
		   $repciId = mb_convert_encoding(sqlsrv_get_field($result, 0), "UTF-8", "HTML-ENTITIES");	   
		   $dummDC=mb_convert_encoding(sqlsrv_get_field($result, 1), "UTF-8", "HTML-ENTITIES");
		   $desc = sqlsrv_get_field($result, 2);
		   $value = mb_convert_encoding(sqlsrv_get_field($result, 3), "UTF-8", "HTML-ENTITIES");
		   $title=mb_convert_encoding(sqlsrv_get_field($result, 4), "UTF-8", "HTML-ENTITIES");
		   $rextit=mb_convert_encoding(sqlsrv_get_field($result, 5), "UTF-8", "HTML-ENTITIES");
		   if ($idDC !== $dummDC && $idDC!==''){
				$entry = $entry."}";
				$orgentry=$entry;
				if (strpos($entry,'".$langtext["FechaVencimiento"].":')){
					$entry = str_replace('".$langtext["FechaVencimiento"].":', '"start":',$entry);
					//echo 'se reemplazo FechaVencimiento\n';
					//echo $entry.',';
					if (strpos($entry,'".$langtext["FechaAviso"].":')){
						$entry=$entry.',';
						$entry=$entry.str_replace('".$langtext["FechaAviso"].":', '"start":',$orgentry);
						if (strpos($entry,'".$langtext["FechaCompromiso"].":')){
							$entry=$entry.',';
							$entry=$entry.str_replace('".$langtext["FechaCompromiso"].":', '"start":',$orgentry);
						}
					}
				}
				else{
					if (strpos($entry,'".$langtext["FechaAviso"].":')){
						$entry=str_replace('".$langtext["FechaAviso"].":', '"start":',$entry);
						if (strpos($entry,'".$langtext["FechaCompromiso"].":')){
							$entry=$entry.',';
							$entry=$entry.str_replace('".$langtext["FechaCompromiso"].":', '"start":',$orgentry);
						}
					}
					else{
						if (strpos($entry,'".$langtext["FechaCompromiso"].":')){
							$entry=str_replace('".$langtext["FechaCompromiso"].":', '"start":',$entry);
						}
					}
				}				
			}
			if (!$first_row){
				$entry = $entry.",";
			}
			
		   if ($idDC !== $dummDC){
				echo $entry;
				$entry = '{"id":"'.$repciId.'", "idDC":"'.$dummDC.'", "title":"'.$rextit.':'.$title.'",';
		   }
		   $entry = $entry.'"'.$desc . '":"'.$value.'"';		   
			$idDC = $dummDC;			
			$first_row=FALSE;			
		}
		$orgentry=$entry;
		if (strpos($entry,'".$langtext["FechaVencimiento"].":')){
			$entry = str_replace('".$langtext["FechaVencimiento"].":', '"start":',$entry);
			if (strpos($entry,'".$langtext["FechaAviso"].":')){
				$entry=$entry.'},'.str_replace('".$langtext["FechaAviso"].":', '"start":',$orgentry);
				if (strpos($entry,'".$langtext["FechaCompromiso"].":')){
					$entry=$entry.'},'.str_replace('".$langtext["FechaCompromiso"].":', '"start":',$orgentry);
				}
			}
		}
		else{
			if (strpos($entry,'".$langtext["FechaAviso"].":')){
				$entry=str_replace('".$langtext["FechaAviso"].":', '"start":',$entry);
				if (strpos($entry,'".$langtext["FechaCompromiso"].":')){
					$entry=$entry.'},'.str_replace('".$langtext["FechaCompromiso"].":', '"start":',$orgentry);
				}
			}
			else{
				if (strpos($entry,'".$langtext["FechaCompromiso"].":')){
					$entry=str_replace('".$langtext["FechaCompromiso"].":', '"start":',$entry);
				}
			}
		}
		echo $entry;		
		echo"}]\n";
	}		
		
// close mysql connection
sqlsrv_free_stmt($result); 
sqlsrv_close($link);
 	
?>