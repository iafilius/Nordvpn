#!/bin/bash
#title           :importnordvpn.sh
#description     :This script  batch import nordvpn ovpn files tonetworManger my nmcli  .
#author          :dzaczek consolechars.wordpress.com
#GIT             : https://github.com/dzaczek/Nordvpn
#date            :20180415
#version         :0.5.1a
#usage           :./importnordvpn.sh [-u <"username">   -p <"password">][-h][-d <"directory"> || -g][-c][-f pl,ch,uk,ru,de,*-]
#notes           :Install NetworkManager.x86_64 NetworkManager-openvpn.x86_64 NetworkManager-openvpn-gnome.x86_64 awk
#notes           : the script requires some time, for add 1583 vpn config needed 3h 2m
#==============================================================================
sessionname="$(
  tr </dev/urandom -dc _A-Z-a-z-0-9 | head -c 6
  echo
)"
target="/tmp/$sessionname/nordvpn.zip"
target_1=/tmp/$sessionname/
nmclisysttemconnections="/etc/NetworkManager/system-connections"
nmclibuffer="/tmp/$sessionname/bufer"
nmclitmpfs="/etc/NetworkManager/tmpfs"
bck=$PWD
wnump=0
ttt=$(ps ax | grep $$ | grep -v grep | awk '{print $2}')
terminal="/dev/$ttt"
#rows=$(stty -a <"$terminal" | grep -Po '(?<=rows )\d+')
start=$(date +%s)
UUIDFILE="/tmp/$sessionname.file.dat"

runtime=$((end - start))
nice_output() {
  clear
  columns=$(stty -a <"$terminal" | grep -Po '(?<=columns )\d+')
  #echo "Progress BARR"
  precenteage=$(echo "(($1*100/$2))/1" | bc)
  in="$precenteage/100%"
  sizbar=$(($columns - ${#in} - 7))
  p1=$(echo "(($precenteage*$sizbar)/100)/1" | bc)
  arrr=$5
  precenteage1=$p1
  precenteage2=$((sizbar - p1))
  echo "Session name: $sessionname"
  echo -n -e "\n\n\n\n\n \t\t\tImporting Files.$1/$2\t $6 \n\n\n"
  end=$(date +%s)
  echo -n -e "\t\t\t Script Working $(date -d@$((end - $3)) -u +%H:%M:%S) seconds \n \t\t\t ETA : $(date -d@$(echo "($2-$1)*$4" | bc -l) -u +%H:%M:%S)\n ${arrr[@]}\n"

  #___________Progress___BAR______________________________
  echo -n "$in"
  echo -n -e "["
  #echo -n -e "\n"
  for ((i = 0; i <= precenteage1; i++)); do
    echo -n -e "\e[44m#\e[0m"
  done

  for ((i = 0; i < precenteage2; i++)); do
    echo -n -e "\e[100m-\e[0m"
  done

  echo -n -e "]"
  echo -n -e "100% \n"
  #______________________________________________
}

# Warning, removes really all VPN, including non NordVpn ones....
remove_all_vpn() {
  #remove all vpn utill any vpn conncetion is on a list
  while [[ $(nmcli con show | awk '$3=="vpn" {print "1"}' | wc -l) -gt 0 ]]; do
    nmcli con del $(nmcli con show | awk '$3=="vpn" {print $2}') 2>/dev/null
  done
  echo "Connection VPN removed"
}

get_ovpn_files() {
  #get form network vpn-config files

  #url_config_f="aHR0cHM6Ly9ub3JkdnBuLmNvbS9hcGkvZmlsZXMvemlwCg=="
  url_config_f="aHR0cHM6Ly9kb3dubG9hZHMubm9yZGNkbi5jb20vY29uZmlncy9hcmNoaXZlcy9zZXJ2ZXJzL292cG4uemlwCg=="
  wget $(echo "$url_config_f" | base64 -d) -O $target
  if [ $? -eq 1 ]; then
    echo "I cant download ovpn files check internet connection"
    exit 1
  fi
  unzip $target -d$target_1

  rm -f $target

}

backupnmcliconnections() {
  #create backup ncli connections
  sudo tar --xz -cvf ~/backupNMCLI-$sessionname.tar.xz $nmclisysttemconnections
  if [ $? -eq 0 ]; then
    echo "Backuped $nmclisysttemconnections  in home directory file : backupNMCLI-$sessionname.tar.xz"
    # changed to use tar direcly  it due to set permission error
    #    if hash xz 2>/dev/null;then
    #      xz -9 ~/backupNMCLI-$sessionname.tar && echo "Compressed backup" &
    #    else
    #      echo "Nooooo xz consuela say nononono nono no  no packing "
    #    fi
  else
    echo "Na backuped "
  fi
}

fasterfaster() {
  if [ ! -d $nmclibuffer ]; then
    sudo mkdir $nmclibuffer
    sudo mount -t tmpfs -o size=100M tmpfs $nmclibuffer
  fi
  sudo mv $nmclisysttemconnections/* $nmclibuffer/
  sleep 1
  sudo systemctl restart NetworkManager.service
  sleep 3
}
echo "start6"
createramdisk() {
  #mount ram disk for faster work nmcli
  sudo mkdir $nmclitmpfs
  sudo mount -t tmpfs -o size=1M tmpfs $nmclitmpfs
  sudo restorecon $nmclitmpfs
  sudo mount --bind $nmclitmpfs $nmclisysttemconnections
  sudo restorecon $nmclisysttemconnections
  if [ ! -d $nmclibuffer ]; then
    sudo mkdir $nmclibuffer
    sudo mount -t tmpfs -o size=100M tmpfs $nmclibuffer
  fi

}

restore_files() {
  for x in {a..z}; do
    sudo mv -f $nmclibuffer/${x}* $nmclisysttemconnections/
  done
  sudo mv -f $nmclibuffer/* $nmclisysttemconnections/
}

moveconfigsfromramdisk() {
  sudo mv -f $nmclisysttemconnections/ $nmclibuffer/*
  sudo umount $nmclisysttemconnections
  #sudo mv -f $nmclibuffer/* $nmclisysttemconnections/
  restore_files
  sudo umount $nmclitmpfs
  sudo umount $nmclibuffer
  sudo rm -rf $nmclitmpfs9
  sudo rm -rf $nmclibuffer
  sudo systemctl restart NetworkManager.service

}

import_files_to_nmcli() {
  dxa=6
  dxb=0
  dbl=()
  touch $UUIDFILE
  flags=30
  echo "Added :"
  printf '%s\n' "$a" | while IFS= read -r line; do
    if [ "x" != "x$arr" ]; then
      if [ $flags -eq 0 ]; then
        fasterfaster
        flags=11
      fi
      flags=$(($flags - 1))
    fi
    start_loop1=$(date +%s.%N)
    wnump=$(($wnump + 1))
    #  dxb=$(($dxb+1))
    #prepare short name for connection
    conname=$(echo $line | awk -F "." '{print $1"-"$4}')
    # add/import connection to nmcli and grap uuid by regex in awk
    uuidcon=$(nmcli connection import $temp8 type openvpn file $line | awk 'match($0,  /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/) {print substr($0, RSTART, RLENGTH)}')
    #reneme conenction and add username and password
    #nmcli -w 5 con mod $temp8 uuid $uuidcon connection.id $conname +vpn.data "username=$USERNAMEFORVPN" vpn.secrets password="$PASSWFORVPN" &
    echo "$uuidcon,$conname" >>$UUIDFILE
    if [ $dxb -eq $dxa ]; then
      echo -n -e "\n"
      dxb=0
    else
      dbl[dxb]="$(echo "scale=3;$(date +%s.%N)-$start_loop1" | bc -l)"
      dxb=$(($dxb + 1))
    fi
    average_nmcli_loop=$(echo "scale=2;($(echo ${dbl[*]} | tr ' ' '+'))/${#dbl[*]}" | bc -l)
    #echo "$average_nmcli_loop"
    #echo ${dbl[*]}

    nice_output $wnump $numfiles $start $average_nmcli_loop "${dbl[*]}" $conname
    #echo -n -e "\e[$((31+$dxb))m$conname\e[0m\t" ; if  [ $dxb -eq $dxa ];then echo -n -e "\n";dxb=0; fi
    #      echo -e "$wnump. Added $conname:\t $uuidcon" #verbose

  done

  echo "Loops $wnump"
  usernameandpasswd
}

usernameandpasswd() {
  echo $UUIDFILE
  wnump=0
  dxa=6
  dxb=0
  dbl=()
  flags=30
  while read SLINE; do
    wnump=$(($wnump + 1))
    start_loop1=$(date +%s.%N)

    if [ $dxb -eq $dxa ]; then
      echo -n -e "\n"
      dxb=0
    else
      dbl[dxb]="$(echo "scale=3;$(date +%s.%N)-$start_loop1" | bc -l)"
      dxb=$(($dxb + 1))
    fi
    average_nmcli_loop=$(echo "scale=2;($(echo ${dbl[*]} | tr ' ' '+'))/${#dbl[*]}" | bc -l)
    CUUID2=$(echo $SLINE | cut -d, -f1)
    CNAME2=$(echo $SLINE | cut -d, -f2)

    nice_output $wnump $numfiles $start $average_nmcli_loop "${dbl[*]}" $CNAME2
    nmcli con mod $temp8 uuid $(echo $SLINE | cut -d, -f1) connection.id $(echo $SLINE | cut -d, -f2) +vpn.data "username=$USERNAMEFORVPN" vpn.secrets password="$PASSWFORVPN"

  done <"$UUIDFILE"

}

while getopts ":u:p:d:f:c h g t r" opt; do
  case $opt in
  u) au=$OPTARG ;;
  p) ap=$OPTARG ;;
  c) ac=1 ;;
  d) ad=$OPTARG ;;
  h) ah=1 ;;
  t) att=1 ;;
  r) arr=1 ;;
  g) ag=1 ;;
  f) aff=$OPTARG ;;
  \?)
    echo "Invalid option: -$OPTARG\n Please use parameter -h for help" >&2
    exit 1
    ;;

  esac
done

if [ "$#" == 0 ]; then

  echo "Parameter do not found please use -h for help"
  exit 1
  exit 1
fi

#check if -h print help end exit
if [ "x" != "x$ah" ]; then
  cat <<EOF

          script batch adding openvpn  nordvpn configs to nmcli
          Aplication Working in 2 cycle , First add all or selected configs to NetworkManager.
          Second Sycle is rename concentions (shorname) and add username and password.
          Password  in Gnome is storaged by the  gnome-keyring, after add many servers please wait
          few minutes to complete keyring work( example 300 connection need around 1 minutes).

      usage:
      ./importnordvpn.sh [-u <"username">   -p <"password">][-h][-d <"directory"> || -g][-c][-f pl,ch,uk,ru,de,*-]

            -u username (is mail ) it must be in qoutes " "
            -p password it must be in qoutes " "
            -d patch to direcotory  ovpn files arguments not required
                you can run script in direcotry white space in patch
                not working.
            -f *RECOMMENDED* Filter: Select country use short name exampe
                de for Germany fr for France etc... coma sperated.
                Additional you can use this for selec custom servers
                example se148,us255,de13....
                If you want select Double vpn and Onion over vpn
                user parameter *- example: -f "*-"
            -g Get configs from network.
            -c clean DANGER, roemove all connection type vpn from nmcli
            -t Temporary use this for test, added configuration
                disaper after restart NetworkManager (nmcli)
            -h it is this information
            -r *NOT RECOMMENDED * Test function for fast add servers , all operations
                works on ram disk and NetwormManager is restarted every 30 new added configs
      examples:
            ./importnordvpn -u "myemail@exampl.com" -p "P44SSwoRd"  -g
          or
            ./importnordvpn -u "myemail@exampl.com" -p "P44SSwoRd" -d Download/configs/

          Get configuration from nordvpn.com
            ./importnordvpn -u "myemail@exampl.com" -p "P44SSwoRd" -d

          If you want remove all vpn servers from NetworkManager (-c)
             ./importnordvpn -c

          Clean configuration (remove all vpns from nmcli ). and load new
            ./importnordvpn -c -u "myemail@exampl.com" -p "P44SSwoRd" -d Download/configs/

          Clean configuration (remove all vpns from nmcli ).Add  new from fresh config
          dowloaded from nordvpn server (-g) and filer(-f) only few countries
              ./importnordvpn -c -u "myemail@exampl.com" -p "P44SSwoRd" -g -f uk,ch,de,jp

          Clean configuration (remove all vpns from nmcli ).Add  new from fresh config
          dowloaded from nordvpn server (-g) and filer(-f) only doublevpn and tor
              ./importnordvpn -c -u "myemail@exampl.com" -p "P44SSwoRd" -g -f  "*-"
          ____
      __________________________________________________________
      Report bugs to:dzaczek[animaleatingyellow fruit]sysop.cat
      up home page:https://consolechars.wordpress.com/
      __________________________________________________________
EOF

  exit 1
fi
backupnmcliconnections
#check if -c if exist remove all vpn
if [ "x" != "x$ac" ]; then

  remove_all_vpn
  #check if username and password id declarated if not exit
  if [ "x" == "x$au" ] && [ "x" == "x$ap" ]; then
    exit 1
  fi
fi
#checked if username declarated
if [ "x" == "x$au" ]; then
  echo "-u [username] is required"
  exit 1
fi
#checked if password is declarated
if [ "x" == "x$ap" ]; then
  echo "-p [password] is required"
  exit 1
fi
if [ "x" != "x$att" ]; then
  temp8="--temporary"
  echo "ok"
else
  temp8=""
fi
#checked id direcotry is delcarated
if [ "x" != "x$ad" ]; then
  cd $ad 2>/dev/null
  #chek if -d patch is able to cd if not exit
  if [ $? -eq 1 ]; then
    echo "-d $ad wrong patch to directory"
    exit 1
  fi
fi
#check if parameter -g
if [ "x" != "x$ag" ]; then
  #get ovpn config files
  mkdir $target_1
  get_ovpn_files
  #go to diretory with ovpn config files
  #cd $target_1 2>/dev/null
  cd $target_1/ovpn_udp 2>/dev/null

  echo $PWD
  #chek if -g patch is able to cd if not exit
  if [ $? -eq 1 ]; then
    echo "-d $target_1 wrong patch to directory"
    exit 1
  fi
fi

#assign varaibles
USERNAMEFORVPN=$au
PASSWFORVPN=$ap
a=""
#ssign to vataible a all files *.vpn in directory
if [ "x" != "x$aff" ]; then
  echo $aff
  for MER in $(echo $aff | sed 's/,/ /g'); do
    a+=$(ls $MER*.ovpn)
  done
  echo $a

else
  a=$(ls *.ovpn)
fi
#exit
numfiles=$(echo $a | wc | awk '{print $2}')
#check   if not len a eq 0
if [[ "$numfiles" -eq 0 ]]; then
  echo "Ovpn file in $PWD- do not found $numfiles"
  exit 1
fi

mkdir $target_1
if [ "x" != "x$arr" ]; then
  createramdisk 15
fi

import_files_to_nmcli
if [ "x" != "x$arr" ]; then
  moveconfigsfromramdisk
fi

# Program strat here iterating a line by line and adding
if [ "x" != "x$ag" ]; then
  cd $bck
  rm -fr $target_1 2>/dev/null
  #chek if -g patch is able to rm if not exit
  if [ $? -eq 1 ]; then
    echo "-d $target_1 wrong patch to directory i can remove directory"
    exit 1
  fi
fi
