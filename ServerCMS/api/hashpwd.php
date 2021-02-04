<?php
// See the password_hash() example to see where this came from.

$request = explode('/', trim($_SERVER['PATH_INFO'],'/'));

$password = filter_var(array_shift($request), FILTER_SANITIZE_STRING);


$hashedPWD = password_hash($password, PASSWORD_DEFAULT);

echo $hashedPWD;

exit;

/*$hash = '$2y$07$BCryptRequires22Chrcte/VlQH0piJtjXl.0t1XkA8pw9dMXTpOq';

if (password_verify('rasmuslerdorf', $hash)) {
    echo 'Password is valid!';
} else {
    echo 'Invalid password.';
}*/
?>