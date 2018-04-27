<?php

// php fixconfig.php < config.php

$old = file_get_contents("php://stdin");

$new = preg_replace_callback(
    '|getenv\(\'([^\']*)\'\)|',
    function ($matches) {
        // return __(htmlent_utf8(trim($matches[1])));
        $key = trim($matches[1]);
        $value = getenv($key);
        return "'".$value."'";
    },
    $old
);

echo($new);
