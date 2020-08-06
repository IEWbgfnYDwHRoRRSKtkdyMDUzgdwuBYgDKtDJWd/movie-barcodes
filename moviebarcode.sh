#!/bin/bash

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

FILE=$1
widthfactor=$2


		vidinfo;
		python3 barcode.py -video "$FILE" -width $((width*widthfactor)) -height $height
