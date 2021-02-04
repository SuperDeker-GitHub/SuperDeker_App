<?php

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
        if(!$result){die("Connection Failure in SDApproval");}
        curl_close($curl);
        return $result;
    }
    
    function addBL($params){
        $toktok='666123';
        $Tuple["V1"]="WordNotAllowed";
        
        $Tuple["V2"]=$params[0]["value"];
        
        $Tuplas[]=$Tuple;
        /*$Tuple["V1"]="Comment";
        $Tuple["V2"]='';
        $Tuplas[]=$Tuple;*/
        
        $Head["titulo"]=$params[0]["value"];
        $Head["filename"]="";
        $Head["Comment"]=$params[0]["value"];
        $Head["repciID"]="";
        $Head["user"]=$params[0]["fromUser"]; 
        $Head["DCWebId"]='';
        $Head["PrevDC"]='';
        $Head["NeExtDC"]='';
        $Head["DCType"]='APPBLOCKLIST';
        $Head["when_date"]= date('Y-m-d H:i:s');
        $Head["longitud"]=0;
        $Head["latitud"]=0;
        $Head["IP"]='10.10.10.10';
        $Head["GPSOrg"]='auto';
        $Head["CopyToRexs"]=[]; 
        $Head["grupo"]="8540";
        $Head["notift"]="0";
        $Head["repcitype"]="0";
        $Head["Totales"]=[];
        
        $JsonObj['token']= $toktok;
        $JsonObj['head']= $Head;
        $JsonObj['tuple']= $Tuplas;
       // echo json_encode($JsonObj);
       $get_data = callAPI('POST', 'https://dossierplus-srv.com/superdeker/api/saveDC-v132.php?', json_encode($JsonObj));
       $response = json_decode($get_data, true);
       $errors = $response['response']['errors'];
       $data = $response['response']['data'][0];
    }

    function modBL($params){
        $toktok='666123';
        $Tuple["V1"]="WordNotAllowed";
        
        $Tuple["V2"]=$params[1]["value"];
        
        $Tuplas[]=$Tuple;
        /*$Tuple["V1"]="Comment";
        $Tuple["V2"]='';
        $Tuplas[]=$Tuple;*/
        
        $Head["titulo"]=$params[1]["value"];
        $Head["filename"]="";
        $Head["Comment"]=$params[1]["value"];
        $Head["repciID"]=$params[0]["repciid"];
        $Head["user"]=$params[0]["fromUser"]; 
        $Head["DCWebId"]=$params[0]["dcid"];
        $Head["PrevDC"]='';
        $Head["NeExtDC"]='';
        $Head["DCType"]='APPBLOCKLIST';
        $Head["when_date"]= date('Y-m-d H:i:s');
        $Head["longitud"]=0;
        $Head["latitud"]=0;
        $Head["IP"]='10.10.10.10';
        $Head["GPSOrg"]='auto';
        $Head["CopyToRexs"]=[]; 
        $Head["grupo"]="8540";
        $Head["notift"]="0";
        $Head["repcitype"]="0";
        $Head["Totales"]=[];
        
        $JsonObj['token']= $toktok;
        $JsonObj['head']= $Head;
        $JsonObj['tuple']= $Tuplas;
        //echo json_encode($JsonObj);
       $get_data = callAPI('POST', 'https://dossierplus-srv.com/superdeker/api/saveDC-v132.php?', json_encode($JsonObj));
       $response = json_decode($get_data, true);
       $errors = $response['response']['errors'];
       $data = $response['response']['data'][0];
       
    }


    function delBL($params){
       $toktok='666123';
       $statusBody["rexid"]=$params[0]["repciid"];
       $statusBody["newStatus"]="0";
       $statusBody["when_date"]=date('Y-m-d H:i:s');
       $statusBody["grupo"]="8620"; // Carpetas de approbacion
       $statusBody["longitud"]="0"; 
       $statusBody["latitud"]="0"; 
       $statusBody["fromUser"]=$params[0]["fromUser"];
       $statusBody["LocationOrigin"]="auto";
       $get_data = callAPI('POST', 'https://dossierplus-srv.com/superdeker/api/setrexstatus.php/23423', json_encode($statusBody));
       $response = json_decode($get_data, true);
       $errors = $response['response']['errors'];
       $data = $response['response']['data'][0];
       
    }

function getRepciIdAndDCidofBlockList($word,$link){
   $sql2 = "select repciDCs.id, repciDCs.repciid from repcidcs,repciDCTuplas where repcidcs.status = 0 and repciDCTuplas.idDC = repciDCs.id and repciDCs.DCType = 'APPBLOCKLIST' AND repciDCTuplas.value1 = 'WordNotAllowed' and repciDCTuplas.VALUE2 = '".$word."'";
   $result2 =  sqlsrv_query($link,$sql2);
   $retval = [];
   if ($result2){
       if (sqlsrv_has_rows($result2)){
            $metaData = sqlsrv_field_metadata($result2);
            $numFields = sqlsrv_num_fields( $result2 );
            $idDC='';
            $RepciId ='';
            if ( sqlsrv_fetch( $result2 )) {           
                $idDC = mb_convert_encoding(sqlsrv_get_field($result2, 0), "UTF-8", "HTML-ENTITIES");	   
                $RepciId=mb_convert_encoding(sqlsrv_get_field($result2, 1), "UTF-8", "HTML-ENTITIES");
                $retval["dcid"] = $idDC;
                $retval["repciid"] = $RepciId;
            }
       }	
    }
    
    sqlsrv_free_stmt($result2); 
    return $retval;
}

$method = $_SERVER['REQUEST_METHOD'];
$request = explode('/', trim($_SERVER['PATH_INFO'],'/'));
$repciid = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$ReqAppRepciId = $repciid;

if ($repciid==''){
	header('Cache-Control: no-cache, must-revalidate');
    header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
    // headers to tell that result is JSON
    header('Content-type: application/json');
    echo '{"id":"0","msg":"done"}';
	exit;
}
$fromUser="";
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
		$sql = "select repciDCs.id, repciDCs.DCTYpe, repciDCTuplas.value1,repciDCTuplas.value2, repciDCs.fromUser, repciDcs.repciid from repcidcs,repciDCTuplas where repciDCs.repciId = ".$repciid." and repcidcs.status = 0 and repciDCTuplas.idDC = repciDCs.id order by repciDCs.id";
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
        $DCType='';
        $idDC='';
        $value1 = '';
        $value2 = '';
        //echo '[';
        $operacion = [];
        $registro = [];
        $registro["id"] = "0";
        while( sqlsrv_fetch( $result )) {           
            $idDC = mb_convert_encoding(sqlsrv_get_field($result, 0), "UTF-8", "HTML-ENTITIES");	   
            $DCType=mb_convert_encoding(sqlsrv_get_field($result, 1), "UTF-8", "HTML-ENTITIES");
            $value1=mb_convert_encoding(sqlsrv_get_field($result, 2), "UTF-8", "HTML-ENTITIES");
            $value2=mb_convert_encoding(sqlsrv_get_field($result, 3), "UTF-8", "HTML-ENTITIES");
            $fromUser=mb_convert_encoding(sqlsrv_get_field($result, 4), "UTF-8", "HTML-ENTITIES");
            $repciID2 = mb_convert_encoding(sqlsrv_get_field($result, 5), "UTF-8", "HTML-ENTITIES");
            
            if ($idDC != $registro["id"] && $registro["id"] != "0") {
                //echo json_encode($operacion);
                //echo ',';
                switch ($operacion[0]["oper"]) {
                    case "ADD_2_BL":
                        //echo '{"opr":"agrega","word":"'.$operacion[0]["value"].'","fromUser":"'.$fromUser.'"},';
                        $operacion[0]["repciid"] = ""; // its new
                        addBL($operacion);
                        //echo ",";
                        break;
                    case "MOD_BL":
                        $ids = getRepciIdAndDCidofBlockList($operacion[0]["value"],$link);
                        //echo '{"opr":"modifica","wordorg":"'.$operacion[0]["value"].'","wordnew":"'.$operacion[1]["value"].'","fromUser":"'.$fromUser.'"},';
                        $operacion[0]["dcid"] = $ids["dcid"];
                        $operacion[0]["repciid"] = $ids["repciid"];
                        //echo json_encode($operacion);
                        modBL($operacion);
                    break;
                    case "DEL_BL":
                        //echo '{"opr":"borrar","word":"'.$operacion[0]["value"].'","fromUser":"'.$fromUser.'"},';
                        $ids = getRepciIdAndDCidofBlockList($operacion[0]["value"],$link);
                        //echo '{"opr":"modifica","wordorg":"'.$operacion[0]["value"].'","wordnew":"'.$operacion[1]["value"].'","fromUser":"'.$fromUser.'"},';
                        $operacion[0]["dcid"] = $ids["dcid"];
                        $operacion[0]["repciid"] = $ids["repciid"];
                        delBL($operacion);
                        break;
                }
                $operacion=[];
            }
            /*
            echo '{"iddc":"'.$idDC.'"';
            echo ',"DCType":"'.$DCType.'"';
            echo ',"v1":"'.$value1.'"';
            echo ',"v2":"'.$value2.'"}';
            */
            $registro["id"] = $idDC;
            $registro["oper"] = $DCType;
            $registro["campo"] = $value1;
            $registro["value"] = $value2;
            $registro["fromUser"] = $fromUser;
            $registro["repciid"] = $repciID2;
            //echo json_encode($registro);
            array_push($operacion,$registro);
        }
        //echo json_encode($operacion);
        switch ($operacion[0]["oper"]) {
            case "ADD_2_BL":
                //echo '{"opr":"agrega","word":"'.$operacion[0]["value"].'","fromUser":"'.$fromUser.'"}';
                $operacion[0]["repciid"] = ""; // its new
                addBL($operacion);
                break;
            case "MOD_BL":
                $ids = getRepciIdAndDCidofBlockList($operacion[0]["value"],$link);
                $operacion[0]["dcid"] = $ids["dcid"];
                $operacion[0]["repciid"] = $ids["repciid"];
                //echo json_encode($operacion);
                //echo '{"opr":"modifica","wordorg":"'.$operacion[0]["value"].'","wordnew":"'.$operacion[1]["value"].'","fromUser":"'.$fromUser.'"}';
                modBL($operacion);
                break;
            case "DEL_BL":
                //echo '{"opr":"borrar","word":"'.$operacion[0]["value"].'","fromUser":"'.$fromUser.'"}';
                //echo '{"opr":"borrar","word":"'.$operacion[0]["value"].'","fromUser":"'.$fromUser.'"},';
                $ids = getRepciIdAndDCidofBlockList($operacion[0]["value"],$link);
                //echo '{"opr":"modifica","wordorg":"'.$operacion[0]["value"].'","wordnew":"'.$operacion[1]["value"].'","fromUser":"'.$fromUser.'"},';
                $operacion[0]["dcid"] = $ids["dcid"];
                $operacion[0]["repciid"] = $ids["repciid"];
                delBL($operacion);
                break;
        }
       // echo ']';
        ///////////////////////////////    
       $statusBody["rexid"]=$ReqAppRepciId;//$params[0]["ReqAppRepciId"];
       $statusBody["newStatus"]="2";
       $statusBody["when_date"]=date('Y-m-d H:i:s');
       $statusBody["grupo"]="8620"; // Carpetas de approbacion
       $statusBody["longitud"]="0"; 
       $statusBody["latitud"]="0"; 
       $statusBody["fromUser"]=$fromUser;
       $statusBody["LocationOrigin"]="auto";
       $get_data = callAPI('POST', 'https://dossierplus-srv.com/superdeker/api/setrexstatus.php/23423', json_encode($statusBody));
       $response = json_decode($get_data, true);
       $errors = $response['response']['errors'];
       $data = $response['response']['data'][0];  
       echo '[]';//necesario para que retorne algo
    }		
}

sqlsrv_free_stmt($result); 
sqlsrv_close($link);
 	
?>
