#!/bin/bash
#!bash moviebarcode.sh video6.mp4 6 batchno
#!bash moviebarcode.sh video6.mp4 6 batchyes

function vidinfo () {
	INPUT="${FILE}"
	width=$(ffprobe -select_streams v -show_streams $INPUT 2>/dev/null | grep coded_width | sed -e 's/coded_width=//')
	height=$(ffprobe -select_streams v -show_streams $INPUT 2>/dev/null | grep coded_height | sed -e 's/coded_height=//')

	echo ------------------------------- 
	echo imginfo: $INPUT 
	echo  
	echo width: "$width"
	echo height: "$height"
	echo ------------------------------- 
}

function batchno () {

		vidinfo;
		python3 barcode.py -video "$FILE" -width $((width*widthfactor)) -height $height
		
}

function batchyes () {

		mkdir out
		while read line; do
		
			mkdir temp
			cd temp
			FILE=$(youtube-dl -s --get-filename -f 'bestvideo[height<=1080]' $line -o '%(id)s.%(ext)s')
			youtube-dl -f 'bestvideo[height<=1080]' $line -o '%(id)s.%(ext)s'
			vidinfo;
			mv $FILE ../$FILE
			cd ../
			python3 barcode.py -video "$FILE" -width $((width*widthfactor)) -height $height
			mv "$FILE" temp/"$FILE"
			rm -rf temp
			find . -maxdepth 1  -name "*.jpg" -exec mv "{}" ./out \;
			
		done <batch.txt
}

FILE=$1
widthfactor=$2
batch=$3


if [ $batch == 'batchno' ];then
batchno
fi

if [ $batch == 'batchyes' ];then
batchyes
fi
