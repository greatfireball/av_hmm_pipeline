#!/bin/bash

# Build a hmm for each file ending in .fa(sta) from alignment folder
for i in $(find alignments/ -type f | grep -P "\.fa[^.]*$")
do
    date +"[%Y-%m-%d %H:%M:%S] Started '${i}'"

    # generate the hmm name
    HMMNAME=$(basename ${i} | sed 's/\.fa[^.]*//').hmm

    # build the hmm
    hmmbuild hmms/"${HMMNAME}" "${i}"

    date +"[%Y-%m-%d %H:%M:%S] Finished '${i}'"
done

# Search each hmm against each file from assembly folder
# Get each hmm created in first step
for hmmfile in $(find hmms/ -type f -name "*.hmm")
do
    # run hmmsearch for each file in assemblies ending in *.fa...
    for assemblyfile in $(find assemblies/ -type f | grep -P "\.fa[^.]*$")
    do
	date +"[%Y-%m-%d %H:%M:%S] Started hmmseach for '${hmmfile}' vs '${assemblyfile}'"
	OUTFILE_BASENAME=hmmsearch/$(basename "${hmmfile}")_vs_$(basename "${assemblyfile}")
	hmmsearch \
	    --tblout "${OUTFILE_BASENAME}".tblout \
	    --domtblout "${OUTFILE_BASENAME}".domtblout \
	    --pfamtblout "${OUTFILE_BASENAME}".pfamtblout \
	    "${hmmfile}" \
	    "${assemblyfile}" \
	    > "${OUTFILE_BASENAME}".out
	date +"[%Y-%m-%d %H:%M:%S] Finished hmmseach for '${hmmfile}' vs '${assemblyfile}'"

	date +"[%Y-%m-%d %H:%M:%S] Starting sequence extraction for '${hmmfile}' vs '${assemblyfile}'"
	grep -v "^#" "${OUTFILE_BASENAME}".tblout | \
	    cut -f 1 -d " " | sort | uniq | \
	    SeqFilter/bin/SeqFilter -o "${OUTFILE_BASENAME}".fasta --ids - "${assemblyfile}"
	date +"[%Y-%m-%d %H:%M:%S] Finished sequence extraction for '${hmmfile}' vs '${assemblyfile}'"
    done
done
