#!/bin/bash

#Controllo necessario per verificare che l'utente abbia richiamtato lo script con tutti gli argomenti necessari.
if [ -z "$1" -o -z "$2" -o -z "$3" ]
then
	echo
	echo 'Errore! Uno o più parametri mancanti!' >&2
	echo "La sintassi corrretta è: $0 <tipo_backup> <directory_sorgente> <directory_destinazione>" >&2
	exit 8
fi

#Controlli necessari a verificare la disponibilità della directory sorgente
nomiCartelleBackup=`ls $3`
if [ $? -gt 0 ]
then
	echo
	echo "Attenzione, directory di destinazione non disponibile!" >&2
	exit 3
fi

nomeCartellaBackup=`date +%Y%m%d%H%M`

#Ottenimento data backup completo
if [ $1 == 'completo' ]
then
	ultimaData="1970-01-01-00:00"
else
	ultimaData="1970-01-01-00:00"
	#Ottenimento data backup incrementale
	if [ $1 == 'incrementale' ]
	then
		for i in $nomiCartelleBackup
		do
			dataCartella="${i:0:4}-${i:4:2}-${i:6:2}-${i:8:2}:${i:10:2}"
			if [[ "$dataCartella" > "$ultimaData" ]]
			then
				ultimaData=$dataCartella
			fi
		done
		if [[ $ultimaData == '1970-01-01-00:00' ]]
		then
			echo
			echo "Attenzione! Nella directory di destinazione non è stato trovato alcun backup! Eseguire un backup, quindi riprovare!" >&2
			exit 6
		fi
	else
		#Ottenimento data backup differenziale
		if [ $1 == 'differenziale' ]
		then
			for i in $nomiCartelleBackup
			do
				dataCartella="${i:0:4}-${i:4:2}-${i:6:2}-${i:8:2}:${i:10:2}"
				tipoBackup=${i:13:8}
				if [ $tipoBackup == 'completo' ]
				then
					if [[ "$dataCartella" > "$ultimaData" ]]
					then
						ultimaData=$dataCartella
					fi
				fi
			done
			if [[ $ultimaData == '1970-01-01-00:00' ]]
			then
				echo
				echo "Attenzione! Nella directory di destinazione non è stato trovato alcun backup completo! Eseguire un backup completo, quindi riprovare!" >&2
				exit 5
			fi
		else
			echo
			echo "Attenzione! Tipo di backup non riconosciuto!" >&2
			exit 7
		fi
	fi
fi


`./copia_file.sh $1 $2 $3 $ultimaData $nomeCartellaBackup`

controllo=$?
#Controlli necessari ad accertarsi della presenza di errori durante la copia dei file
if [ $controllo -gt 0 ]
then
	if [ $controllo -eq 1 ]
	then
		echo
		echo "Attenzione, directory sorgente non disponibile!" >&2
		exit 1
	else
		if [ $controllo -eq 2 ]
		then
			echo
			echo "Attenzione! La directory sorgente è vuota!" >&2
			exit 2
		else
			if [ $controllo -eq 4 ]
			then
				echo
				echo "Attenzione! Si sono verificati degli errori durante la copia dei file!"
				exit 4
			fi
		fi
	fi
else
	echo
	echo "Backup di tutti i file avvenuto con successo!"
	exit 0
fi





