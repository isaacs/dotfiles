# Used on platforms that support yinst commands.
export ROOT=/home/y

# pull in the yvm tab-completions
[ -e /home/y/etc/yvm.bashrc ] && . /home/y/etc/yvm.bashrc

portshift () {
	[ $# -gt 1 ] && from="$1" && to="$2"
	[ $# -eq 1 ] && from="80" && to="$1"
	[ $# -eq 0 ] && from="80" && to="10080"
	s=""
	for i in $(
		yinst set | egrep ': '$from'$' | awk -F: '{ print $1 }'
	); do s="$s $i=$to"; echo $i=$to; done
	yinst set $s
}

relink () {
	br="$1"
	[ "$br" != "" ] && br="-br $br"
	if ! [ -f "`which yinst_create`" ]; then
		yinst i yinst_create
	fi
	rm *.tgz &>/dev/null
	yinst_create -t link && yinst i *.tgz $br && return 0
	return 1
}

rebuild () {
	if ! [ -f "`which yinst_create`" ]; then
		yinst i yinst_create
	fi
	rm *.tgz
	yinst_create
	yinst i *.tgz
}

dist_nightly () {
	if ! [ -f "`which yinst_create`" ]; then
		yinst i yinst_create
	fi
	if ! [ -f "`which dist_install`" ]; then
		yinst i dist_tools
	fi
	rm *.tgz
	yinst_create -t nightly
	dist_install -br nightly *.tgz -batch
}

alias clearydht="/home/y/bin/ydhtUtil -h nightly-vm0.mlk.corp.re1.yahoo.com:4080  -t YapDropzoneData -r 3S6DVY5YYV3QJZ6UWC6MURRYIQ -d"
