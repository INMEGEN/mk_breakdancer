BREAKDANCER_TARGETS=`{ ./bin/targets }

breakdancer:V:	$BREAKDANCER_TARGETS

results/cfgfiles/%.cfg:D:	data/%.bam
	mkdir -p `dirname $target`
	bam2cfg.pl \
		$prereq \
		> $target".build" \
	&& mv $target".build" $target

results/breakdancer/%.ctx \
results/breakdancer/%.ctx.%.1.fastq \
results/breakdancer/%.ctx.%.2.fastq:D:	results/cfgfiles/%.cfg
	mkdir -p `dirname $target`
	FILE=`echo $stem | cut -d"_" -f1`
	breakdancer-max \
		-d $target".build" \
		$prereq \
		> $target".build" \
	&& mv $target".build" $target \
	&& mv $target".build."$FILE".1.fastq" $target"."$FILE".1.fastq" \
	&& mv $target".build."$FILE".2.fastq" $target"."$FILE".2.fastq"

