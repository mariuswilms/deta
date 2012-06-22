#
# deta
#
# Copyright (c) 2011-2012 David Persson
#
# Distributed under the terms of the MIT License.
# Redistributions of files must retain the above copyright notice.
#
# @COPYRIGHT 2011-2012 David Persson <nperson@gmx.de>
# @LICENSE   http://www.opensource.org/licenses/mit-license.php The MIT License
# @LINK      http://github.com/davidpersson/deta
#

msgok "Module %s loaded." "sys"

# @FUNCTION: sys_check_command
# @USAGE: [command]
# @DESCRIPTION:
# Checks if the given command is callable.
sys_check_command() {
	which $1 &> /dev/null
	if [[ $? == 0 ]]; then
		msgok "Command %s at %s." $1 $(which $1)
	else
		msgfail "Command %s not found." $1
	fi
}

# @FUNCTION: sys_check_command_return
# @USAGE: [command (with args)]
# @DESCRIPTION:
# Checks if the give command has a return code equal 0.
sys_check_command_return() {
	$@ &> /dev/null
	if [[ $? == 0 ]]; then
		msgok "Command %s returned %s." $1 $?
	else
		msgfail "Command %s returned %s." $1 $?
	fi
}

# @FUNCTION: sys_check_service
# @USAGE: [service]
# @DESCRIPTION:
# Checks if a given service status is OK. Works only with existing init
# scripts which must be located within /etc/init.d./[service]
sys_check_service() {
	if [[ -d /etc/init.d ]]; then
		/etc/init.d/$1 status > /dev/null
		if [[ $? == 0 ]]; then
			msgok "Service %s running." $1
		else
			msgfail "Service %s not running?" "fail"
		fi
	else
		msgskip "Cannot check for service %s." $1
	fi
}

# @FUNCTION: sys_check_php_module
# @USAGE: [module]
# @DESCRIPTION:
# Checks if a certain PHP module is enabled.
sys_check_php_module() {
	php -m | grep $1 > /dev/null
	if [[ $? == 0 ]]; then
		msgok "PHP %s extension is installed." $1
	else
		msgfail "PHP %s extension not installed." $1
	fi
}

# @FUNCTION: sys_check_php_setting
# @USAGE: [setting] [value]
# @DESCRIPTION:
# Checks if a PHP setting equals a given value.
sys_check_php_setting() {
	php -i | grep -e "$1.*$2" > /dev/null
	if [[ $? == 0 ]]; then
		msgok "PHP setting %s is %s." $1 $2
	else
		msgfail "PHP setting %s is not %s." $1 $2
	fi
}

# @FUNCTION: sys_check_im_format_r
# @USAGE: [long format]
# @DESCRIPTION:
# Checks whether a certain format is supported by imagemagick for reading. The
# format must be provided in its long version i.e. "Portable Network Graphics".
sys_check_im_format_r() {
	identify -list format | grep -e "r.....$1" > /dev/null
	if [[ $? == 0 ]]; then
		msgok "Imagemagick has read support for %s." "$1"
	else
		msgfail "Imagemagick has no read support for %s." "$1"
	fi
}

# @FUNCTION: sys_check_im_format_rw
# @USAGE: [long format]
# @DESCRIPTION:
# Checks whether a certain format is supported by imagemagick for reading and
# writing. The format must be provided in its long version i.e. "Portable
# Network Graphics".
sys_check_im_format_rw() {
	identify -list format | grep -e "rw....$1" > /dev/null
	if [[ $? == 0 ]]; then
		msgok "Imagemagick has read-write support for %s." "$1"
	else
		msgfail "Imagemagick has no read-write support for %s." "$1"
	fi
}

# @FUNCTION: sys_check_sox_format
# @USAGE: [extensions/format]
# @DESCRIPTION:
# Checks whether a certain format is supported by sox. The format must
# be provided in its short version i.e. "ogg".
sys_check_sox_format() {
	sox -h | grep $1 > /dev/null
	if [[ $? == 0 ]]; then
		msgok "Sox has support for %s." "$1"
	else
		msgfail "Sox has no support for %s." "$1"
	fi
}

# @FUNCTION: sys_check_ffmpeg_format_r
# @USAGE: [long format]
# @DESCRIPTION:
# Checks whether a certain format is supported by ffmpeg for reading. The
# format must be provided in its long version i.e. "raw H.264 video format".
sys_check_ffmpeg_format_r() {
	ffmpeg -formats 2>&1 | grep -e "D..*$1" > /dev/null
	if [[ $? == 0 ]]; then
		msgok "Ffmpeg has read support for %s." "$1"
	else
		msgfail "Ffmpeg has no read support for %s." "$1"
	fi
}

# @FUNCTION: sys_check_ffmpeg_format_rw
# @USAGE: [long format]
# @DESCRIPTION:
# Checks whether a certain format is supported by ffmpeg for reading and
# writing. The format must be provided in its long version i.e. "raw H.264
# video format".
sys_check_ffmpeg_format_rw() {
	ffmpeg -formats 2>&1 | grep -e "DE.*$1" > /dev/null
	if [[ $? == 0 ]]; then
		msgok "Ffmpeg has read-write support for %s." "$1"
	else
		msgfail "Ffmpeg has no read-write support for %s." "$1"
	fi
}

# @FUNCTION: sys_check_apache_module
# @USAGE: [module]
# @DESCRIPTION:
# Checks whether a certain module is loaded into apache.
sys_check_apache_module() {
	httpd -t &> /dev/null
	if [[ $? == 0 ]]; then
		httpd -M 2>&1 | grep "$1_module" > /dev/null
		if [[ $? == 0 ]]; then
			msgok "Apache module %s loaded." "$1"
		else
			msgfail "Apache is missing module %s." "$1"
		fi
	else
		msgskip "Cannot check for apache module %s, the httpd command errors out." "$1"
	fi
}

# @FUNCTION: sys_check_mysql_engine
# @USAGE: [engine]
# @DESCRIPTION:
# Checks whether a certain storage engine is available with MySQL.
sys_check_mysql_engine() {
	mysql -e 'SHOW ENGINES;' &> /dev/null
	if [[ $? == 0 ]]; then
		mysql -e 'SHOW ENGINES;' 2>&1 | grep -E "$1.*(YES|DEFAULT)" > /dev/null
		if [[ $? == 0 ]]; then
			msgok "MySQL has support for engine %s." "$1"
		else
			msgfail "MySQL has no support for engine %s." "$1"
		fi
	else
		msgskip "Cannot check for MySQL engine %s, the mysql command errors out." "$1"
	fi
}
