# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    monitoring.sh                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ededemog <ededemog@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/02/19 20:00:28 by ededemog          #+#    #+#              #
#    Updated: 2024/02/20 12:27:44 by ededemog         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/bash
printf "\n\n"

kernel_version=$(uname -r)
archi=$(uname -m)

cpu=$(lscpu | grep Socket | awk '{print $2}')
vcpu=$(nproc)

memtotal=$(free -m | grep Mem | awk '{print $2}')
memused=$(free -m | grep Mem | awk '{print $3}')
mempercent=$(free -m | grep Mem | awk '{print $3/$2 * 100}')

disktotal=$(df -h --block-size=G --total | tail -n 1 | awk '{printf $2}' | cut -d G -f1)
diskused=$(df -h --block-size=G --total | tail -n 1 | awk '{printf $3}' | cut -d G -f1)
diskpercent=$(df -h --block-size=G --total | tail -n 1 | awk '{printf $5}' | cut -d % -f1)

cpuload1=$(mpstat | tail -n 1 | awk '{gsub(/,/, "." $4); print $4}')
cpuload2=$(mpstat | tail -n 1 | awk '{gsub(/,/, "." $6); print $6}')
cpuload=$(echo "$cpuload1 + $cpuload2" | bc)

lastreboot=$(who -b | awk '{print $3 " " $4}')

lvm=$(cat /etc/fstab | grep /dev/mapper | wc -1)

tcp=$(echo "$(ss -t state established | wc -l) - 1" | bc)

usercount=$(who | wc -l)

mac=$(ip address show | grep link/ether | awk '{print $2}')
ip=$(ip address | grep enp | grep inet | awk '{print $2}' | cut -d / -f1)

printf "\t #Architecture : $archi $kernel_version\n"
printf "\t #pCPU : $cpu\n"
printf "\t #vCPU : $vcpu\n"
printf "\t #Memory Usage : $memused/$memtotal%s ($mempercent%%)\n" "MB"
printf "\t #Disk Usage : $diskused/$disktotal%s ($diskpercent%%)\n" "Gb"
printf "\t #CPU Load : $cpuload%%\n"
printf "\t #Last Reboot : $lastreboot\n"
printf "\t #LVM Use : "
if [ $lvm -gt 0 ]
then
	printf "yes\n"
else
	printf "no\n"
fi
printf "\t #TCP : $tcp ESTABLISHED\n"
printf "\t #User Logs : $usercount\n"
printf "\t #Network : IP $ip%s ($mac)\n"

printf "\n\n"