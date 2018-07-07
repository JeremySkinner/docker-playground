#!/usr/bin/env php
<?php
$restart = TRUE;

if (isset($argv[1]) && $argv[1] == '--no-restart') {
  $restart = FALSE;
}
$dirs = array_filter(glob(__DIR__ . '/../*'), 'is_dir');

$template = file_get_contents(__DIR__ . '/apache-config-template.conf');

$output = '';

foreach($dirs as $dir) {
  $segments = explode("/", $dir);
  $hostname = end($segments) . ".localhost";

  if (file_exists("$dir/web")) {
    $dir = "$dir/web";
  }

  $dir = realpath($dir);

  $placeholders = ['{DIR}' => $dir, '{HOST}' => $hostname];
  $vhost = strtr($template, $placeholders);

  print("Adding host: $hostname -> $dir\n");
  $output .= "$vhost\n\n";
}

file_put_contents("/etc/apache2/sites-enabled/000-default.conf", $output);

if ($restart) {
  shell_exec("service apache2 restart");
}