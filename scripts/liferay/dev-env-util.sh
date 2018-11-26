#!/bin/bash

projects_home='/home/dev/projects/';

lr_bundles_base_path='/home/dev/version/bundle/liferay/'
lr_bundles_base_urls='https://sourceforge.net/projects/lportal/files/Liferay%20Portal/'
lr_bundles_config_files='/home/dev/version/bundle/liferay/config-files'

#
# Definizione delle directory di progetto 
#
directories=('notes' 'workspaces' 'documents' 'bundles')

#
# Definizione file notes
#
notes=('notes.md' 'enviroments.md')

#
# Definizione bundles liferay
#
lr_bundles=('7.0-ga6' '7.0-ga7' '7.1.0-ga1' '7.1.1-ga2')
lr_bundles_names=('liferay-ce-portal-tomcat-7.0-ga6-20180320170724974.zip' 'liferay-ce-portal-tomcat-7.0-ga7-20180507111753223.zip' 'liferay-ce-portal-tomcat-7.1.0-ga1-20180703012531655.zip')

echo "### Dev Environment Tools ###"
echo "Dev Environment Creation... "
echo "Insert Project Name (new-project):"
read project_name

if [ -e "$project_name" ]; then
	project_name='new-project'
fi

echo "Select Liferay bundle version (Lifera CE 7.0 ga7):"
for i in "${!lr_bundles[@]}"; do
	echo "$i: ${lr_bundles[$i]}" 
done
read lr_bundle_index

if [ -e "$lr_bundle_index" ]; then
	lr_bundle_index='1'
fi

project_home=$projects_home$project_name
lr_home=$project_home'/bundles/liferay-ce-portal-'${lr_bundles[$lr_bundle_index]}

createProjectStructure() {

	echo "Creating project folder: $project_home"

	#
	# Creo la cartella home del singolo di processo
	#
	mkdir $project_home

	#
	# Vengono create le directory generiche del progetto
	#
	for i in "${directories[@]}"; do
		mkdir "$project_home/$i"
	done
}

createNotesFiles() {

	#
	# Vengono creati i file generici per gli appunti
	#
	for i in "${notes[@]}"; do
		touch "$project_home/notes/$i"
	done
}

setLiferayBundle() {

	lr_bundles_path=$lr_bundles_base_path${lr_bundles_names[$lr_bundle_index]}

	echo 'Set Liferay bundle:'$lr_bundles_path

	if [ -e "$lr_bundles_path" ]; then
		unzipLiferayBundle && setConfigurationFile
	elif [ -n "$lr_bundles_path" ]; then
		echo 'Downlaod Liferay Bundle'
	fi
}

unzipLiferayBundle() {

	if [ -d "$lr_home" ]; then
		echo 'Bundle already exist'
		exit 0
	fi
	
	echo 'Copy and Unzip Liferay Bundle'
	unzip $lr_bundles_path -d $project_home/bundles &> /dev/null

}

#
# La funzione imposta le configurazioni di default:
# - copia dei file di configurazione base di liferay
#    - configurazioni di sviluppo: portal-developer.properties
#	 - configurazioni di base di liferay: portal-runtime.properties
#	 - configurazioni di connettività alla base dati: portal-database.properties
# - copia del file setenv.sh nel quali vengoon impostate le configurazioni 
#   di avvio di liferay:
#    - tunining della jvm (xms, xmx)
#	 - configurazione debuging
#
setConfigurationFile() {
	
	echo 'Setting configuration files:'$lr_home

	cp $lr_bundles_config_files/portal-* $lr_home
	cat > $lr_home/portal-ext.properties << _EOF_
include-and-override=$lr_home/portal-developer.properties
include-and-override=$lr_home/portal-runtime.properties
include-and-override=$lr_home/portal-database.properties
_EOF_
	
	cp $lr_bundles_config_files/setenv.sh $lr_home/tomcat-*/bin

}

#createProjectStructure
#createNotesFiles
setLiferayBundle