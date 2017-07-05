BREAKDANCER_TARGETS=`{ ./bin/targets }

breakdancer:V:	$BREAKDANCER_TARGETS

results/cfgfiles/%.cfg:D:	data/%.bam
	mkdir -p `dirname $target`
	bam2cfg.pl \
		$prereq \
		> $target

results/breakdancer/%.ctx	results/breakdancer/%.ctx.%.1.fastq	results/breakdancer/%.ctx.%.2.fastq:D:	results/cfgfiles/%.cfg
	VAR=`echo $alltarget | awk '{print $1}'`
	mkdir -p `dirname $target`
	breakdancer-max \
		-d $VAR \
		$prereq \
		> $VAR
