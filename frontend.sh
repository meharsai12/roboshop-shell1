#!/bin/bash

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

dnf module list nginx  &>>$LOG_FILE
VALIDATE $? "list nginx"

dnf module disable nginx -y   &>>$LOG_FILE
VALIDATE $? "disable nginx"

dnf module enable nginx:1.24 -y   &>>$LOG_FILE
VALIDATE $? "enable:1.24 nginx"

dnf install nginx -y   &>>$LOG_FILE
VALIDATE $? "install nginx"

systemctl enable nginx   &>>$LOG_FILE
VALIDATE $? "enable nginx"

systemctl start nginx   &>>$LOG_FILE
VALIDATE $? "start nginx "

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "removing the default content "

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "downloading the frontend catalogue"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $? "unzipping frontend"

rm -rf vim /etc/nginx/nginx.conf
VALIDATE $? "removing default nginx conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "nginxconfigurations "

systemctl restart nginx 
VALIDATE $? "restarting nginx"

