BREAKDANCER_TARGETS=`{ ./targets_breakdance }

breakdancer:V:$BREAKDANCER_TARGETS

data/cfgfiles/%.cfg	:D:	data/%.final.bam
	mkdir -p `dirname $target`
	bam2cfg.pl \
		$prereq \
		> $target

results/%.ctx	results/%.ctx.%.1.fastq	results/%.ctx.%.2.fastq	:D:	data/cfgfiles/%.cfg
	VAR=`echo $alltarget | awk '{print $1}'`
	mkdir -p `dirname $target`
	breakdancer-max \
		-d "prueba" \
		$prereq \
		> $VAR
