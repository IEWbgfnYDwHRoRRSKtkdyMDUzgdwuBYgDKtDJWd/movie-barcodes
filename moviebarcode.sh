#!/bin/bash
#!bash moviebarcode.sh video6.mp4 6 batchno
#!bash moviebarcode.sh video6.mp4 6 batchyes

function vidinfo () {
	INPUT="${FILE}"
	width=$(ffprobe -select_streams v -show_streams $INPUT 2>/dev/null | grep coded_width | sed -e 's/coded_width=//')
	height=$(ffprobe -select_streams v -show_streams $INPUT 2>/dev/null | grep coded_height | sed -e 's/coded_height=//')

	echo 
	echo \[vidinfo\]":" $INPUT 
	echo \[width\]":" "$width"
	echo \[height\]":" "$height"
}

function batchno () {

		vidinfo;
		python3 barcode.py -video "$FILE" -width $((width*widthfactor)) -height $height
		
}

function batchyes () {

		
		if [ ! -d "out" ]
			then
			mkdir out
		fi
		
		while read line;
		do
		
			TITLEext=$(youtube-dl -s --get-filename -f 'bestvideo[height<=720]' $line -o '%(title)s.%(ext)s');
			echo \[Downloading Video\]":" "$TITLEext";
			echo ;
			TITLE="${TITLEext%.*}";
			ext="${TITLEext##*.}";
			FILE=tmp.$ext;
			youtube-dl -f 'bestvideo[height<=720]' $line -o "$FILE";
			vidinfo;
			echo \[barcode output dims\] = \[$((width*widthfactor)) x $height\] \(width factor = $widthfactor\);
			echo ;
			python3 barcode.py -video "$FILE" -width $((width*widthfactor)) -height $height;
			mv tmp_barcode.jpg ./out/"$TITLE"-barcode.jpg;
			echo ;
			echo \[deleting temp video\]":" "$FILE";
			echo ;
			rm -rf "$FILE";
			
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
