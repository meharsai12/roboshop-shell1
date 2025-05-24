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


dnf module disable nodejs -y
VALIDATE $? " disabling the nodejs "

dnf module enable nodejs:20 -y
VALIDATE $? " enable the nodejs:20 "

dnf install nodejs -y
VALIDATE $? " installing the nodejs"

id roboshop
if [$? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "creating roboshop user "
else
    echo -e "Roboshop user is already created.... $G SKIPPING $N "
fi

mkdir -p /app  #by adding -p , it created directory if no there , if there it dont create
VALIDATE $? "creating app directory "

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "downloading catalogue zipfile "

rm -rf /app/* #by adding this line if we run n number of times it wont stuck because if we alreadr run one time it asks again to say whether it is there so by giving this command it deletes the data present and unzip again 
cd /app 
unzip /tmp/catalogue.zip
VALIDATE $? "unzipping the catalogue"

npm install 
VALIDATE $? "installing the dependicies "

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copying the catalogue.service files"


systemctl daemon-reload
VALIDATE $? "reloading the catalogue.service"

systemctl enable catalogue 
VALIDATE $? "enabling catalogue"

systemctl start catalogue
VALIDATE $? "starting catalogue"

cp $SCRIPT_DIR/mongodb.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "mongodb.repo relading"

dnf install mongodb-mongosh -y
VALIDATE $? "installing mongodb client"

mongosh --host mongodb.meharsai.site </app/db/master-data.js
VALIDATE $? "to load the masterdata products"

mongosh --host mongodb.meharsai.site
VALIDATE $? "to check whether the data is loaded or not "


