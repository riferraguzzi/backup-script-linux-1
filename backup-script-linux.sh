#!/bin/bash

#Controllo necessario per verificare che l'utente abbia richiamtato lo script con tutti gli argomenti necessari.
if [ -z "$1" -o -z "$2" -o -z "$3" ]
then
	echo
	echo "Attenzione! Argomenti non sufficienti indicare, in ordine, tipo di backup, directory sorgente, directory di destinazione"
	exit 8
fi
#Salvataggio nella variabile "elencoFile" dei nomi dei file presenti nella directory sorgente.
elencoFile=`ls $2`
#Controllo necessario per verificare la disponibilità della directory sorgente.
if [ $? -gt 0 ]
then
	echo
	echo "Attenzione! Directory sorgente non disponibile!"
	exit 1
fi
#Controllo necessario per verificare se la directory sorgente è vuota.
if [ `ls $2 | wc -l` -eq 0 ]
then
	echo
	echo "Attenzione! La directory sorgente è vuota!"
	exit 2
fi
#Salvataggio nella variabile "elencoDirectory" dell'elenco delle directory di backup presenti nella directory di destinazione.
elencoDirectory=`ls $3`
if [ $? -gt 0 ]
then
	echo "Attenzione! Directory di destinazione non disponibile!"
	exit 3
fi
#Ottenimento dell'ultima data di backup.
if [ $1 == 'completo' ]
then
	#Nel caso in il backup scelto sia completo, alla variabile "ultima_data" verrà assegnato valore 0, in modo da includere nel backup tutti i file 
	#creati o modificati successivamente al 1/1/1970 (tutti i file).
	ultima_data=0
else
	#Nel caso in cui il backup scelta sia incrementale, alla variabile "ultima_data" verranno assegnati i secondi passati tra il 1/1/1970 e la data di
	#creazione o modifica dell'ultima cartella di backup.
	if [ $1 == 'incrementale' ]
	then
		elencoDirectory=`ls $3`
		ultima_data=0
		for i in $elencoDirectory
		do
			dataIndice=`stat -c %Y $3/$i`
			if [ $dataIndice -gt $ultima_data ]
			then
				ultima_data=$dataIndice
			fi
		done
			if [ $ultima_data -eq 0 ]
				then
					echo
					echo "Errore! Nella directory di destinazione non è stato trovato alcun backup! Eseguire un backup, quindi riprovare!"
					exit 6
				fi
		else
			#Nel caso in cui il backup scelta sia incrementale, alla variabile "ultima_data" verranno assegnati i secondi passati tra il 1/1/1970 e la data di
			#creazione o modifica della cartella contenente l'ultimo backup completo effettuato.
			if [ $1 == 'differenziale' ]
			then
				ultima_data=0
				for i in $elencoDirectory
				do 
					if [ ${i:13:8} == 'completo' ]
					then
						dataIndice=`stat -c %Y $3/$i`
						if [ $dataIndice -gt $ultima_data ]
						then
							ultima_data=$dataIndice
						fi
					fi
				done
				if [ $ultima_data -eq 0 ]
				then
					echo
					echo "Errore! Nella directory di destinazione non è stato trovato alcun backup completo! Eseguire un backup completo, quindi riprovare!"
					exit 5
				fi
			else
				echo
				echo "Errore! Tipo di backup non riconosciuto!"
				exit 7
			fi
		fi
fi
#Salvataggio in due variabili dei nomi dei file da copiare e del nome della cartella dove verrà salvato il backup.
nomiFileDaCopiare=`ls $2`
nomeCartellaBackup=`date +%Y%m%d%H%M`
#Inizializzazione dei contatori necessari al calcolo del totale dei file da copiare, dei file copiati e dei file per cui sono stati evidenziati errori durante
#la copia.
total=0
success=0
err=0
mkdir $3/${nomeCartellaBackup}_$1
#Ciclo necessario all'esecuzione del backup.
for i in $nomiFileDaCopiare
do
	data_file=`stat -c %Y $2/$i`
	if [ $data_file -gt $ultima_data ]
	then
		total=$((total+1))
		cp $2/$i $3/${nomeCartellaBackup}_$1
		if [ $? -gt 0 ]
		then
			echo 
			echo "Impossibile eseguire il backup di $i" >&2
			err=$((err+1))
		else
			echo
			echo "Backup di: $i avvenuto con successo"
			success=$((success+1))
		fi
	fi
done
#Nel caso in cui il numero dei file totali, memorizzato nella variabile "total", alla fine del ciclo sia pari a 0 verrà visualizzato un avviso e lo script
#restituirà l'exit code 9.
if [ $total -eq 0 ]
then
	echo
	echo "Attenzione! Nessun file cambiato dall'ultimo backup, backup non necessario"
	rmdir $3/${nomeCartellaBackup}_$1
	exit 9
#In caso contrario verrà visualizzato il report del backup.
else
	echo
	echo "Backup Completato, numero di file copiati: $success su $total, numero di file per cui non è stato possibile eseguire il backup: $err"
	#Nel caso in cui tutti i file siano stati copiati con successo lo script restituirà exit code 0.
	if [ $err -eq 0 ]
	then
		exit 0
	else
		#Nel caso in cui si siano evidenziati errori durante la copia di alcuni file lo script restituirà exit code 4.
		exit 4
	fi
fi

