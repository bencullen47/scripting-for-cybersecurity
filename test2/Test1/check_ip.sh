#!/usr/bin/env bash

if [ "$#" -ne 1 ] || [[ ! "$1" =~ ^[0-9]+(\.[0-9]+){3}$ ]]; then
	echo "Error: provide one IPv4 address" >&2
exit 1
fi

ip="$1"
auth="exam-data/case/logs/auth.log"
ioc="exam-data/intel/iocs.txt"
firewall="exam-data/case/logs/firewall.log"

failed=$(awk -v ip="$ip" '
	/Failed password/ {
		for (i=1; i<NF; i++)
			if ($i=="from" && $(i+1)==ip) n++
	}
	END {print n+0}
' "$auth")

accepted=$(awk -v ip="$ip" '
    /Accepted password/ {
        for (i=1; i<NF; i++)
            if ($i=="from" && $(i+1)==ip) n++
    }
    END {print n+0}
' "$auth")

echo "IP : $ip"
echo "Failed : $failed"
echo "Accepted : $accepted"

if [ "$failed" -eq 0 ]; then
risk="NONE"

elif [ "$failed" -le 4 ]; then
risk="LOW"

elif [ "$failed" -le 9 ]; then
risk="MEDIMUM"

else
risk="HIGH"
fi
echo "Risk : $risk"

if grep -Fxq -- "$ip" "$ioc"; then
	echo "IOC : yes"
else
echo "IOC : no"
fi


if ! grep -Fw -- "$ip" "$firewall"; then
	echo "Firewall : no entries"
fi

if [ "$failed" -gt 0 ] && [ "$accepted" -gt 0 ]; then
echo "Warning : Successful login after failed attempts"
fi

found=0

for logfile in exam-data/case/logs*; do
[ -f "$logfile" ] || continue
if grep -Fwq -- "$ip" "$logfile"; then
	found=1

fi
done

if [ "$found" -eq 1 ]; then
exit 0
else
exit 3
fi
