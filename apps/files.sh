for i in $(eval echo "{1..$(tput lines)}")
#"
do
  echo 
done
mkdir -p ./appdata/files
echo "" > ./appdata/files/files.list
function files-list-dir(){
  echo $(ls $dir) > ./appdata/files/files.list
}
dir=/
files-list-dir