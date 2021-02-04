<?php
 $hayrecibidos=false;
 try{
	$ip = gethostbyname('demosaime.ddns.net');
	$conexion = mysql_connect ("$ip","root","") or die ("Error: El servidor no puede conectar con la base de datos");
	mysql_select_db("demosaime",$conexion);

	$result=mysql_query("select estado,cedula from demo where estado='recibido'");

	if ($result){
		echo("<BR>");
		while ($fila = mysql_fetch_assoc($result)) {
			echo $fila['cedula']."-";
			echo $fila['estado'].">";
			$smslink='http://www.sistema.massivamovil.com/webservices/SendSms?usuario=sms@sagcit.com&clave=123&telefonos=584122255584&texto=Estimado%20portador%20de%20la%20cedula%20'.$fila['cedula'].',%20su%20pasaporte%20esta%20en%20la%20oficina%20que%20solicito,%20le%20pedimos%20por%20favor%20que%20se%20dirija%20rapidamente%20a%20retirarlo'; 
			$contents = file_get_contents($smslink);	
			echo $contents."<BR>";
			$hayrecibidos=true;
		}
		mysql_free_result($result);
		
	}
	else{
		echo("Error en select ");
	}
}
catch(Exception $e) {
  echo 'Message: ' .$e->getMessage();
}


if ($hayrecibidos){
	// establecer una conexión básica
	$ftp_server = 'demosaime.ddns.net';
	$conn_id = ftp_connect($ftp_server); 

	// iniciar una sesión con nombre de usuario y contraseña
	$ftp_user_name='demosaimeftp';
	$ftp_user_pass='demosaimeclv';
	$login_result = ftp_login($conn_id, $ftp_user_name, $ftp_user_pass); 

	// verificar la conexión
	if ((!$conn_id) || (!$login_result)) {  
		echo "¡La conexion FTP ha fallado!";
		echo "Se intento conectar al $ftp_server por el usuario $ftp_user_name"; 
		exit; 
	} else {
		echo "Conexion a $ftp_server realizada con exito, por el usuario $ftp_user_name";
	}

	$destination_file='5535775.call';
	$source_file='5592454.call';
	// subir un archivo
	$upload = ftp_put($conn_id, $destination_file, $source_file, FTP_ASCII);  

	// comprobar el estado de la subida
	if (!$upload) {  
		echo "¡La subida FTP ha fallado!";
	} else {
		echo "Subida de $source_file a $ftp_server como $destination_file";
	}

	// cerrar la conexión ftp 
	ftp_close($conn_id);
}
else{
	echo 'No hay pasaportes en estado recibido';
}
exit;

 
 ?>