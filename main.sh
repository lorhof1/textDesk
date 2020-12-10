#!/bin/bash

#load variables
echo Initiatig variables...
reservedSpace=3
addTemp=0
ru_0=$(cat ru0.var)
ru_1=$(cat ru1.var)
ru_2=$(cat ru2.var)
ru_3=$(cat ru3.var)
#load functions
echo Initiatig Elite lxOS light ui...
#save recentlyUsed variables
function save-ru-to-file(){
  echo "$ru_0" > ru0.var
  echo "$ru_1" > ru1.var
  echo "$ru_2" > ru2.var
  echo "$ru_3" > ru3.var
}

#add a recently used app
function add-recently-used(){
  ru_3=$ru_2
  ru_2=$ru_1
  ru_1=$ru_0
  ru_0=$addTemp
  save-ru-to-file
}

#to do: downscale image to screen resolution, then draw it.
function draw-background(){
  screenH="$(tput lines)"
  bgH=$((screenH-reservedSpace))
  convert background.jpg -resize "$(tput cols)"x"$bgH"! background_scaled.jpg
  #echo "$(grep ")  #" <<< "$(convert background_scaled.jpg -crop '1x1+1+1' txt:-)")" | cut -d " " -f 4
  y=0
  for i in $(eval echo "{1..$bgH}")
  do
  let "y=y+1"
    line=""
    for j in $(eval echo "{1..$(tput cols)}")
    x=0
    do
      let "x=x+1"
      pixelHEX="$(echo "$(grep ")  #" <<< "$(convert background_scaled.jpg -crop '${x}x${y}+1+1' txt:-)")" | cut -d " " -f 4)"
      pixelR="$((16#"$(echo "$pixelHex" | head -c 2 | tail -c 1)"))""$((16#"$(echo "$pixelHex" | head -c 3 | tail -c 1)"))"
      pixelG="$((16#"$(echo "$pixelHex" | head -c 4 | tail -c 1)"))""$((16#"$(echo "$pixelHex" | head -c 5 | tail -c 1)"))"
      pixelB="$((16#"$(echo "$pixelHex" | head -c 6 | tail -c 1)"))""$((16#"$(echo "$pixelHex" | head -c 7 | tail -c 1)"))"
      pixelRCompatible="$(echo "$(($pixelR / 255))"| awk '{print int($1+0.5)}')"
      pixelGCompatible="$(echo "$(($pixelG / 255))"| awk '{print int($1+0.5)}')"
      pixelBCompatible="$(echo "$(($pixelB / 255))"| awk '{print int($1+0.5)}')"
      if [ "$pixelRCompatible" = "0"]
      then
        if [ "$pixelGCompatible" = "0"]
        then
          if [ "$pixelBCompatible" = "0"]
          then
            pixel="\e[0m\e[0m.\e[0m"
          done
        done
      done
      if [ "$pixelRCompatible" = "0"]
      then
        if [ "$pixelGCompatible" = "0"]
        then
          if [ "$pixelBCompatible" = "1"]
          then
            pixel="\e[34m\e[44m.\e[0m"
          done
        done
      done
      if [ "$pixelRCompatible" = "0"]
      then
        if [ "$pixelGCompatible" = "1"]
        then
          if [ "$pixelBCompatible" = "0"]
          then
            pixel="\e[32m\e[42m.\e[0m"
          done
        done
      done
      if [ "$pixelRCompatible" = "1"]
      then
        if [ "$pixelGCompatible" = "0"]
        then
          if [ "$pixelBCompatible" = "0"]
          then
            pixel="\e[31m\e[41m.\e[0m"
          done
        done
      done
      if [ "$pixelRCompatible" = "0"]
      then
        if [ "$pixelGCompatible" = "1"]
        then
          if [ "$pixelBCompatible" = "1"]
          then
            pixel="\e[36m\e[46m.\e[0m"
          done
        done
      done
      if [ "$pixelRCompatible" = "1"]
      then
        if [ "$pixelGCompatible" = "1"]
        then
          if [ "$pixelBCompatible" = "0"]
          then
            pixel="\e[33m\e[43m.\e[0m"
          done
        done
      done
      if [ "$pixelRCompatible" = "1"]
      then
        if [ "$pixelGCompatible" = "1"]
        then
          if [ "$pixelBCompatible" = "1"]
          then
            pixel="\e[97m\e[107m.\e[0m"
          done
        done
      done
      line="${line}${pixel}"
    done
    echo -e "$line"
  done
}

function desk-menu-connectivity-wlan(){
  #incomplete
  desk
}

function desk-menu-connectivity-bluetooth(){
  #incomplete
  desk
}

#power menu
#tested, pm-utils has to be installed
function desk-menu-power(){
  echo -e "\e[105mPower off Restart Sleep\e[0m"
  reservedSpace=3
  draw-background
  echo -e "\e[44mrecently used $ru_0 $ru_1 $ru_2 $ru_3\e[0m"
  read -rsn1 input
  if [ "$input" = "p" ]
  then
    reservedSpace=2
    draw-background
    echo "Info: you will not see the password"
    sudo shutdown -h now
  elif [ "$input" = "r" ]
  then
    reservedSpace=2
    draw-background
    echo "Info: you will not see the password"
    sudo shutdown -r now
  elif [ "$input" = "s" ]
  then
    desk
    pm-suspend-hybrid
  else
    desk-menu
  fi
}

#connectivity menu
#functions incomplete
function desk-menu-connectivity(){
  echo -e "\e[105mWlan Bluetooth\e[0m"
  ping=$(ping -c 1 1.1.1.1 | grep 64 | cut -d " " -f 7)
  if [ "$ping" = "" ]
  then
    echo no internet connection
  else
    echo ${ping/time=/ping: }
  fi
  reservedSpace=4
  draw-background
  echo -e "\e[44mrecently used $ru_0 $ru_1 $ru_2 $ru_3\e[0m"
  read -rsn1 input
  if [ "$input" = "w" ]
  then
    desk-menu-connectivity-wlan
  elif [ "$input" = "b" ]
  then
    desk-menu-connectivity-bluetooth
  else
    desk-menu
  fi
}

#app menu
#completed
function desk-menu-apps(){
  echo -e "\e[105mmenu power connectivity apps\e[0m"
  echo $(ls apps) > apps.list
  applist=$(<"apps.list")
  > apps.list
  for word in $applist
  do
    echo "$word" | sed -e "s/.sh$//" >> apps.list
  done
  sed -i.bak '/appdata/d' ./apps.list
  counter=0
  while [ $counter -lt $(grep "" -c apps.list) ]
  do
    let "counter=counter+1"
    echo $counter $(sed "$(echo $counter)q;d" apps.list)
    #"
  done
  reservedSpace=$((3 + $(grep "" -c apps.list)))
  draw-background
  echo -e "\e[44mrecently used $ru_0 $ru_1 $ru_2 $ru_3\e[0m"
  read -rs input
  re='^[0-9]+$'
  if ! [[ $input =~ $re ]]
  then
    desk-menu
  elif [ "$input" -gt "$(grep "" -c apps.list)" ]
  then
    desk-menu
  else
    addTemp=$(sed "${input}q;d" apps.list)
    add-recently-used
    bash ./apps/$(sed "${input}q;d" apps.list).sh
  fi
}

#menu bar
function desk-menu(){
  echo -e "\e[105mmenu Power Connectivity Apps\e[0m"
  reservedSpace=3
  draw-background
  echo -e "\e[44mrecently used $ru_0 $ru_1 $ru_2 $ru_3\e[0m"
  read -rsn1 input
  if [ "$input" = "p" ]
  then
    desk-menu-power
  elif [ "$input" = "c" ]
  then
    desk-menu-connectivity
  elif [ "$input" = "a" ]
  then
    desk-menu-apps
  else
    desk
  fi
}

#recently used bar
#completed
function desk-recenly-used(){
  echo -e "\e[44mmenu power connectivity apps\e[0m"
  reservedSpace=3
  draw-background
  echo -e "\e[105mrecently used ${ru_0^} ${ru_1^} ${ru_2^} ${ru_3^}\e[0m"
  read -rsn1 input
  if [ "$input" = "$(echo $ru_0 | head -c 1)" ]
  then
    addTemp=$ru_0
    add-recently-used
    save-ru-to-file
    bash ./apps/$addTemp.sh
  elif [ "$input" = "$(echo $ru_1 | head -c 1)" ]
  then
    addTemp=$ru_1
    add-recently-used
    save-ru-to-file
    bash ./apps/$addTemp.sh
  elif [ "$input" = "$(echo $ru_2 | head -c 1)" ]
  then
    addTemp=$ru_2
    add-recently-used
    save-ru-to-file
    bash ./apps/$addTemp.sh
  elif [ "$input" = "$(echo $ru_3 | head -c 1)" ]
  then
    addTemp=$ru_3
    add-recently-used
    save-ru-to-file
    bash ./apps/$addTemp.sh
  else
    desk
  fi
}

#main ui
#completed
function desk(){
  echo -e "\e[44mMenu power connectivity apps\e[0m"
  reservedSpace=3
  draw-background
  echo -e "\e[44mRecently used $ru_0 $ru_1 $ru_2 $ru_3\e[0m"
  read -rsn1 input
  if [ "$input" = "m" ]
  then
    desk-menu
  elif [ "$input" = "r" ]
  then
    desk-recenly-used
  else
    desk
  fi
}

#make backup
save-ru-to-file
#load ui
desk