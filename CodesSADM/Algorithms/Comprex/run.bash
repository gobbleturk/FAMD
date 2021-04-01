#!/bin/bash



inplist=(shuttle)
len=${#inplist[*]}
numbins=10
eps=0.01
echo "The array has $len members. They are:"


	i=0
	while [ $i -lt $len ]; do
		matlab -r "buildFeatureMatrixNML ('data/${inplist[$i]}/${inplist[$i]}2class.txt', ${numbins}, ${eps}, ${eps});  x = textread('data/${inplist[$i]}/${inplist[$i]}2class.txt_${numbins}nmlbins_eps.txt'); [cost CT] =  buildModelVar (x, '${inplist[$i]}${numbins}nmlbinsVar_avg', 1); exit"
		matlab -r "computeCompressionScoresVar( 'data/${inplist[$i]}/label2class.txt','data/${inplist[$i]}/${inplist[$i]}2class.txt_${numbins}nmlbins_eps.txt','CT_${inplist[$i]}${numbins}nmlbinsVar_avg.mat'); exit"
		let i++		
	done	

