# Used on Linux platforms.
backup_apache () {
	tarsnap -cvf apache-$(date +'%Y-%m-%d') ~/apache
}