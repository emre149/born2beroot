# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    monitoring.sh                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ededemog <ededemog@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/02/20 17:32:38 by ededemog          #+#    #+#              #
#    Updated: 2024/02/20 17:32:49 by ededemog         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/bash
printf "\n\n"

kernel_version=$(uname -r)
archi=$(uname -m)

cpu=$(lscpu | awk '/Socket/ {print $2}')
vcpu=$(nproc)

memtotal=$(free -m | grep Mem | awk '{print $2}')
memused=$(free -m | grep Mem | awk '{print $3}')
mempercent=$(free -m | grep Mem | awk '{print $3/$2 * 100}')

disktotal=$(df -h --block-size=G --total | tail -n 1 | awk '{printf $2}' | cut -d G -f1)
diskused=$(df -h --block-size=G --total | tail -n 1 | awk '{printf $3}' | cut -d G -f1)
diskpercent=$(df -h --block-size=G --total | tail -n 1 | awk '{print $5}' | cut -d % -f1)

cpuload1=$(mpstat | tail -n 1 | awk '{gsub(/,/, ".", $4); print $4}')
cpuload2=$(mpstat | tail -n 1 | awk '{gsub(/,/, ".", $6); print $6}')
cpuload=$(echo "$cpuload1 + $cpuload2" | bc)

lastreboot=$(who -b | awk '{print $3 " " $4}')

lvm=$(cat /etc/fstab | grep /dev/mapper | wc -l)

tcp=$(echo "$(ss -t state established | wc -l) - 1" | bc)

usercount=$(who | wc -l)

mac=$(ip address show | grep link/ether | awk '{print $2}')
ip=$(ip address | grep enp | grep inet | awk '{print $2}' | cut -d / -f1)

totalsudo=$(echo "obase=10; ibase=36; $(cat /var/log/sudo/seq)" | bc)

printf "\t #Architecture : $archi $kernel_version\n"
printf "\t #pCPU : %d\n" $cpu
printf "\t #vCPU : %d\n" $vcpu
printf "\t #Memory Usage : %d/%dMB (%.2f%%)\n" $memused $memtotal $mempercent
printf "\t #Disk Usage : %d/%dGb (%.2f%%)\n" $diskused $disktotal $diskpercent
if [[ $(echo "cpuload < 1" | bc -l) -eq 1 ]]
then
    printf "\t #CPU Load : 0%s%%\n" $cpuload
else
    printf "\t #CPU Load : %s%%\n" $cpuload
fi
printf "\t #Last Reboot : %s %s\n" $lastreboot
printf "\t #LVM Use : "
if [ $lvm -gt 0 ]
then
    printf "yes\n"
else
    printf "no\n"
fi
printf "\t #TCP : %d ESTABLISHED\n" $tcp
printf "\t #User Logs : %d\n" $usercount
printf "\t #Network : IP %s (%s)\n" $ip $mac
printf "\t #Sudo : %d cmd\n" $totalsudo

printf "\n\n"