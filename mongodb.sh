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


cp mongodb.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying the mongodb repo"

dnf install mongodb-org -y    &>>LOGS_FOLDER
VALIDATE $? " Installing mongodb "

systemctl enable mongod     &>>LOGS_FOLDER
VALIDATE $? "enable mongod"


systemctl start mongod       &>>LOGS_FOLDER
VALIDATE $? "start mongod" 


sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf   # we will be sed editor to replacing the content and -i is for premanent edit or replacing content
VALIDATE $?  " replacin ip address for remote connections"

systemctl restart mongod
VALIDATE $? "Restarting mongodb"


END_TIME=$(date +%s)
TOTAL_TIME=$(( $START_TIME - $END_TIME ))
echo -e " Time taken to execute script is :: $Y $TOTAL_TIME in seconds $N
