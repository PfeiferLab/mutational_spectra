# Written by Suhail Ghafoor
# Date Jul 10, 2022

# This snakemake workflow breaks down the process of converting the VCF file
# to a CSV in multiple small steps. This process is inefficient at a higher 
# level but allows for these short jobs to get queued quicker on a computational 
# cluster environment since each individual job uses miniscule resources
 

configfile: "snake_config.json"

sample_sizes=list(range(5,200,5)) + list(range(200,1000,100)) + list(range(1000,10001,1000)) # list of sample sizes we want from each seed
draws=list(range(1,2)) # list of draws we want per each seed per each sample size

# Create directories if they don't exist
def make_required_dirs():
	for i in config['dir']:
		Path(i).mkdir(exist_ok=True)

rule target:
	input:
		expand(config['dir']['singleton_csvs'] + "{seed}_pop{popnum}_{sampsize}_{drawnum}.singletons.reduced.csv", seed=config['seeds'], popnum=[0,1,2,3], sampsize=sample_sizes, drawnum=draws)


# Produces an index file of given VCF
rule index_vcf_gz:
	input:
		vcf=os.path.join(config['dir']['vcfs'], "{seed}_pop{popnum}.vcf.gz")
	output:
		tbi=os.path.join(config['dir']['vcfs'], "{seed}_pop{popnum}.vcf.gz.tbi")
	threads: 
		24
	params:
		exec=config['app']['bcftools']
	shell:
		"{params.exec} index --threads {threads} -o {output} {input}"

# Compresses a vcf
rule compress_vcf:
	input:
		vcf=os.path.join(config['dir']['vcfs'], "{seed}_pop{popnum}.vcf")
	output:
		compressed_vcf=os.path.join(config['dir']['vcfs'], "{seed}_pop{popnum}.vcf.gz")
	threads:
		8
	params:
		exec=config['app']['bgzip']
	shell:
		"{params.exec} {input} -@ {threads} -c > {output}"

# Given a vcf file draws wildcards.samplesize of individuals from it.
rule create_draws:
	input:
		vcf=os.path.join(config['dir']['vcfs'], "{seed}_pop{popnum}.vcf")
	output:
		draw_list=os.path.join(config['dir']['draws'], "{seed}_pop{popnum}_{sampsize}_{drawnum}.list")
	group:
		"all_grouped"
	threads: 
		1
	params:
		exec=config['app']['drawer']
	shell:
		"{params.exec} {input.vcf} {output.draw_list} {wildcards.sampsize}"

# Uses a .list file and a vcf to create a vcf with sampled individuals
rule draw_individuals:
	input:
		vcf=os.path.join(config['dir']['vcfs'], "{seed}_pop{popnum}.vcf.gz"),
		draw_list=os.path.join(config['dir']['draws'],  "{seed}_pop{popnum}_{sampsize}_{drawnum}.list"),
		tbi=os.path.join(config['dir']['vcfs'], "{seed}_pop{popnum}.vcf.gz.tbi")
	output:
		vcf_sampled=os.path.join(config['dir']['sampled'], "{seed}_pop{popnum}_{sampsize}_{drawnum}.vcf")
	group:
		"all_grouped"
	params:
		exec=config['app']['bcftools']
	threads:
		1
	shell:
		"{params.exec} view -S {input.draw_list} {input.vcf} > {output.vcf_sampled}"

# Apply allele filter to remove mutations that don't exist in the population
rule apply_af:
	input:
		vcf_sampled=os.path.join(config['dir']['sampled'], "{seed}_pop{popnum}_{sampsize}_{drawnum}.vcf")
	output:
		vcf_sampled_af=os.path.join(config['dir']['af_vcf'], "{seed}_pop{popnum}_{sampsize}_{drawnum}.AF.recode.vcf")
	group:
		"all_grouped"
	threads:
		1
	params:
		exec=config['app']['vcftools'],
		arguments="--recode --recode-INFO-all --maf 0.00001 --max-maf 0.99999"
	shell:
		"{params.exec} --vcf {input.vcf_sampled} {params.arguments} -c > {output.vcf_sampled_af}"

# Extract the singleton positions from the sampled VCF
rule extract_singleton_positions:
	input:
		vcf_sampled=os.path.join(config['dir']['sampled'], "{seed}_pop{popnum}_{sampsize}_{drawnum}.vcf")
	output:
		singletons=os.path.join(config['dir']['singleton_positions'] ,"{seed}_pop{popnum}_{sampsize}_{drawnum}.singletons")
	group:
		"all_grouped"
	threads:
		1
	params:
		exec=config['app']['vcftools']
	shell:
		"{params.exec} --vcf {input} --singletons -c > {output}"

# Create a positions file from the singletons output
rule create_positions_file:
	input:
		singletons=os.path.join(config['dir']['singleton_positions'] ,"{seed}_pop{popnum}_{sampsize}_{drawnum}.singletons")
	output:
		positions=os.path.join(config['dir']['create_position'] ,"{seed}_pop{popnum}_{sampsize}_{drawnum}.singletons.positions")
	group:
		"all_grouped"
	threads:
		1
	shell:
		"""awk -F"\\t" '$3 == "S" {{ print $0 }}' {input} | cut -f 1,2 > {output}"""

# Using the positions file, extract positions from the sampled VCF.
rule position_file_extract_vcf:
	input:
		positions=os.path.join(config['dir']['create_position'] ,"{seed}_pop{popnum}_{sampsize}_{drawnum}.singletons.positions"),
		vcf_sampled=os.path.join(config['dir']['sampled'], "{seed}_pop{popnum}_{sampsize}_{drawnum}.vcf")
	output:
		recoded=os.path.join(config['dir']['af_vcf'], "{seed}_pop{popnum}_{sampsize}_{drawnum}.singletons.recode.vcf")
	group:
		"all_grouped"
	threads:
		1
	params:
		exec=config['app']['vcftools']
	shell:
		"{params.exec} --vcf {input.vcf_sampled} --recode --recode-INFO-all --positions {input.positions} -c > {output}"

# Reduce singletons VCF
rule reduced_singletons_vcf:
	input:
		recoded=os.path.join(config['dir']['af_vcf'], "{seed}_pop{popnum}_{sampsize}_{drawnum}.singletons.recode.vcf")
	output:
		reduced=os.path.join(config['dir']['reduced'], "{seed}_pop{popnum}_{sampsize}_{drawnum}.singletons.reduced.vcf")
	group:
		"all_grouped"
	threads:
		1	
	shell:
		"cat {input} | cut -f 1-10 > {output}"

# Convert to CSVs for uploading
rule convert_to_csv_singleton:
	input:
		reduced=os.path.join(config['dir']['reduced'], "{seed}_pop{popnum}_{samplesize}_{drawnum}.singletons.reduced.vcf")
	output:
		csv=os.path.join(config['dir']['singleton_csvs'], "{seed}_pop{popnum}_{samplesize}_{drawnum}.singletons.reduced.csv")
	group:
		"all_grouped"
	threads:
		1
	params:
		exec=config['app']['csv_converter']
	shell:
		"python {params.exec} --input {input} --output {output}"

# Reduce allel filtered vcf
rule reduce_vcf:
	input:
		vcf_sampled_af=os.path.join(config['dir']['af_vcf'], "{seed}_pop{popnum}_{samplesize}_{drawnum}.AF.recode.vcf")
	output:
		vcf_sampled_af_reduce=os.path.join(config['dir']['reduced'], "{seed}_pop{popnum}_{samplesize}_{drawnum}.AF.recode.reduced.vcf")
	group:
		"all_grouped"
	threads:
		1
	shell:
		"cut -f 1-10 {input} > {output}"

# Convert vcfs to bed files
rule vcf_to_bed:
	input:
		vcf_sampled_af_reduce=os.path.join(config['dir']['reduced'], "{seed}_pop{popnum}_{samplesize}_{drawnum}.AF.recode.reduced.vcf")
	output:
		bed_file=os.path.join(config['dir']['beds'], "{seed}_pop{popnum}_{samplesize}_{drawnum}.AF.recode.reduced.positions.bed")
	group:
		"all_grouped"
	threads:
		1
	shell:
		"""awk 'BEGIN{{OFS="\\t"}} ! /\#/ {{print $1, $2-1, $2}}' {input} > {output}"""

# Creates a population specific bed which contains mutations that are exclusive to that population
rule create_popspec_bed:
	input:
		bed_file=expand(config['dir']['beds'] + "{{seed}}_pop{popnum}_{{samplesize}}_{{drawnum}}.AF.recode.reduced.positions.bed", popnum=list(range(0,4)))
	output:
		pop_spec=os.path.join(config['dir']['pop_spec'], "{seed}_pop{popnum}_{samplesize}_{drawnum}.AF.recode.reduced.positions.popspec.bed")
	group:
		"all_grouped"
	threads:
		1
	params:
		exec=config['app']['bedtools']
	run:
		input_files = []
		popspec = ""
		for i in input:
			if ("pop" + wildcards.popnum) not in i:
				input_files.append(i)
			else:
				popspec=i
		shell_command="{exec} intersect -a {in_pop} -b {ex_pop} -v > {out_file}".format(exec=params.exec, in_pop=popspec, ex_pop=' '.join(input_files),out_file=output)
		print(shell_command) 
		shell(shell_command)

# Add headers to bed files
rule add_bed_header:
	input:
		pop_spec=os.path.join(config['dir']['pop_spec'], "{seed}_pop{popnum}_{samplesize}_{drawnum}.AF.recode.reduced.positions.popspec.bed")
	output:
		pop_spec=os.path.join(config['dir']['pop_spec'], "{seed}_pop{popnum}_{samplesize}_{drawnum}.AF.recode.reduced.positions.header.bed")
	group:
		"all_grouped"
	threads:
		1
	shell:
		"""sed 1i"chr\\tstart\\ttend" {input} > {output}"""
	
# Remove non-population specific mutations
rule remove_nonpopspec_mut:
	input:
		vcf_sampled_af_reduce=os.path.join(config['dir']['reduced'], "{seed}_pop{popnum}_{samplesize}_{drawnum}.AF.recode.reduced.vcf"),
		pop_spec=os.path.join(config['dir']['pop_spec'], "{seed}_pop{popnum}_{samplesize}_{drawnum}.AF.recode.reduced.positions.header.bed")
	output:
		pop_spec_vcf=os.path.join(config['dir']['pop_spec_vcf'], "{seed}_pop{popnum}_{samplesize}_{drawnum}.AF.recode.reduced.popspec.recode.vcf")
	group:
		"all_grouped"
	threads:
		1
	params:
		exec=config['app']['vcftools'],
		arguments="--recode --recode-INFO-all"
	shell:
		"{params.exec} --vcf {input.vcf_sampled_af_reduce} --bed {input.pop_spec} {params.arguments} -c > {output}"

# Convert to CSVs for uploading
rule convert_to_csv:
	input:
		pop_spec_vcf=os.path.join(config['dir']['pop_spec_vcf'], "{seed}_pop{popnum}_{samplesize}_{drawnum}.AF.recode.reduced.popspec.recode.vcf")
	output:
		csv=os.path.join(config['dir']['csvs'], "{seed}_pop{popnum}_{samplesize}_{drawnum}.AF.recode.reduced.popspec.recode.csv")
	group:
		"all_grouped"
	threads:
		1
	params:
		exec=config['app']['csv_converter']
	shell:
		"python {params.exec} --input {input} --output {output}"

# Upload all csvs
rule upload_csv:
	input:
		csv=os.path.join(config['dir']['csvs'], "{seed}_pop{popnum}_{samplesize}_{drawnum}.AF.recode.reduced.popspec.recode.csv")
	output:
		uploaded=os.path.join(config['dir']['uploaded'], "{seed}_pop{popnum}_{samplesize}_{drawnum}.AF.recode.reduced.popspec.recode.csv")
	group:
		"convert_submit"
	threads:
		1
	params:
		exec=config['app']['uploader']
	shell:
		"{params.exec} --input {input} && cp {input} {output}"
