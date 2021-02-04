<?php
 
 //Ejemplo de como se llama desde el web este restfull
 //https://www.tuapoyo.net/dossier2/api/DCs.php/121300
 
 
 
// get the HTTP method, path and body of the request
$method = $_SERVER['REQUEST_METHOD'];
$request = explode('/', trim($_SERVER['PATH_INFO'],'/'));

include 'dbconex.php';

//"Data Source=tcp:s07.everleap.com;Initial Catalog=DB_4666_tuapoyo;User ID=DB_4666_tuapoyo_user;Password=******;Integrated Security=False;"

$connectionInfo = array( "UID"=>$uid,                            
                         "PWD"=>$pwd,                            
                         "Database"=>$databaseName); 
  
/* Connect using SQL Server Authentication. */  
$link = sqlsrv_connect( $serverName, $connectionInfo);  
 
// retrieve the table and key from the path
//$table = preg_replace('/[^a-z0-9_]+/i','',array_shift($request));
$table = "repciDCs, repcis";
$key = filter_var(array_shift($request), FILTER_VALIDATE_INT);


// create SQL based on HTTP method
switch ($method) {
  case 'GET':
      // build the SET part of the SQL command		
		$dumyblank ="''";
		$set ='id,repciDCs.repciId,fromUser,CONVERT(VARCHAR, repciDCs.when_date, 120) as when_date,DCType,repciDCs.longitud,repciDCs.latitud,repciDCs.status,PrevDC,NextDC,filepath,comment,titulo,repcis.grupo,repciDCs.IP,repciDCs.LocationOrigin,SelloImage, OriginalDC,repcis.status as repcistatus, '.$dumyblank.' as path'; // path should be added for back-compatiblity
		$sql = "select ".$set." from " .$table ;
		
		$where = "";
		
		if (is_numeric($key))
			$where=$where. " id=".$key." and repcis.repciid = repcidcs.repciid ";

		if ($where!=="")
			$where=" WHERE ".$where;
		$sql=$sql.$where.";";
		//echo $sql."\n";
		//die();
		break;
  case 'PUT':
      $values = array_map(function ($value) use ($link) {
      if ($value===null) return null;
        return (string)$value;
      },array_values($input)); 
    $sql = "";break;//"update `$table` set $set where id=$key"; break;
  case 'POST':      
    $sql = "";break;//"insert `$table` where id=$key"; break;
  case 'DELETE':
    $sql = "";break;//"delete `$table` where id=$key"; break;
} 

$result= null;

// excecute SQL statement
if ($where!=="")
	$result =  sqlsrv_query($link,$sql);

 
// die if SQL statement failed
if (!$result) {
  http_response_code(404);
  die(sqlsrv_errors());
}
 
// print results, insert id or affected row count
if ($method == 'GET') {
	//header('Cache-Control: no-cache, must-revalidate');
	//header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');

	// headers to tell that result is JSON

	header('Content-type: application/json; Charset=UTF-8');
	if (!sqlsrv_has_rows($result)){
		die(http_response_code(404));
	}
	else {
		$metaData = sqlsrv_field_metadata($result);
		$numFields = sqlsrv_num_fields( $result );
		echo "{";
		while( sqlsrv_fetch( $result )) {
			// Iterate through the fields of each row.
		   for($i = 0; $i < $numFields; $i++) { 
			$content = mb_convert_encoding(sqlsrv_get_field($result, $i), "UTF-8", "HTML-ENTITIES");			
			echo '"'.$metaData[$i]["Name"] . '":"'.$content.'"';
			if ( $i!==($numFields-1)){
				echo ",";
			}					
		   }
		}
		//tuplas
		
		echo ", \"tuplas\":";
		$set ='value1,value2,value3,value4,value5';
		$table='repciDCTuplas';
		
		$sql = "select ".$set." from " .$table ;
		
		$where = "";
		
		if (is_numeric($key))
			$where=$where. " idDC=".$key;

		if ($where!=="")
			$where=" WHERE ".$where;
		$sql=$sql.$where.";";
		
		sqlsrv_free_stmt( $result);
		
		$result= null;

		// excecute SQL statement
		if ($where!=="")
			$result =  sqlsrv_query($link,$sql);

		 
		// die if SQL statement failed
		if (!$result) {
			$content='[]';
		}
		 
		//echo $sql;
		 
		//////////////////
		
		if (!sqlsrv_has_rows($result)){
			$content='[]';
			echo $content;
		}
		else {
			$metaData = sqlsrv_field_metadata($result);
			$numFields = sqlsrv_num_fields( $result );
			$first_row=TRUE;
			echo "[";
			$first_row=TRUE;
			while( sqlsrv_fetch( $result )) {
				// Iterate through the fields of each row.
				if ($first_row){
					echo "{";
					$first_row=false;
				}
				else
					echo ",{";
			   for($i = 0; $i < $numFields; $i++) { 
				$content = mb_convert_encoding(sqlsrv_get_field($result, $i), "UTF-8", "HTML-ENTITIES");			
				echo '"'.$metaData[$i]["Name"] . '":"'.$content.'"';
				if ( $i!==($numFields-1)){
					echo ",";
				}					
			   }
				echo "}";
			}
			echo "]";
		}
		
		
		///////////////////
		
		echo "}\n";
	}
} elseif ($method == 'POST') {
	if ($key!==0 ){	
		header('Cache-Control: no-cache, must-revalidate');
		header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
		// headers to tell that result is JSON
		header('Content-type: application/json');
		$metaData = sqlsrv_field_metadata($result);
		echo file_get_contents('php://input');//mssqli_insert_id($link);
	}
	else {
		die(http_response_code(409));
	}
} elseif ($method == 'PUT'){
    echo 'PUT con payload '.file_get_contents('php://input');//mssqli_insert_id($link);
}
else {
  echo "Deleting DC ".$key ;
}
 
// close mysql connection
sqlsrv_free_stmt( $result); 
sqlsrv_close($link);
?>