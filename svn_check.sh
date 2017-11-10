#!/bin/bash

############onfig params############
# worker count base on cpus
WORKERS=20
# svn repo path
SVN_PATH="/path/to/svn_repo"
# excluded svn repo path
EXCLUDE_PATHS=("xxx")
####################################



SEARCH_PATH=$SVN_PATH"/*"
EXCLUDE_PATH=""

# clear old files
test -e svn_check_path_* && rm -rf svn_check_path_*

for exc_path in ${EXCLUDE_PATHS[@]}
do
    EXCLUDE_PATH=$EXCLUDE_PATH$SVN_PATH"/"$exc_path"|"
done

EXCLUDE_PATH=${EXCLUDE_PATH%|*}

total_tasks=`find $SEARCH_PATH -maxdepth 0 -type d | grep -v -E $EXCLUDE_PATH`
total_tasks_count=`echo "$total_tasks" | wc -l`
task_count_per_worker=`expr $total_tasks_count / $WORKERS`
if [ $task_count_per_worker == 0 ]
then
    task_count_per_worker=1
fi

# split tasks
echo "$total_tasks" | split -d -l $task_count_per_worker - svn_check_path_

# start workers
for task in `find svn_check_path_*`
do
    nohup /bin/bash svn_check_worker.sh $task > $task".log" 2>&1 &
done

echo "workers: "$WORKERS
echo "task_count_per_worker: "$task_count_per_worker
