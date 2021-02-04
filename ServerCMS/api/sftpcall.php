<?php

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

exit;

include 'Net/SFTP.php';

define('NET_SFTP_LOGGING', NET_SFTP_LOG_COMPLEX);


$sftp = new Net_SFTP('sftp://demosaime.ddns.net',123);
if (!$sftp->login('vmartinez', 'azul1111')) {
	exit('=>Login Failed');
}

$sftp->chdir('/var/spool/asterisk/outgoing');

// puts an x-byte file named filename.remote on the SFTP server,
// where x is the size of filename.local
$sftp->put('5592454.call', '5592454.call', NET_SFTP_LOCAL_FILE);

echo '<br>FIN<br>';

echo $sftp->getSFTPLog();

?>