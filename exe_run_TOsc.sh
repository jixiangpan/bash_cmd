#!/bin/bash
#
#     source exe.sh begin_number end_number
#
# $1: file_begin, eg. 10
# $2: file_end, eg. 100

# gt >=, lt <=, eq ==, ne !=, ge >=, le <=

bins_xlow=$1
bins_xhgh=$2

for((idx=$bins_xlow; idx<=$bins_xhgh; idx++))
do
    for((jdx=1; jdx<=40; jdx++))
    do
	file_OscPars_AA=./configurations/zz_OscPars_${idx}_${jdx}.txt
	if [ -f $file_OscPars ]
	then
	    echo "------------------------------------------------------>" processing $file_OscPars_AA
	    cp $file_OscPars_AA ./configurations/osc_parameter.txt
	    
	    rm -f ./hist_rootfiles/*.root
	    rm -f ./hist_rootfiles/XsFlux/*.root
	    rm -f ./mc_stat/*.log
	    
	    ##########

	    echo " ---------> at step: ./convert_histo.pl 2"
	    
	    ./convert_histo.pl 2
	    lines=`ps aux | grep convert_checkout_hist | grep xji | grep bbb | wc -l`
	    while [ $lines -eq 0 ] ### make sure the it starts to run
	    do
		sleep 0.01s
		lines=`ps aux | grep convert_checkout_hist | grep xji | grep bbb | wc -l`
	    done
	    
	    while [ $lines -ge 1 ]
	    do
		echo " ---> Processing $idx $jdx  ./convert_histo.pl 2"
		sleep 2s
		lines=`ps aux | grep convert_checkout_hist | grep xji | grep bbb | wc -l`
	    done
	    
	    ##########
	    
	    lines=`ls -l ./hist_rootfiles/ | grep root | wc -l`
	    while [ $lines -lt 4 ]
	    do
		sleep 0.5s
		lines=`ls -l ./hist_rootfiles/ | grep *.root | wc -l`
	    done

	    echo " ---------> at step: merge_hist -r0 -l1"
	    
	    merge_hist -r0 -l1

	    ##########

	    echo " ---------> at step: ./run_xf_sys.pl 1"
	    
	    ./run_xf_sys.pl 1	    	    
	    lines=`ps aux | grep xf_cov_matrix | grep xji | grep bbb | wc -l`
	    while [ $lines -eq 0 ] ### make sure the it starts to run
	    do
		sleep 0.01s
		lines=`ps aux | grep xf_cov_matrix | grep xji | grep bbb | wc -l`
	    done
	    
	    while [ $lines -ge 1 ]
	    do
		echo " ---> Processing $idx $jdx  ./run_xf_sys.pl 1"
		sleep 2s
		lines=`ps aux | grep xf_cov_matrix | grep xji | grep bbb | wc -l`
	    done
	    
	    ##########

	    echo " ---------> at step: ./run_mc_stat.pl"
	    
	    ./run_mc_stat.pl	    
	    lines=`ps aux | grep merge_hist | grep xji | grep bbb | wc -l`
	    while [ $lines -eq 0 ] ### make sure the it starts to run
	    do
		sleep 0.01s
		lines=`ps aux | grep merge_hist | grep xji | grep bbb | wc -l`
	    done
	    
	    while [ $lines -ge 1 ]
	    do
		echo " ---> Processing $idx $jdx  ./run_mc_stat.pl"
		sleep 2s
		lines=`ps aux | grep merge_hist | grep xji | grep bbb | wc -l`
	    done

	    ##########
	    
	    dir_temp=result_syst_${idx}_${jdx}
	    mkdir $dir_temp

	    mv merge.root $dir_temp
	    cp -r ./hist_rootfiles/XsFlux $dir_temp
	    cp -r ./mc_stat $dir_temp

	    rm -f ./hist_rootfiles/*.root
	    rm -f ./hist_rootfiles/XsFlux/*.root
	    rm -f ./mc_stat/*.log
	fi
    done
done
