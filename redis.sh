#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
PACKAGES=("mysql" "python" "nginx" "httpd")
SCRIPT_DIR=$PWD


mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]
then
    echo -e " $R ERROR : you dont have root access to run the script  $N " | tee -a $LOG_FILE #by using tee command the output shown on screen and stored in logs also ,we have -e for echo to print colours and $N to stop the colour for that line 
    exit 1
else
    echo -e "$R you have root access to run the script $N " | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "   $2....  is $G success $N " | tee -a $LOG_FILE
    else
        echo -e "  $2....   is $Y failure $N " | tee -a $LOG_FILE
        exit 1
    fi
}


