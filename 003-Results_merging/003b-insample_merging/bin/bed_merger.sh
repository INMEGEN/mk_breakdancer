## This script performs round of bed regions merging by reciprocal overlap.
## First, script checks number of lines of input file
## Then, script performs bed region merging
## Then, script checks number of lines of output.tmp file
##  If number of lines of output.tmp file is different than number of lines of input files, The output.tmp file enters a new round of region merging
##  If number of lines of output.tmp file and input file is the same, then no more merging is neccesary and output.tmp file is renamed finally to output file.

#!/bin/bash
set -x

## Define bed merging function
function bed_merge_func {
	echo "Merging bed entries for $1"
	echo "Results will be stored temporally in $2"
	## Run bedmap to produce REGION1 | REGION 2 raw data for merging
	$BEDMAP --echo --echo-map --fraction-both $OVERLAP $1 \
	> $2.intermediate_from_bedmap.bed.build \
	&& mv $2.intermediate_from_bedmap.bed.build $2.intermediate_from_bedmap.bed
	## This extracts records that does not need merging
	awk 'BEGIN {FS="|"; OFS="|"} $1==$2 {print $1}' $2.intermediate_from_bedmap.bed \
	> $2.unnecesary_merge.bed.build \
	&& mv $2.unnecesary_merge.bed.build $2.unnecesary_merge.bed
	## This extracts lines that require merging
	awk 'BEGIN {FS="|"; OFS="|"} $1!=$2 {print $0}' $2.intermediate_from_bedmap.bed \
	> $2.to_merge.bed.build \
	&& mv $2.to_merge.bed.build $2.to_merge.bed
	## This merges the record that needs merging
	{
	while read SV
	do
		SV_EVENTS=`echo $SV | tr "|" "\n" | tr ";" "\n"`
#		echo $SV_EVENTS
#		echo "CHR"
		CHR=`echo $SV | tr "|" "\n" | tr ";" "\n" | cut -d" " -f1 | sort -u`
#		echo "STARTS"
#		echo $SV | tr "|" "\n" | tr ";" "\n" | cut -d" " -f2 | sort -u
#		echo "MIN START"
		MIN_START=`echo $SV | tr "|" "\n" | tr ";" "\n" | cut -d" " -f2 | sort -n | head -n1`
#		echo "ENDS"
#		echo $SV | tr "|" "\n" | tr ";" "\n" | cut -d" " -f3 | sort -u
#		echo "MAX END"
		MAX_END=`echo $SV | tr "|" "\n" | tr ";" "\n" | cut -d" " -f3 | sort -n | tail -n1`
#		echo "SAMPLES"
		SAMPLES=`echo $SV | tr "|" "\n" | tr ";" "\n" | cut -d" " -f4 | sort -u | tr "\n" "," | sed "s#,\\$##"`
		echo $CHR $MIN_START $MAX_END $SAMPLES | tr " " "\t"
	done < $2.to_merge.bed
	} | sort -V -u > $2.merged.bed.build \
	&& mv $2.merged.bed.build $2.merged.bed
	## Concatenate entries merged nd that need no merging
	cat $2.unnecesary_merge.bed $2.merged.bed \
	| sort -V \
	> $2.build \
	&& mv $2.build $2

## Count number of lines in Input file
NUMBER_OF_INPUT_LINES=`wc -l $I_FOR_MERGE | cut -d" " -f1`
## Count number of lines in Output.tmp file
NUMBER_OF_OUTPUT_LINES=`wc -l $O_FOR_MERGE | cut -d" " -f1`

## Compare number of lines in I_FOR_MERGE and O_FOR_MERGE files
if [[ "$NUMBER_OF_INPUT_LINES" -eq "$NUMBER_OF_OUTPUT_LINES" ]]; then
## If number of lines in Output.tmp file and Input file is different, perform a new round of bed merging
	echo "[DEBUGGING] bed files DOES NO NEED more merging"
else
## If number of lines in Output.tmp file and Input file is THE SAME, rename .tmp file to $O_FILE requested by user
	echo "[DEBUGGING] bed files NEEDS MORE merging"
		echo "[DEBUGGING]
	I_FOR_MERGE=$O_FOR_MERGE \
	&& rm $O_FOR_MERGE.*
	"
	I_FOR_MERGE=$2 \
	&& rm $2.*
	bed_merge_func $I_FOR_MERGE $O_FOR_MERGE
fi
}

## Script takes first argument, which is path to input file
I_FILE=$1
## Script takes second argument, which is path to output file required
O_FILE=$2

## Define initial paths for intermediate files for merging
I_FOR_MERGE=$I_FILE
O_FOR_MERGE=$O_FILE.tmp

## Perform bed merging
bed_merge_func $I_FOR_MERGE $O_FOR_MERGE
