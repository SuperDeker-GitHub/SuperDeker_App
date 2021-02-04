<?php
// correr dentro de la transaccion cualquier registro o verificacion en la base de datos
function precheck($PayLoad,$Conn){	
	switch ($PayLoad->head->DCType) {
		case 'UsuarioDossier':
			$usuario='';
			$name='';
			$pwd='';
			$email='';
			$status='1';
			foreach ($PayLoad->tuple as $tup){
				switch ($tup->V1){
					case 'UsuarioDossier':
						$usuario = filter_var($tup->V2,FILTER_SANITIZE_STRING);
						break;
					case 'Nombre_Usuario':
						$nombre = filter_var($tup->V2,FILTER_SANITIZE_STRING);
						break;
					case 'Cedula_Usuario':
						$pwd = filter_var($tup->V2,FILTER_SANITIZE_STRING);
						$pwd=password_hash($pwd, PASSWORD_DEFAULT);
						break;
					case 'Email_Usuario':
						$email = filter_var($tup->V2,FILTER_SANITIZE_STRING);
						break;
				}
			}
			//$PayLoad->head->Comment='usuario:'.$usuario.', nombre:'.$nombre.', pwd:'.$pwd.', email:'.$email;
			//$newtup->V1='SQL_Command';
			//$newtup->V2="Insert into DossierCreds (userid,pwd,name,email,status,Incorporado) values ('".$usuario."','".$pwd."','".$nombre."','".$email."','1',GETDATE())";
			//array_push($PayLoad->tuple,$newtup);
			if ($PayLoad->head->DCWebId==''){
				$sqlprechek="Insert into DossierCreds (userid,pwd,name,email,status,Incorporado) values (?,?,?,?,'1',GETDATE())";
				$paramsprecheck = array( $usuario, $pwd, $nombre,$email);
			}
			else{
				$sqlprechek="update DossierCreds set name=?,pwd=?,email=? where userid=? ";
				$paramsprecheck = array( $nombre, $pwd, $email,$usuario);
			}
			$stmtprecheck = sqlsrv_query( $Conn, $sqlprechek, $paramsprecheck);
			if (!$stmtprecheck){
				$errMsg='';
				if( ($errors = sqlsrv_errors() ) != null) {
					foreach( $errors as $error ) {
						$errMsg= "SQLSTATE: ".$error[ 'SQLSTATE']."\n";
						$errMsg .= "code: ".$error[ 'code']."\n";
						$errMsg.= "message: ".$error[ 'message']."\n";
					}
				}
				sqlsrv_rollback( $Conn );
				if ($PayLoad->head->DCWebId=='')
					echo "No se pudo registrar Crear Usuario, Error: ".$errMsg."\n";
				else
					echo "No se pudo actualizar el Usuario, Error: ".$errMsg."\n";
				die(sqlsrv_errors());
				exit;
			}
			break;
		case 'PerfilUsuario':
			$grupo='';
			$usuario='';
			$perfil='';
			foreach ($PayLoad->tuple as $tup){
				switch ($tup->V1){
					case 'UsuarioDossier':
						$usuario = filter_var($tup->V2,FILTER_SANITIZE_STRING);
						break;
					case 'Grupo':
						$todo_grupo = filter_var($tup->V2,FILTER_SANITIZE_STRING);
						$arr_grupo = explode('-',$todo_grupo);
						$grupo = $arr_grupo[1];
						break;
					case 'Perfil':
						$perfil = filter_var($tup->V2,FILTER_SANITIZE_STRING);
						break;
				}
			}
			//$PayLoad->head->Comment='grupo:'.$grupo.', usuario:'.$usuario.', perfil:'.$perfil;
			//$newtup->V1='SQL_Command';
			//$newtup->V2="Insert into usuariosgrupo (grupo,userid,desde,perfil) values (".$grupo.",'".$usuario."',GETDATE(),'".$perfil."')";
			//array_push($PayLoad->tuple,$newtup);
			if ($PayLoad->head->DCWebId==''){
				$sqlprechek="Insert into usuariosgrupo (grupo,userid,desde,perfil) values (?,?,GETDATE(),?)";
				$paramsprecheck = array( $grupo,$usuario, $perfil);
			}
			else{
				sqlsrv_rollback( $Conn );
				echo "No se pudo actualizar el perfil de un usuario, anulalo con un sello y crea el nuevo perfil"."\n";
				exit;
			}
			$stmtprecheck = sqlsrv_query( $Conn, $sqlprechek, $paramsprecheck);
			if (!$stmtprecheck){
				$errMsg='';
				if( ($errors = sqlsrv_errors() ) != null) {
					foreach( $errors as $error ) {
						$errMsg= "SQLSTATE: ".$error[ 'SQLSTATE']."\n";
						$errMsg .= "code: ".$error[ 'code']."\n";
						$errMsg.= "message: ".$error[ 'message']."\n";
					}
				}
				sqlsrv_rollback( $Conn );
				if ($PayLoad->head->DCWebId=='')
					echo "No se pudo registrar el perfil del usuario, Error: ".$errMsg."\n";
				else
					echo "No se pudo actualizar el perfil del uUsuario, Error: ".$errMsg."\n";
				die(sqlsrv_errors());
				exit;
			}		
			break;
	}
	return $PayLoad;
}
// cualquier tarea propia de la solucion como grabar o verificar dentro de la transaccion.
function postcheck($PayLoad,$Conn){
	switch ($PayLoad->head->DCType) {
		case 'UsuarioDossier':
			$usuario='';
			
			foreach ($PayLoad->tuple as $tup){
				switch ($tup->V1){
					case 'UsuarioDossier':
						$usuario = filter_var($tup->V2,FILTER_SANITIZE_STRING);
						break;
				}
			}
			$filename=filter_var($PayLoad->head->filename,FILTER_SANITIZE_STRING);
			if ($filename !=''){
				$archpicado = explode('.',$filename);
				$ext = $archpicado[1];
				copy('../DCImages/'.$filename,'../aicons/user-'.$usuario.'.'.$ext);				
			}			
			break;
	}
}

function SelloPrecheck($PayLoad,$Conn){
	switch (filter_var($PayLoad->dctype,FILTER_SANITIZE_STRING)) {
		case 'PerfilUsuario':
			if (filter_var($PayLoad->newStatus,FILTER_VALIDATE_INT)<0){ //se debe considerar borrado
				$dcid=filter_var($PayLoad->dcid,FILTER_VALIDATE_INT);
				if ($dcid!=0){
					$sqlprecheck = "delete from usuariosgrupo ";
					$sqlprecheck .="where     userid=(select value2  from repciDCTuplas where idDC=".$dcid." and value1='UsuarioDossier') ";
					$sqlprecheck .="      and grupo= (select reverse(Left(reverse(value2),CHARINDEX('-',reverse(value2))-1)) from repciDCTuplas where idDC=".$dcid." and value1='Grupo') ";
					$sqlprecheck .="      and perfil=(select value2  from repciDCTuplas where idDC=".$dcid." and value1='Perfil')";
					$stmtprecheck = sqlsrv_query( $Conn, $sqlprecheck);
					if (!$stmtprecheck){
						$errMsg='';
						if( ($errors = sqlsrv_errors() ) != null) {
							foreach( $errors as $error ) {
								$errMsg= "SQLSTATE: ".$error[ 'SQLSTATE']."\n";
								$errMsg .= "code: ".$error[ 'code']."\n";
								$errMsg.= "message: ".$error[ 'message']."\n";
							}
						}
						sqlsrv_rollback( $Conn );
						echo "No se pudo eliminar el perfil del Usuario, Error: ".$errMsg."\n";
						die(sqlsrv_errors());
						exit;
					}
				}
			}			
		break;
	}
	return $PayLoad;
}

function CambioStatusPrecheck($PayLoad,$Conn){
	switch (filter_var($PayLoad->grupo,FILTER_SANITIZE_STRING)) {
		case '190'://usuarios de dossier
			if ($PayLoad->newStatus=='0'){ //se debe considerar borrado
				$rexid=filter_var($PayLoad->rexid,FILTER_VALIDATE_INT);
				if ($rexid!=0){
					$sqlprecheck = "delete from DossierCreds ";
					$sqlprecheck .="where userid=(select value2  from repciDCTuplas where idDC=(select id from repcidcs where repciid=".$rexid." and dctype ='UsuarioDossier' and status=0) and value1='UsuarioDossier')";
					$stmtprecheck = sqlsrv_query( $Conn, $sqlprecheck);
					if (!$stmtprecheck){
						$errMsg='';
						if( ($errors = sqlsrv_errors() ) != null) {
							foreach( $errors as $error ) {
								$errMsg= "SQLSTATE: ".$error[ 'SQLSTATE']."\n";
								$errMsg .= "code: ".$error[ 'code']."\n";
								$errMsg.= "message: ".$error[ 'message']."\n";
							}
						}
						sqlsrv_rollback( $Conn );
						echo "No se pudo eliminar el perfil del Usuario, Error: ".$errMsg."\n";
						die(sqlsrv_errors());
						exit;
					}
				}
			}
			if ($PayLoad->newStatus=='1'){ //se debe considerar que se esta reactivando el usuario
				$rexid=filter_var($PayLoad->rexid,FILTER_VALIDATE_INT);
				if ($rexid!=0){
					$sqlNewUser= "Insert into DossierCreds (userid,pwd,name,email,status,Incorporado) values";
					$sqlNewUser.= "( ( select value2 from repcidctuplas,repcidcs where repciid=".$rexid." and dctype='UsuarioDossier' and status=0 and value1='UsuarioDossier' and idDC = repcidcs.id),";
					$sqlNewUser.= "( select value2 from repcidctuplas,repcidcs where repciid=".$rexid." and dctype='UsuarioDossier' and status=0 and value1='Cedula_Usuario' and idDC = repcidcs.id),";
					$sqlNewUser.= "( select value2 from repcidctuplas,repcidcs where repciid=".$rexid." and dctype='UsuarioDossier' and status=0 and value1='Nombre_Usuario' and idDC = repcidcs.id),";
					$sqlNewUser.= "( select value2 from repcidctuplas,repcidcs where repciid=".$rexid." and dctype='UsuarioDossier' and status=0 and value1='Email_Usuario' and idDC = repcidcs.id),'1',GETDATE())";
					
					$stmtprecheck = sqlsrv_query( $Conn, $sqlNewUser);
					if (!$stmtprecheck){
						$errMsg='';
						if( ($errors = sqlsrv_errors() ) != null) {
							foreach( $errors as $error ) {
								$errMsg= "SQLSTATE: ".$error[ 'SQLSTATE']."\n";
								$errMsg .= "code: ".$error[ 'code']."\n";
								$errMsg.= "message: ".$error[ 'message']."\n";
							}
						}
						sqlsrv_rollback( $Conn );
						echo "No se pudo eliminar el perfil del Usuario, Error: ".$errMsg."\n";
						die(sqlsrv_errors());
						exit;
					}
				}
			}			
		break;
	}
	return $PayLoad;
}


?>