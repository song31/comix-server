<?php

################################################################################
# Set $parent_path with the full path of the parent directory of 
# the manga directory. 
#
# Combined with $dir_name in index.php, 
# the manga directory's full path will be /volume1/manga.
#
# For example, if your manga directory is /home/comix/content, 
# set $parent_path = "/home/comix" in this file and 
# set $dir_name = "content" in index.php. 
# You also need to change "manga" to "content" in AliasMatch 
# directive in httpd.conf-comix. 
################################################################################
$parent_path = "/volume1";


$is_debug = false;
$source_encoding = "EUC-KR";
$target_encoding = "UTF-8";
$hidden_fullname = array(".", "..", "@eaDir", "Thumbs.db", ".DS_Store");
$hidden_partname = array("__MACOSX");
$image_ext = array("jpg", "gif", "png", "tiff");
$zip_ext = array("zip", "rar");

$allows = array_merge($image_ext, $zip_ext);
ini_set('default_charset', $target_encoding);

$request_uri = $_SERVER['REQUEST_URI'];
$request_path = parse_url($request_uri, PHP_URL_PATH);
$request_path = urldecode($request_path);
debug("request_path: ".$request_path);

$path = $parent_path.$request_path;
debug("path: ".$path);

if (is_dir($path)) {
    list_dir($path);
} else {
    $path_parts = pathinfo($path);
    $ext = strtolower($path_parts['extension']);
    $type = get_content_type($ext);

    if (is_in_zip($path, $ext)) {
        process_file_in_zip($path, $type);
    } else {
        if (in_array($ext, $image_ext)) {
            process_image($path, $type);
        } else if ($ext == "zip") {
            process_zip($path);
        } else if ($ext == "rar") {
            process_rar($path);
        } else {
            return;
        }
    }
}


################################################################################
# Print filenames in the directory
################################################################################
function list_dir($dir_path) {
    debug("list_dir: ". $dir_path);
    if ($handle = opendir($dir_path)) {
        while (false !== ($file = readdir($handle))) {
            if (is_support($file)) {
                echo "$file\n";
            }
        }
        closedir($handle);
    }
    exit;
}

################################################################################
# Return image content
################################################################################
function process_image($file_path, $type) {
    global $is_debug;
    debug("process_image: ". $file_path." type: ".$type);
    if (file_exists($file_path)) {
        $fp = fopen($file_path, 'rb');
        if (!$is_debug) {
            header("Content-Type: ".$type);
            header("Content-Length: ".filesize($file_path));
            fpassthru($fp);
        }
        fclose($fp);
        exit;
    } 
}

################################################################################
# Print filenames in the zip file
################################################################################
function process_zip($file_path) {
    debug("process_zip: ".$file_path);
    $zip_handle = zip_open($file_path) or die("can't open $file_path: $php_errormsg");

    while ($entry = zip_read($zip_handle)) {
        $entry_name = zip_entry_name($entry);
        $entry_name = change_encoding($entry_name);
        debug("entry_name: ".$entry_name);
        if (is_support($entry_name, false)) {
            echo "$entry_name\n";
            debug("supported");
        } else {
            debug("not supported");
        }
    }
    zip_close($zip_handle);
}

################################################################################
# Print filenames in the rar file
# TODO: testing
################################################################################
function process_rar($file_path) {
    debug("process_rar: ".$file_path);
    $arch = RarArchive::open($file_path);
    $entries = $arch->getEntries();

    debug(count($entries));
    for ($i = 0; $i < count($entries); $i++) {
        $entry_name = $entries[$i]->getName();
        debug("entry_name: ".$entry_name);
        if (is_support($entry_name, false)) {
            echo "$entry_name\n";
        }
    }
    $arch->close();
}

################################################################################
# Return image content in the zip file
################################################################################
function process_file_in_zip($file_path, $type) {
    global $path_parts, $is_debug;
    debug("process_file_in_zip: ".$file_path." type: ".$type);

    $zip_file_path = $path_parts['dirname'];
    $image_file_name = $path_parts['basename'];
    if (!end_with($zip_file_path, ".zip")) {
        $zip_file_path = parse_real_path($zip_file_path, ".zip");
    }
    debug("zip_file_path: ".$zip_file_path);
    debug("image_file_name: ".$image_file_name);

    $zip_handle = zip_open($zip_file_path) or die("can't open $zip_file_path: $php_errormsg");
    while ($entry = zip_read($zip_handle)) {
        $entry_name = zip_entry_name($entry);
        $entry_name = change_encoding($entry_name);
        $entry_size = zip_entry_filesize($entry);

        if ($entry_size > 0) {
            if (end_with($entry_name, $image_file_name)) {
                debug("entry_name: ".$entry_name);
                if (zip_entry_open($zip_handle, $entry)) {
                    if (!$is_debug) {
                        header("Content-Type: ".$type);
                        header("Content-Length: ".$entry_size);
                        echo zip_entry_read($entry, $entry_size);
                    }
                }
            }
        }
    }
    zip_close($zip_handle);
}


################################################################################
# Return true if file or directory name is valid.  
# Valid means:
# - File (directory) name should not start with ".".
# - File (directory) name should not in $hidden_fullname 
# - File (directory) name should not contain strings in $hidden_partname 
# - File extension should be in $image_ext or $zip_ext
################################################################################
function is_support($file_name, $is_dir=true) {
    global $hidden_fullname, $hidden_partname, $allows;

    if (start_with($file_name, ".")) {
        return false;
    }

    if (in_array($file_name, $hidden_fullname)) {
        return false;
    } 

    foreach($hidden_partname as $keyword) {
        $ret = strpos($file_name, $keyword);
        if ($ret !== false) {
            return false;
        }
    }
    $ext =  get_file_extension($file_name);
    if ($ext) {
        if (in_array($ext, $allows)) {
            return true;
        } else {
            return false;
        }
    } else {
        if ($is_dir) {
            return true;
        } else {
            return false;
        }
    }
}

################################################################################
# Return true if the file is in a zip file
################################################################################
function is_in_zip($file_path, $ext) {
    $ret = strpos($file_path, ".zip");
    if ($ret == false) {
        return false;
    } else {
        if ($ext == "zip") {
            return false;
        } else {
            return true;
        }
    }
}

################################################################################
# Return content type from file extension
################################################################################
function get_content_type($ext) {
    if ($ext == "jpg") {
        return "image/jpeg";
    } else {
        return "image/".$ext;
    }
}


################################################################################
# Return file extension 
################################################################################
function get_file_extension($file_name) {
    return strtolower(substr(strrchr($file_name,'.'),1));
}

################################################################################
# Return true if string starts with keyword
################################################################################
function start_with($haystack, $needle) {
    return !strncmp($haystack, $needle, strlen($needle));
}

################################################################################
# Return true if string ends with keyword
################################################################################
function end_with($haystack,$needle,$case=true) {
    if($case){return (strcmp(substr($haystack, strlen($haystack) -
        strlen($needle)),$needle)===0);}
        return (strcasecmp(substr($haystack, strlen($haystack) -
        strlen($needle)),$needle)===0);
}

################################################################################
# Cut off the path after extension
################################################################################
function parse_real_path($path, $ext) {
    return substr($path, 0, strpos($path, "$ext")).$ext;
}

################################################################################
# Change string encoding to target_encoding
################################################################################
function change_encoding($name) {
    global $source_encoding, $target_encoding;
    $tmp = iconv($source_encoding, $source_encoding, $name);
    if (strlen($tmp) == strlen($name)) {
        return iconv($source_encoding, $target_encoding, $name);
    } else {
        return $name;
    }
}

################################################################################
# Print debugging message
################################################################################
function debug($str) {
    global $is_debug;
    if ($is_debug) { 
        echo "<i>".$str."</i><br>";
    }
}
?>
