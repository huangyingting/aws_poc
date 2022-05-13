#!/bin/bash
apt update
apt install docker.io -y
docker run -d --name nginx -p 80:80 huangyingting/aws_poc
docker run -d --name myadmin -e PMA_HOST=${rds_endpoint} -p 8080:80 phpmyadmin
