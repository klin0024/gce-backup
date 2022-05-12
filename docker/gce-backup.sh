#!/bin/bash

#instances="docker:us-central1-a win2016:us-central1-a"
#project=gcp-expert-sandbox-allen
#location=us-central1
#retainDays=7

currentDatatime=$(date +"%Y-%m-%d-%H-%M")
retainDatatime=$(date +"%Y-%m-%d" --date="$[1-${retainDays}]days")
#retainDatatime=$(date +"%Y-%m-%dT%H:%M" --date="$[1-${retainDays}]days")

getInstance(){
	echo $1|cut -d : -f 1
}

getZone(){
	echo $1|cut -d : -f 2
}

getSourceInstance(){
	echo "https://www.googleapis.com/compute/v1/projects/${project}/zones/${zone}/instances/${instance}"
}

getExpirationMachineImage(){
	gcloud compute machine-images list --project=${project} --format="get(name)" --filter="sourceInstance=$1 AND creationTimestamp<${retainDatatime}" 
}

createMachineImage(){
	gcloud compute machine-images create ${instance}-${currentDatatime} --project=${project} --storage-location=${location} --source-instance=${instance} --source-instance-zone=${zone}
}

deleteMachineImage(){
	echo Y|gcloud compute machine-images delete $1 --project=${project}
}


main(){
	
	for i in ${instances}; do
		instance=$(getInstance $i)
		zone=$(getZone $i)
		createMachineImage
		if [[ $? -ne 0 ]]; then
			echo "instance not found"
    		continue
  		fi

		for j in $(getExpirationMachineImage $(getSourceInstance)); do
			deleteMachineImage $j
		done
	done	

}

main