<?php

$usr = htmlspecialchars($_GET["u"]);
$Dc = htmlspecialchars($_GET["d"]);
$search = htmlspecialchars($_GET["s"]);
$Table = htmlspecialchars($_GET["t"]);

$typesearch = htmlspecialchars($_GET["ts"]);

$field = htmlspecialchars($_GET["f"]);

$GRP = htmlspecialchars($_GET["grp"]);

$DcId = htmlspecialchars($_GET["dcid"]);

$RetArray=[];

if ($usr == ""){
	echo "NEG";
	exit;
}
/*
echo "user:".$usr;
echo "<br>";
echo "Dc:".$Dc;
echo "<br>";
echo "search:".$search;
echo "<br>";
echo "Table:".$Table;
echo "<br>";
echo "typesearch:".$typesearch;
echo "<br>";
echo "field:".$field;
echo "<br>";
echo "GRP:".$GRP;
echo "<br>";
echo "DcId:".$DcId;
exit;
*/

include 'dbconex.php';
	
	$top = 100;
	
	if ($Dc==""){	
		if ($typesearch=="like") {
			$SqlComd = "Select top ".$top." * from  ".$Table." where ".$field." like '%".$search."%'";
		}
		else{
			$SqlComd = "Select top ".$top." * from  ".$Table." where ".$field." = '".$search."'";
		}
	}
	else{
		if ($DcId=="") {
			if ($typesearch=="like"){
				$SqlComd = "Select idDC,value1,value2 from repciDCtuplas where iddC in ( Select top 1 repciDcs.id from repciDcs, repciDCTuplas, repcis where repciDcs.DCType='".$Table."' and repciDCTuplas.Value1 = '".$field."' and repciDCTuplas.Value2 like '%".$search."%' and repcidcTuplas.idDC=repciDcs.id and repcis.repciid = repciDcs.repciid  and repciDcs.status >=0 and repcis.status = 1 order by repciDcs.id desc)";
			}
			else{
				$SqlComd = "Select idDC,value1,value2 from repciDCtuplas where iddC in ( Select top 1 repciDcs.id from repciDcs, repciDCTuplas, repcis where repciDcs.DCType='".$Table."' and repciDCTuplas.Value1 = '".$field."' and repciDCTuplas.Value2 = '".$search."' and repcidcTuplas.idDC=repciDcs.id and repcis.repciid = repciDcs.repciid  and repciDcs.status >=0 and repcis.status = 1 order by repciDcs.id desc)";
			}
		}
		else{
			$SqlComd = "Select idDC,value1,value2 from repciDCtuplas where iddC = ".$DcId;		
		}
	}

	
	
	$connectionInfo = array( "UID"=>$uid,                            
                         "PWD"=>$pwd,                            
                         "Database"=>$databaseName); 
  
/* Connect using SQL Server Authentication. */  
	$link = sqlsrv_connect( $serverName, $connectionInfo);  
	
	if ($link){
		$result =  sqlsrv_query($link,$SqlComd);
		if (!$result) {
		  http_response_code(404);
		  die(sqlsrv_errors());
		}
	}
	else{
		http_response_code(404);
		die(sqlsrv_errors());		
	}
	
	if (!sqlsrv_has_rows($result)){
		die(http_response_code(404));
	}
	else {
		header('Content-type: application/json; Charset=UTF-8');
		$metaData = sqlsrv_field_metadata($result);
		$numFields = sqlsrv_num_fields( $result );
		while( sqlsrv_fetch( $result )) {
			// Iterate through the fields of each row.
			if ($Dc==""){
			   for($i = 0; $i < $numFields; $i++) { 
				$content = mb_convert_encoding(sqlsrv_get_field($result, $i), "UTF-8", "HTML-ENTITIES");			
				$name = $metaData[$i]["Name"];
				$retval[$name]=$content;			
			   }
			   $RetArray[]=$retval;
			}
			else{
				$retval["idDC"]=sqlsrv_get_field($result, $i);
				$name = mb_convert_encoding(sqlsrv_get_field($result, 1), "UTF-8", "HTML-ENTITIES");			
				$content = mb_convert_encoding(sqlsrv_get_field($result, 2), "UTF-8", "HTML-ENTITIES");
				if ($retval[$name]){
					if (is_array($retval[$name])){
						$retval[$name][]=$content;
					}
					else{
						$dummy=$retval[$name];
						$retval[$name]=[];
						$retval[$name][]=$dummy;
						$retval[$name][]=$content;
					}
				}
				else
					$retval[$name]=$content;			
			}
		}
	}
	if ($Dc!="")
		$RetArray[]=$retval;
	echo json_encode($RetArray);
	
	sqlsrv_free_stmt( $result); 
	sqlsrv_close($link);	
?>
