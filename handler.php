<?php

################################################################################
# Set $parent_path with the full path of the parent directory of 
# the manga directory. 
#
# Combined with $dir_name in index.php, 
# the manga directory's full path will be /volume1/manga.
#
# For example, if your manga directory is /home/comix/content,
# set $parent_path = "/home/comix" in handler.php,
# set $dir_name = "content" in index.php, and
# add /home/comix/content to open_base_dir in user-setting.ini.
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
    } else if(is_in_rar($path,$ext)) {
         process_file_in_rar($path, $type);
     }else {
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

    if (end_with($file_path, "/")) {
        $file_path = substr($file_path, 0, -1);
        debug("process_zip: ".$file_path);
    }

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
	if (end_with($file_path, "/")) {
        $file_path = substr($file_path, 0, -1);
        debug("process_rar: ".$file_path);
    }

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
	$subfolder_path="";
    $image_file_name = $path_parts['basename'];
    if (!end_with($zip_file_path, ".zip")){ 
        $zip_file_path = parse_real_path($zip_file_path, ".zip");
        $subfolder_path = str_replace($zip_file_path."/","",$path_parts['dirname'])."/";
    }
    debug("zip_file_path:".$zip_file_path.", subfolder_path:".$subfolder_path.", image_file_name:".$image_file_name);
    debug($subfolder_path.$image_file_name);
	$zip = new ZipArchive;
    if($zip->open($zip_file_path)==TRUE)echo $zip->getFromName(iconv("UTF-8","EUC-KR",  $subfolder_path.$image_file_name));
    zip_close($zip_handle);
}

################################################################################
# Return image content in the rar file
################################################################################
function process_file_in_rar($file_path, $type) {
    global $path_parts, $is_debug;
    debug("process_file_in_rar: ".$file_path." type: ".$type);
    $rar_file_path = $path_parts['dirname'];
    $subfolder_path="";
    $image_file_name = $path_parts['basename'];
    if (!end_with($rar_file_path, ".rar")) {
        $rar_file_path = parse_real_path($rar_file_path, ".rar");
        $subfolder_path = str_replace($rar_file_path."/","",$path_parts['dirname'])."/";
    }
    debug("rar_file_path: ".$rar_file_path."subfolder_path:".$subfolder_path.", image_file_name: ".$image_file_name);
    debug("file path :".$subfolder_path.$image_file_name);
    $rar_handle = RarArchive::open($rar_file_path);
    $entry = rar_entry_get($rar_handle, $subfolder_path.$image_file_name);
    $fp = $entry->getStream();
    rar_close($rar_handle);
    while (!feof($fp)) {
        $buff = fread($fp, 8192);
        if ($buff !== false) echo $buff;
        else break;
    }
    fclose($fp);
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
# Return true if the file is in a rar file
################################################################################
function is_in_rar($file_path, $ext) {
    $ret = strpos($file_path, ".rar");
    if ($ret == false) {
        return false;
    } else {
        if ($ext == "rar") {
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
    return substr($path, 0, strrpos($path, "$ext")).$ext;
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
