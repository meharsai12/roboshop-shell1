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
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

# check the user has root priveleges or not
if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1 #give other than 0 upto 127
else
    echo "You are running with root access" | tee -a $LOG_FILE
fi

# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf module disable nodejs -y
VALIDATE $? "disable nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "enable nodejs"

dnf install nodejs -y
VALIDATE $? "install nodejs"

if [ $? -ne 0 ]
then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   VALIDATE $? "systemuser is created"
else
 echo -e  "Systemuser is already created... $Y SKIPPING $N "
 exit 1

fi

mkdir -p /app 
VALIDATE $? "Creating app directory"


curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "download catalogue zipfile"


rm -rf /app/* &>>$LOG_FILE
cd /app 
unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzip catalogue"

npm install &>>$LOG_FILE
VALIDATE $? "install catalogue"


cp $SCRIPT_DIR/catalogue.ser /etc/systemd/system/catalogue.service
VALIDATE $? "copying catalogue services "

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "daemon reload catalogue"

systemctl enable catalogue  &>>$LOG_FILE
VALIDATE "enable catalogue"

systemctl start catalogue &>>$LOG_FILE
VALIDATE $? "start catalogue"

cp $SCRIPT_DIR/mongodb.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? " install mongodb client "

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "install mongodb-mongosh"

STATUS=$(mongosh --host mongodb.meharsai.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.meharsai.site </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data into MongoDB"
else
    echo -e "Data is already loaded ... $Y SKIPPING $N"
fi

END_TIME=$(date +%s)
TOTAL_TIME= $(( $START_TIME - $END_TIME ))
echo -e " Script executed in $Y ..seconds $N "


