<html>
<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
require_once "Mail.php";
$from = "ratanaz@ratpack.com";
$to = "bermudez.luis@gmail.com";
$subject = "Mail.php test email";
$body = "Test email sent using Mail.php.";
$host = "sm14.internetmailserver.net";
$username = "admin@tuapoyo.net";
$password = "Melocoton2413?";
$headers = array ('From' => $from,
  'To' => $to,
  'Subject' => $subject);
$smtp = Mail::factory('smtp',
  array ('host' => $host,
  'auth' => true,
  'username' => $username,
  'password' => $password));
$mail = $smtp->send($to, $headers, $body);
echo "Mail.php test</BR>";
?>
</html>
