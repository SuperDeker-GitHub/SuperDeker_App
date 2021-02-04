<?php

$request = explode('/', trim($_SERVER['PATH_INFO'],'/'));

$Operadora = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$Celular = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$Status = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$Cedula = filter_var(array_shift($request), FILTER_SANITIZE_STRING);

echo 'Prueba de Robot 2 <br>';

echo "Cedula=$Cedula, Operadora=$Operadora, Celular = $Celular y Status=$Status\n";

if ($cedula===""){
	echo ("No cedula");
	exit;
}

if ($status===""){
	echo ("No status");
	exit;
}
$ip = gethostbyname('demosaime.ddns.net');
//$conexion = mysql_connect ("$ip","root","") or die ("Error: El servidor no puede conectar con la base de datos");
$conexion = mysql_connect ("$ip","demosaimedb","demosaimedbclv") or die ("Error: El servidor no puede conectar con la base de datos");
mysql_select_db("demosaime",$conexion);

//$result=mysql_query("delete from demo");
//exit;


$result=mysql_query("select * from demo where cedula='".$Cedula."'");

if ($result){
	if ($fila = mysql_fetch_assoc($result)) {
		echo("<BR>update demo set estado='".$Status."' where cedula=".$Cedula."\n");
		$update=mysql_query("update demo set estado='".$Status."' where cedula=".$Cedula);
	}
	else{
		echo("<BR>insert into demo (estado,cedula) values ('".$Status."',".$Cedula.")\n");
		$insert=mysql_query("insert into demo (estado,cedula) values ('".$Status."', ".$Cedula.")");
	}
}
else{
	echo("Error en select * from demo where cedula='".$Cedula."'");
}


mysql_free_result($result);

$result=mysql_query("select * from demo");
echo("<BR>");
while ($fila = mysql_fetch_assoc($result)) {
    echo $fila['cedula']."-";
    echo $fila['estado']."<BR>";
}
mysql_free_result($result);


mysql_free_result($update);

mysql_free_result($insert);

//$conn_string = 'host=localhost port=5432 dbname=semcel_semcel user=semcel password=A|s@iQB( connect_timeout=5';
//$dbconn = pg_connect($conn_string);

exit;

$myPDO = new PDO('pgsql:host=localhost; dbname=semcel_semcel', 'semcel', 'A|s@iQB(');

if (!$myPDO) {
  echo "Ocurrió un error en pg_connect";
  exit;
}
else{
	  echo "pg_connect OK";
}

//$result = pg_query($dbconn, "SELECT idmensaje,asunto from mensaje limit 10");

$result = $myPDO->query("SELECT * from mensaje limit 10");
if (!$result) {
  echo "Ocurrió un error en query.\n";
  exit;
}
else{
	  echo "pg_query OK";
}

foreach ($myPDO->query("SELECT * from mensaje limit 5") as $row) {
	echo "Author: $row[0]  E-mail: $row[1]";
	echo "<br />\n";
}
//while ($row = pg_fetch_row($result)) {
 // echo "idmensaje: $row[0]  asunto: $row[1]";
 // echo "<br />\n";
//}

//exit;

$now=date("Y/m/d H:i:s");
$mensajeEnviar="Mensaje del SAIME, ".$Status ;

$qq = "INSERT INTO mensaje (idcliente,fecharecibidovacorp,asunto,costototalmensaje,idstatus,tipomensaje,fechaaenviar,servicio)
					VALUES 
					(102,'$now','".trim($mensajeEnviar)."',0,1,1,'$now',0)";
					
echo $qq;



$myPDO->query($qq);

			$headerId = $myPDO->lastInsertId('mensaje_idmensaje_seq');
			
			echo "lastId:-$headerId-";

			$myPDO->query("INSERT INTO mensajedetalle
					(
						idmensaje
						,operadora
						,celular
						,idstatus
						,iddirectorio
					)
					VALUES
					(
						$headerId,
						$Operadora,
						$Celular,
						1,
						0
					)
				");





?>