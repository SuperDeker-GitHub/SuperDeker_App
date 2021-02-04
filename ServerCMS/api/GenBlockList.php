<?php

$method = $_SERVER['REQUEST_METHOD'];

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
		$sql = "select repciDCs.id, repciDCtuplas.value2 as name  from repcis,repcidcs,repciDCTuplas where repcis.repciid = repciDCs.repciId and repcidcs.status = 0 and repciDCTuplas.idDC = repciDCs.id and repciDCs.DCType = 'APPBLOCKLIST' AND repciDCTuplas.value1 = 'WordNotAllowed' and repcis.status = 1 and repcis.grupo = 8540 order by value2";
        //echo $sql;
    break;
  default:
		echo '{"id":"0","msg":"wrong method"}';
		exit;
	break;
}
// excecute SQL statement
$result =  sqlsrv_query($link,$sql);
 
// die if SQL statement failed

if (!$result){
    //echo "No result";
    echo '{"id":"0","msg":"Query without result"}';
    //exit;
}
else{
    if (!sqlsrv_has_rows($result)){
        //echo "No rows" ;
        echo '{"id":"0","msg":"no rows"}';
        //exit;
    }
    else {
        ///////////////////////////////
        $metaData = sqlsrv_field_metadata($result);
        $numFields = sqlsrv_num_fields( $result );
        $filecontent = [];
        while( sqlsrv_fetch( $result )) {           
            $id = mb_convert_encoding(sqlsrv_get_field($result, 0), "UTF-8", "HTML-ENTITIES");	   
            $name=mb_convert_encoding(sqlsrv_get_field($result, 1), "UTF-8", "HTML-ENTITIES");
            $item["id"] = $id;
            $item["value"] = $name;
            $filecontent[] = $item;
        }
        $file = fopen('../appserver/json/blocklist.json','w+');
        fwrite($file, json_encode($filecontent));
        fclose($file);
        echo json_encode($filecontent);//necesario para que retorne algo
       
    }		
}

sqlsrv_free_stmt($result); 
sqlsrv_close($link);
 	
?>
