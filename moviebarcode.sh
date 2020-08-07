#!/bin/bash
#bash moviebarcode.sh vid widthfactor batchpreference
#bash moviebarcode.sh video6.mp4 6 batchno
#bash moviebarcode.sh x 6 batchyes
##var trimfactortoframes_yn can be set to "y" or "no" to trim width to exact frame count

function vidinfo () {
	INPUT="${FILE}"
	width=$(ffprobe -select_streams v -show_streams $INPUT 2>/dev/null | grep coded_width | sed -e 's/coded_width=//')
	height=$(ffprobe -select_streams v -show_streams $INPUT 2>/dev/null | grep coded_height | sed -e 's/coded_height=//')
	frames=$(ffprobe -select_streams v -show_streams $INPUT 2>/dev/null | grep nb_frames | sed -e 's/nb_frames=//')
	echo 
	echo \[vidinfo\]":" $INPUT 
	echo \[frames\]":" "$frames"
	echo \[width\]":" "$width"
	echo \[height\]":" "$height"
}

function batchno () {
		vidinfo;
		barwidth=$((width*widthfactor));
		if [ $trimfactortoframes_yn == 'y' ]; 
			then
				if [ "$barwidth" -gt "$frames" ]; 
					then
						echo ;
						echo "...scale factor exceeded framecount, triming outwidth to framecount";
						echo \[barwidth: $barwidth \> frames: $frames\] .. \[barwidth: \= $frames\];
						barwidth=$frames;
						echo \[barcode output dims\] = \[$barwidth x $height\];
						echo ;
					else
						echo \[barcode output dims\] = \[$barwidth x $height\] \(width factor = $widthfactor\);
				fi
			else
				echo \[barcode output dims\] = \[$barwidth x $height\] \(width factor = $widthfactor\);
		fi
		echo ;
		python3 barcode.py -video "$FILE" -width $barwidth -height $height;
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
			batchno;
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
trimfactortoframes_yn=y


if [ $batch == 'batchno' ];then
batchno
fi
if [ $batch == 'batchyes' ];then
batchyes
fi
