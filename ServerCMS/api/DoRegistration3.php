<?php

function lastId($queryID) {
    sqlsrv_next_result($queryID);
    sqlsrv_fetch($queryID);
    return sqlsrv_get_field($queryID, 0);
}

function intchars($value){
		$Val = utf8_decode($value);
		$Val = iconv('UTF-8', 'ISO-8859-1',$Val);
		return $Val;
}

$method = $_SERVER['REQUEST_METHOD'];
$request = explode('/', trim($_SERVER['PATH_INFO'],'/'));
$nick = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$email = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$pass = filter_var(array_shift($request), FILTER_SANITIZE_STRING);
$dob = filter_var(array_shift($request), FILTER_SANITIZE_STRING);

//echo 'Nick is :'.$nick.'<br>';
//echo 'email es :'.$email.'<br>';
//echo 'pwd es :'.$pass.'<br>';
//echo 'dob es :'.$dob.'<br>';
if ($email==''){
	header('Cache-Control: no-cache, must-revalidate');
    header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
    // headers to tell that result is JSON
    header('Content-type: application/json');
    echo '{"email":"","used":false}';
	exit;
}
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
    $hash = md5( rand(0,1000) );  
    $sqlInsert = "INSERT INTO SDCreds (authby, created,dob,email,pass,userid,verified,hash)  VALUES ('SD', GetDate(), ?, ?, ?, ?, 0,?); SELECT SCOPE_IDENTITY() as last_ins_id";
	$params = array($dob, $email, $pass, intchars($nick),$hash);
	$stmt = sqlsrv_query( $link, $sqlInsert, $params);
    $last_id = 0;
    if($stmt){
        $last_id =lastId($stmt);
        echo '{"id":'.$last_id.',"err":"no"}';
        $to      = $email; // Send email to our user
        $subject = 'SuperDeker Signup | Verification'; // Give the email a subject 
        $message = '
        (This will      go to the user as an HTML page with image logos and proper formatting)
        
        Thanks for signing up!
        Your SuperDeker account has been created, you can login with the following nickname after you have activated your account by pressing the url below.
        
        ------------------------
        Nickname: '.$nick.'
        Password: '.$pass.' (this will not be sent on the production version, only for testing purposes)
        ------------------------
        
        Please click this link to activate your account:
        http://https://4666-28620.el-alt.com/superdeker/api/verify.php?/'.$email.'/'.$hash.'
        
        '; // Our message above including the link
                            
        $headers = 'From:noreply@superdeker.com' . "\r\n"; // Set from headers
        mail($to, $subject, $message, $headers); // Send our email
    }
    else{
        echo '{"id":0,"err":"Cannot register user"}';
	}    
    break;
  default:
		echo json_encode([]);
	break;
}

sqlsrv_free_stmt($stmt); 
sqlsrv_close($link);
 	
?>
