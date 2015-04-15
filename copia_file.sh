#!/bin/bash

#Controllo necessario a verificare la disponibilità della directory sorgente
nomiFileDaCopiare=`ls $2`
if [ $? -gt 0 ]
then
	exit 1
fi

#Controllo necessario a verificare se la directory sorgente è vuota
if [ `ls $2 | wc -l` -eq 0 ]
then
	exit 2
fi

total=0
success=0
err=0


mkdir $3/$5_$1

#Ciclo necessario alla copia dei file
for i in $nomiFileDaCopiare
do
	dataFile=`stat -c %y $2/$i`
	data=${dataFile:0:10}
	ora=${dataFile:11:5}
	dataFile="${data}-${ora}"
	tipoFile=`stat -c %F $2/$i`
	if [[ $tipoFile == "directory" ]]
	then
		if [ `ls $2/$i | wc -l` -gt 0 ]
		then
			mkdir $3/$5_$1/$i
		`	./copia_file.sh $1 $2/$i $3/$5_$1/$i $4 $5`
		fi
	else
		if [[ $dataFile > $4 ]]
		then
			total=$((total+1))
			cp $2/$i $3/$5_$1
			if [ $? -gt 0 ]
			then
				echo "Attenzione! Backup di $i non riuscito!" >&2
				err=$((err+1))
			else
				success=$((success+1))
			fi
		fi
	fi
done

if [ $err -gt 0 ]
then
	exit 4
fi

if [ $total -eq 0 ]
then
	exit 9
fi





	


	
	
	
	