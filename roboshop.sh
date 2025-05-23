#!bin/bash


AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-04272fef9ce3ac807"
INSTANCES=("frontend" "mongodb" "catalogue" "mysql" "redis" "cart" "user" "rabbitmq" "shipping" "payment" "dispatch")
ZONE_ID="Z087991113U7C6A5OTRJB"
DOMAIN_NAME="meharsai.site"

for instances in ${INSTANCES[@]}
do 



done