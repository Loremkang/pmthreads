
#USAGE exec.sh CONFIG NUM_THREADS 
#CONFIG: pthread nvthread pmthreads pmthreads-mpt atlas (case-sensitive)
CONFIG=$1
NUM_THREADS=$2

if [ -z "$1" ] 	
then
	CONFIG=pthread
fi 

if [ -z "$2" ] 	
then
	NUM_THREADS=4
fi 

DATASET_HOME=$HOME/pmthreads/benchmarks/parsec/dataset/parsec-2.1/
ARGUMENTS=" 10 20 128 16384 16384 1000 none /dev/null $NUM_THREADS"
#echo $ARGUMENTS 


#INITIALIZE ENVIRONMENT VARIABLES 
export NVM_LATENCY="100"
export PERSIST_INTERVAL="100"
export CPU_FREQ_MHZ="2000"
#CLEAN NVM 
rm -f .crashed.log  /tmp/nvlib.crash
rm -rf /dev/shm/*
mkdir -p /dev/shm/nvthreads
mkdir -p /dev/shm/pmthreads
sleep 1

#BUILD PROG IF NOT EXIST 
PROG=$CONFIG.out
if [ ! -f ./bin/$PROG ]; then
    echo "$PROG not found, now building ... "
    ./build.sh $CONFIG
    sleep 1
fi


export TIMEFORMAT='TIME IS: %3R seconds'
#EXECUTE 
(time ./bin/$PROG $ARGUMENTS) > /tmp/output  2>&1 
status=$(cat /tmp/output | grep "NORMAL EXIT")
if [ ! -z "$status" ]; then
	cat /tmp/output  | grep "TIME IS" | cut -d " " -f3-
	#cat /tmp/output | grep "real"
else
	echo "OPPS..."
	cat /tmp/output
fi



#CLEAN UP
rm -f .crashed.log  /tmp/nvlib.crash
rm -rf /dev/shm/*
mkdir -p /dev/shm/nvthreads
mkdir -p /dev/shm/pmthreads
