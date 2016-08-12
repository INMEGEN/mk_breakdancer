<mkbreakdancerLSF.mk

BREAKDANCER_TARGETS=`{find -L data/ -name '*.final.bam' \
	| sed \
		-e 's#data/#results/#g' \
		-e 's#.final.bam#.ctx#g' \
	| sort -u \
 }

breakdancer:V:$BREAKDANCER_TARGETS
	for file in $BREAKDANCER_TARGETS; do
		echo "cd `pwd`
		mk $file" | bsub
	done

data/cfgfiles/%.cfg:	data/%.final.bam
	mkdir -p `dirname $target`
	$PERL \
		$BAM2CFG \
		$prereq \
		> $target

results/%.ctx	results/%.ctx.%.1.fastq	results/%.ctx.%.2.fastq:	data/cfgfiles/%.cfg
	VAR=`echo $alltarget | awk '{print $1}'`
	mkdir -p `dirname $target`
	$BREAKDANCER \
		-d \
		$prereq \
		> $VAR
