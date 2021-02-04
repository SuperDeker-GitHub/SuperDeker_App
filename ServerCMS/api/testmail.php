<?php     
        $email = "bermudez.luis@gmail.com";
        $hash = "f76a89f0cb91bc419542ce9fa43902dc";
        $to      = $email; // Send email to our user
        
        $headers = 'From:noreply@superdeker.com' . "\r\n"; // Set from headers

        ////////////////

        $host = "sm14.internetmailserver.net";

        ini_set('display_errors', 1);
        ini_set('display_startup_errors', 1);
        error_reporting(E_ALL);
        require_once "Mail.php";
        $from = "noreply@superdeker.com";
        $to = $email;
        $subject = 'SuperDeker Signup | Verification'; // Give the email a subject 
        $body = '
        (This will go to the user as an HTML page with image logos and proper formatting)

        Thanks for signing up!
        via admin...
        Your SuperDeker account has been created, you can login with the following nickname after you have activated your account by pressing the url below.
        
        ------------------------
        Nickname: ratanaz
        Password: 12345678 (this will not be sent on the production version, only for testing purposes)
        ------------------------
        
        Please click this link to activate your account:
        http://dossierplus-srv.com/superdeker/api/verify.php/'.$hash.'
        
        '; // Our message above including the link$host = "sm14.internetmailserver.net";
        $username = "admin@dossierplus-srv.com";
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
        echo "Mal Sent </BR>";

        ?>