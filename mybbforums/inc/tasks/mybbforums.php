<?php
if (!defined('IN_MYBB')) { die('Direct initialization of this file is not allowed.'); }
require_once MYBB_ROOT.'inc/plugins/mybbforums/lib.php';
function task_mybbforums($task){$settings=mybbforums_settings();$settings=mybbforums_sync($settings);mybbforums_save($settings);return true;}
