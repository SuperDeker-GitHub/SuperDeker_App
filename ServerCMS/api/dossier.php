<?php
 
 //Ejemplo de como se llama desde el web este restfull
 //https://www.tuapoyo.net/dossierJS/dossier.php/repcis/121300
 
 function getSanityzeBody($rexquery){
	
	$retrexq=$rexquery;
	
	$retrexq->Desc = filter_var($retrexq->Desc,FILTER_SANITIZE_STRING);
        if (($retrexq->Desc==false) or (trim($retrexq->Desc)=='')){
            echo "Desc Fail";
            return null;
        }
	$retrexq->Group = filter_var($retrexq->Group,FILTER_VALIDATE_INT);
	if ($retrexq->Group===false){
            echo "Group Fail";
            return null;
        }
	$retrexq->DocType = filter_var($retrexq->DocType,FILTER_VALIDATE_INT);
        if ($retrexq->DocType===false){
            echo "DocType Fail";
            return null;
        }
	$retrexq->Creator = filter_var($retrexq->Creator,FILTER_SANITIZE_STRING);
        if (($retrexq->Creator===false) or (trim($retrexq->Creator)==='')){
            echo "Creator Fail";
            return null; 
        }
	$retrexq->Executor = filter_var($retrexq->Executor,FILTER_SANITIZE_STRING);
        if (($retrexq->Executor===false) or (trim($retrexq->Executor)==='')){
            echo "Executor Fail";
            return null;
        }
		$retrexq->RexId = filter_var($retrexq->RexId,FILTER_VALIDATE_INT);
		if ($retrexq->RexId===false){
			$retrexq->RexId='NULL';
		}
        if ($retrexq->Longitud===0 or $retrexq->Latitud===0 ){
            echo "Location Required";
            return null;
        }
        if ($retrexq->Longitud===0 ){
            echo "Longitud Required";
            return null;
        }
        if ($retrexq->Latitud===0 ){
            echo "Latitud Required";
            return null;
        }
        $retrexq->Longitud = filter_var($retrexq->Longitud,FILTER_VALIDATE_FLOAT);
        if ($retrexq->Longitud===false){
            echo "Longitud Fail";
            return null;
        }            
        $retrexq->Latitud = filter_var($retrexq->Latitud,FILTER_VALIDATE_FLOAT);
        if ($retrexq->Latitud===false){
            echo "Latitud Fail";
            return null;
        }            
        $regexp = "/\d{8}T\d{6}/"; // regular exp for YYYYMMDDTHHMMSS
        if (!filter_var($retrexq->ShowDate,FILTER_VALIDATE_REGEXP,array("options" => array("regexp" => $regexp)))){
            echo "ShowDate Fail";
            return null;
        }
        else{
                $aammdd = substr($retrexq->ShowDate, 0, 8 );
                $hora = substr($retrexq->ShowDate, 9, 2 );
                $min = substr($retrexq->ShowDate, 11, 2 );
                $sec = substr($retrexq->ShowDate, 13, 2 );
                $s = $aammdd.' '.$hora.':'.$min.':'.$sec;
                //$date = strtotime($s);
                $retrexq->ShowDate = $s;
        }
        foreach ($retrexq->DataClips as $rexDC){
            $rexDC->DcType=filter_var($rexDC->DcType,FILTER_SANITIZE_STRING);
            if ($rexDC->DcType===false){
                echo "DcType Fail";
                return null;
            }  
            $rexDC->Comment=filter_var($rexDC->Comment,FILTER_SANITIZE_STRING);
            if ($rexDC->Comment===false){
                echo "Comment Fail";
                return null;
            }
            foreach ($rexDC->DcStructure as $DCTuple){
                $DCTuple->Label=filter_var($DCTuple->Label,FILTER_SANITIZE_STRING);
                if ($DCTuple->Label===false){
                    echo "Label Fail";
                    return null;
                }
                $DCTuple->Value=filter_var($DCTuple->Value,FILTER_SANITIZE_STRING);
                if ($DCTuple->Value===false){
                    echo "Value Fail";
                    return null;
                }
            }            
        }            
    echo $retrexq;
	return $retrexq;
}
 
// get the HTTP method, path and body of the request
$method = $_SERVER['REQUEST_METHOD'];
$request = explode('/', trim($_SERVER['PATH_INFO'],'/'));
//$input = json_decode(file_get_contents('php://input'));
//$RexId = filter_var($_GET['id'], FILTER_SANITIZE_STRING);

// connect to the mssql database

//$serverName = "sql2k804.discountasp.net"; 
//$uid = "SQL2008R2_768156_tuapoyo_user";   
//$pwd = "5592454";  
//$databaseName = "SQL2008R2_768156_tuapoyo"; 


include 'dbconex.php';


//"Data Source=tcp:s07.everleap.com;Initial Catalog=DB_4666_tuapoyo;User ID=DB_4666_tuapoyo_user;Password=******;Integrated Security=False;"


$connectionInfo = array( "UID"=>$uid,                            
                         "PWD"=>$pwd,                            
                         "Database"=>$databaseName);
  
/* Connect using SQL Server Authentication. */  
$link = sqlsrv_connect( $serverName, $connectionInfo);  
 
// retrieve the table and key from the path
//$table = preg_replace('/[^a-z0-9_]+/i','',array_shift($request));
$table = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$key = filter_var(array_shift($request), FILTER_SANITIZE_STRING);

switch ($table) {
    case "repcis":
        break;
	case "DC":
		break;
    default:
		http_response_code(501);
		exit(501);
}

// create SQL based on HTTP method
switch ($method) {
  case 'GET':
      // build the SET part of the SQL command
	  	
		
		$set = 'repciId,creator,titulo, CONVERT(VARCHAR, when_date, 120) as when_date,grupo,longitud,latitud,repcitype,NotificationType AS notift, repcis.status as status ,  NULL as picfiles,CONVERT(VARCHAR(2800),(Select SUBSTRING((SELECT \',\' +  filepath AS \'text()\' FROM repciDcs where repcis.repciid = repciDcs.repciid and filepath <> \'\' and status >= 0 FOR XML PATH(\'\')), 2 , 9999)),120) as Images, CONVERT(text, (Select SUBSTRING((SELECT \',\' + \'{"id":\'+ Convert(VARCHAR(20),repciDcs.id,120) + \' ,"text":"\' + (CASE when repciDcs.DCType=\'\' THEN comment ELSE repciDcs.DCType + \' \' + ISNULL(repciDcs.comment,\'\')  END)+ \'" ,"DCType":"\' + repciDcs.DCType + \'"}\'  AS \'text()\' FROM repciDcs where repciDcs.status >= 0 and repcis.repciid = repciDcs.repciid  FOR XML PATH(\'\')), 2 , 9999)),120) as Dcs ';

		
		$sql = "select ".$set." from repcis" ;
		
		$where = "";
		
		if ($table=="repcis"){		
			if (is_numeric($key))
				$where=$where. " repciId=".$key;
			else
				if (strlen($key)!==0)
					$where=$where. " creator='".$key."'";
				else 
				if ($creator!=="")
					$where=$where. "  creator='".$creator."'";
		}
		else { //Dcs -- repciDcs
			if (is_numeric($key))
				$where=$where. " repciId= (select repciId from repciDCs where id=".$key.")";
			else{
				http_response_code(501);
				exit(501);
			}
		}
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
// excecute SQL statement
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
		echo "[\n";
		$first_row=TRUE;
		$grupo='';			
		while( sqlsrv_fetch( $result )) {
			if (!$first_row){
				echo",";
			}
			//echo"\t{\n";
			echo"{";
		   // Iterate through the fields of each row.
		   for($i = 0; $i < $numFields; $i++) { 
			//echo "\t\t'".$metaData[$i]["Name"] . "':'";
			$content = mb_convert_encoding(sqlsrv_get_field($result, $i), "UTF-8", "HTML-ENTITIES");
			if ($i==4){
				$grupo=$content;
			}
				
			if ($metaData[$i]["Name"]==='picfiles'){
				if ($content===''){
					$content = 'default'.$grupo.'.jpg'; // 4 es grupo
				}
			}


			if ($i==($numFields-1)){
				echo '"'.$metaData[$i]["Name"] . '":['.$content.']';		
			}
			else{
				if ($i==($numFields-2)){
					echo '"'.$metaData[$i]["Name"] . '":["';
					echo str_replace(',','","',$content).'"]';			
				}
				else{
					if ($i==($numFields-3)){
						echo '"'.$metaData[$i]["Name"] . '":["';
						echo str_replace(',','","',$content).'"]';			
					}
					else{
						
						echo '"'.$metaData[$i]["Name"] . '":"';
						echo $content.'"';
					}
					//echo sqlsrv_get_field($result, $i).'"';
				}
			}
			if ($i==($numFields-1))
				echo "\n";
			else
				echo ",\n";
			
		   }
		   //if ($first_row){
				echo"}\n";
			//}
			$first_row=FALSE;			
		}
		//echo"\t}\n";
		echo"]\n";
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
  echo "Deleting rex ".$key ;
}
 
// close mysql connection
sqlsrv_free_stmt( $result); 
sqlsrv_close($link);
?>