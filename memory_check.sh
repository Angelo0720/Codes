usage(){
	echo "$0 [-c <Critical Threshold in %>] [-w <Warning Threshold in %>] [-e <Email Address>]"
	exit 1
}

TOTAL_MEMORY=$( free | grep Mem: | awk '{print $2}' )
USED_MEMORY=$( free | grep Mem: | awk '{print $3}' )

while getopts ":c:w:e:" opt; do
	case "${opt}" in
		c)
			c=${OPTARG}
			;;
		w)
			w=${OPTARG}
			;;
		e)
			e=${OPTARG}
			;;
	esac
done
shift $((OPTIND-1))

if [-z "${c}" ] || [-z "${w}" ] || [-z "${e}" ]; then
	echo "This script needs parameters">&2
	usage
else
	if [ $c -le $w ]; then
		echo " Critical Threshold must be greater than Warning Threshold">&2
		usage
	else
		crit=$(awk "BEGIN {printf \%.0f\n\", $TOTAL_MEMORY*($c/100)}")
		warn=$(awk "BEGIN {printf \%.0f\n\", $TOTAL_MEMORY*($w/100)}")
		if [ $USED_MEMORY -ge $crit ]; then
			datetime=$(date +%Y%m%d" "%H:%M)
			subj=' memory check - critical'
			subject=$datetime$subj
			message=$( ps aux --sort=-%mem | awk 'NR<=10{print $0}' )
			echo $message | mail -s $subject $e
			echo "2">&2
			exit 1
		elif [ $USED_MEMORY -ge $warn ] && [ $USED_MEMORY -lt $crit ]; then
			echo "1">&2
			exit 1
		elif [ $USED_MEMORY -lt $warn ]; then
			echo "0">&2
			exit 1
		fi	
	fi
fi