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

```

### UI would open fine with given [10] entries and 'Orange' border on => http://localhost:9393/



## Part II
```
## Delete containers running in Part I
docker stop ${CONTAINER} && docker rm ${CONTAINER}

## Run using docker-compose
## Use Ctrl+C to shut.
## Either "docker-compose up -d" to run in background

chetan@99devops:~/Documents/coderepo/csvserver-assignment/solution$ docker-compose up
Creating network "solution_default" with the default driver
Creating solution_csvserver_1 ... done
Attaching to solution_csvserver_1
csvserver_1  | 2022/05/06 15:06:39 listening on ****
csvserver_1  | 2022/05/06 15:06:40 wrote 653 bytes for /
csvserver_1  | 2022/05/06 15:06:40 wrote 653 bytes for /favicon.ico
csvserver_1  | 2022/05/06 15:06:51 wrote 653 bytes for /
csvserver_1  | 2022/05/06 15:06:51 wrote 653 bytes for /favicon.ico
csvserver_1  | 2022/05/06 15:06:53 wrote 653 bytes for /
csvserver_1  | 2022/05/06 15:06:53 wrote 653 bytes for /favicon.ico
^CGracefully stopping... (press Ctrl+C again to force)
Stopping solution_csvserver_1 ... done
```

## Part III
```
## Remove old containers
docker-compose down

## Run docker-compose yaml after adding prometheus configuration
docker-compose up -d
```

### Get prometheus.yml either online or from container from trail run
### Location: /etc/prometheus/prometheus.yml
### Add "csvserver:9300" as target in prometheus.yml
### This is where prometheus will get the metrics from app container.

```
## Now run docker-compose to run both containers
## i.) csvserver ii.) prometheus
chetan@99devops:~/Documents/coderepo/csvserver-assignment/solution$ docker-compose up -d
solution_csvserver_1 is up-to-date
Creating solution_prometheus_1 ... done
```

### Now you can see the running containers using docker
```
chetan@99devops:~/Documents/coderepo/csvserver-assignment/solution$ docker ps
CONTAINER ID   IMAGE                           COMMAND                  CREATED          STATUS          PORTS                    NAMES
bcb0363872e1   prom/prometheus:v2.22.0         "/bin/prometheus --c…"   53 seconds ago   Up 51 seconds   0.0.0.0:9090->9090/tcp   solution_prometheus_1
12d59c9c644b   infracloudio/csvserver:latest   "/csvserver/csvserver"   21 minutes ago   Up 21 minutes   0.0.0.0:9393->9300/tcp   solution_csvserver_1
```

### CSVSERVER => http://localhost:9393/
### PROMETHEUS => http://localhost:9090/
### Both running fine.
### query = csvserver_records and 'Execute' on PROMETHEUS
### Under Graph tab, use 10 mins
### There's a clear horizontal line on 10 as expected 
### in the tutorial


### Destroy
```
chetan@99devops:~/Documents/coderepo/csvserver-assignment/solution$ docker-compose down
Stopping solution_prometheus_1 ... done
Stopping solution_csvserver_1  ... done
Removing solution_prometheus_1 ... done
Removing solution_csvserver_1  ... done
Removing network solution_default
```

## Regarding the 'z' option with '-v' mount, I have used '--mount' instead. Tested on vagrant machine (centos7) while selinux is enabled.
## This works fine!!
