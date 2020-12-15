#trash
line=0
while [ "1" = "1" ]
do
    let line=line+1
    debug=$(sed "${line}q;d" main.sh)
    $debug
    read $test
    $test
done