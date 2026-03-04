#!/bin/bash

#tar -cJvf "${hero_pack_name}${backup_script_extension}" ./"${hero_pack_folder_name}"/*


script_name="make_hero_pack.sh"

the_dir="/mnt/REBORN/half_life_stuff/Half-Life/cstrike"

backup_script_extension=".tar.xz"

backup_locations=("/mnt/FASTstorage/GithubFAST/my_amxx_plugins" "/mnt/SUPER_CAVALEIRO/progsBackup" "/mnt/REBORN/FASTERprogs" "/mnt/FASTstorage/FASTprogs")

subfolders_of_backup=("models/shmod" "models/player" "sound/shmod"  "sound/QTM_CodMod"  "sound/weapons" "sound/warcraft3" "sound/zombie_plague" "models/kickball" "sprites" "addons" "configs" "scripts" "gfx")

num_of_subfolders_of_backup=${#subfolders_of_backup[@]}

num_of_backup_locations=${#backup_locations[@]}

pushd $the_dir

hero_pack_folder_name="superhero_pack_folder"

hero_pack_name="superhero_pack"

remove_current_backup_folder_and_archive(){
	
	rm -rfv "${hero_pack_name}${backup_script_extension}"
	rm -rfv "./${hero_pack_folder_name}"
	
}
remove_folder_from_backup_locations(){
	
	for(( i=0; i< num_of_backup_locations; i++ ))
	do
		rm -rfv "${backup_locations[$i]}/${hero_pack_folder_name}"&
	done
	wait
	
}
copy_folder_to_backup_locations(){
	
	for(( i=0; i< num_of_backup_locations; i++ ))
	do
		cp -rfv  "${hero_pack_folder_name}" "${backup_locations[$i]}"&
	done
	wait
	
}
make_empty_pack_folder(){
	mkdir -p ./${hero_pack_folder_name}
	for(( i=0; i< num_of_subfolders_of_backup; i++ ))
	do
		mkdir -p "./${hero_pack_folder_name}/${subfolders_of_backup[$i]}"
	done
}
copy_stuff_to_pack_folder(){
	cp -rfv "./scripts/${script_name}" "${hero_pack_folder_name}"&
	cp -rfv *.gam "${hero_pack_folder_name}"&
	cp -rfv ../*.sh "scripts"&
	cp -rfv ../*.debug_cmd "scripts"&
	cp -rfv *.cfg "configs"&
	wait
	for(( i=0; i< num_of_subfolders_of_backup; i++ ))
	do
		cp --parents  -rfv  "./${subfolders_of_backup[$i]}" "./${hero_pack_folder_name}"/&
	done
	wait
}
remove_current_backup_folder_and_archive

make_empty_pack_folder

remove_folder_from_backup_locations

copy_stuff_to_pack_folder

tar -cJvf "${hero_pack_name}${backup_script_extension}" ./"${hero_pack_folder_name}"/*

copy_folder_to_backup_locations
