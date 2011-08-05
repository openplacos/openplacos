echo "Arduino board ?"
echo "Uno      [1]"
echo "Mega1280 [2]"
echo "Mega2560 [3]"
read board

case $board in
  1) chip="ATMEGA328P";file="Uno.hex";;
  2) chip="ATMEGA1280";file="MEGA1280.hex";;
  3) chip="ATMEGA2560";file="MEGA2560.hex";;
esac

echo $chip
echo $file

echo "USB port ?"
read port

echo "Start uploading"
avrdude -c arduino -p $chip -P $port -b 115200 -U flash:w:$file 
