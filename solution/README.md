# csvserver-assignment
Infracloud interview assignment

## Part-I
mkdir solution
cd solution/

### This is failing as inputdata file is not available inside container under "/csvserver/"
```
chetan@99devops:~/Documents/coderepo/csvserver-assignment$ docker run -it infracloudio/csvserver:latest
2022/05/06 13:29:08 error while reading the file "/csvserver/inputdata": open /csvserver/inputdata: no such file or directory
```

### Generate input data script
```
touch gencsv.sh ## create bash script with content
chmod +x gencsv.sh
./gencsv.sh	## run script to generate "inputFile", colum-1 being index [0..N-1]
		## column-2 being random number

./gencsv.sh 100000	## run script passing argument if script needs to extend values
```

### Execution steps for running docker container
```
## Know the absolute path for inputFile
chetan@99devops:~/Documents/coderepo/csvserver-assignment/solution$ INPUTFILE=`pwd`/inputFile
chetan@99devops:~/Documents/coderepo/csvserver-assignment/solution$ echo $INPUTFILE
/home/chetan/Documents/coderepo/csvserver-assignment/solution/inputFile


## Run container with inputFile on local bind mounted inside container
chetan@99devops:~/Documents/coderepo/csvserver-assignment/solution$ docker run -itd --name csvserver-docker --mount type=bind,source=${INPUTFILE},target=/csvserver/inputdata infracloudio/csvserver:latest
196adbe2d237e7feaaaa83f42cf05488134f3279bf24fc76d68a0c43305d571d

## Know the ID of container
chetan@99devops:~/Documents/coderepo/csvserver-assignment/solution$ CONTAINER=$(docker ps | awk '/csvserver-docker/ {print $1}')
chetan@99devops:~/Documents/coderepo/csvserver-assignment/solution$ echo $CONTAINER
196adbe2d237

## Know the application port inside container
chetan@99devops:~/Documents/coderepo/csvserver-assignment/solution$ PORT=$(docker exec -it ${CONTAINER} netstat -anp | awk '/csvserver/ {print $4}' | awk -F ':' '{print $4}') && echo ${PORT}
9300

## stop & remove container
chetan@99devops:~/Documents/coderepo/csvserver-assignment/solution$ docker stop ${CONTAINER} && docker rm ${CONTAINER}
196adbe2d237
196adbe2d237

## Run container adding environment variable and local host port mapping to container's app port
chetan@99devops:~/Documents/coderepo/csvserver-assignment/solution$ docker run -itd --name csvserver-docker --env CSVSERVER_BORDER=Orange -p 9393:${PORT} --mount type=bind,source=${INPUTFILE},target=/csvserver/inputdata infracloudio/csvserver:latest
bccdf155738eca1ea7c86458d4d75c6dce191ebd43864a622420947f406fca5c

chetan@99devops:~/Documents/coderepo/csvserver-assignment/solution$ CONTAINER=$(docker ps | awk '/csvserver-docker/ {print $1}')
```

### UI would open fine with given [10] entries and 'Orange' border on => http://localhost:9393/




