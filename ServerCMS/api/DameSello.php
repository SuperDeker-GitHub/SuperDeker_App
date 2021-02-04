<?php

$method = $_SERVER['REQUEST_METHOD'];
$request = explode('/', trim($_SERVER['PATH_INFO'],'/'));
$grupo = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$dctype = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$sello = filter_var(array_shift($request), FILTER_SANITIZE_STRING);

//echo 'Grupo es :'.$grupo.'<br>';
//echo 'DCType es :'.$dctype.'<br>';
//echo 'Sello es :'.$sello.'<br>';

if ($grupo!=''){
	$string = file_get_contents("../grupos/".$grupo.".json");
	$json_a = json_decode($string, true);
}
else{
	echo json_encode("");
	exit;
}
if ($dctype!=''){
	$Dcs = $json_a["logs"][0]["DCs"];
	//echo json_encode($Dcs);
	for ($x=0;$x<=count($Dcs);$x++){
		 if ($Dcs[$x]["Code"]==$dctype){
			 $Sellos = $Dcs[$x]["Sellos"];
			 for ($s=0;$s<count($Sellos);$s++){
		 						
				if ($Sellos[$s]["valor"]==$sello){
					echo json_encode($Sellos[$s]["src"]);						
				}
			 }
		 }
	}
	//echo "cantidad de Dcs =".count($Dcs);
	exit;
}
else{
	echo json_encode("");
	exit;
}

?>
