# shellscripts
CI voor armoedzaaiers. (uitgaande dat je docker-compose gebruikt i.c.m. GCP voor je container registry en GKE)

### Deploy
Om makkelijker een nieuwe versie naar GCP te kunnen sturen gebruiken we een script. Dit script zorgt dat
1. de container wordt gemaakt (indien nodig)
1. de container naar GCP wodt gekopieerd
1. de betreffende service in GCP wordt herstart met de nieuwe container  
*deze herstart gebeurt op een "veilige" manier ("rolling update"). De services blijven dus beschikbaar.*  

Om dit script te installeren:
1. Open de terminal en geef commando:  
`sudo curl https://raw.githubusercontent.com/lvansnippenburg/shellscripts/master/deploy.sh -o /usr/local/bin/deploy`  
Dit kopieert het shell script naar de directory /usr/local/bin
1. Zorg dat je het script ook uit kunt voeren:  
`sudo chmod 0755 /usr/local/bin/deploy`  

En dat zou genoeg moeten zijn. Om het script uit te voeren ga je naar de directory waar je "docker-compose.yml" bestand staat - dat is dus in principe de directory van je project. Dan geef je commando:  
`deploy`

Het script zoekt eerst in je docker-compose.yml naar de regel:  
`x-deployment: naam-van-deployment`  
Waar 'naam-van-deployment' de deployment naam is van je workload in GKE. Vervolgens zal een build worden gedaan als je dat wilt (er komt een vraag hiervoor) en zal de container naar de Registry worden gepushed. Tenslotte wordt de deployment ge-update. That's it.
