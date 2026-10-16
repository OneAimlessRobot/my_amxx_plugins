#!/bin/bash

#tar -cJvf "${hero_pack_name}${backup_script_extension}" ./"${hero_pack_folder_name}"/*


script_name="make_hero_pack.sh"

the_dir="/mnt/REBORN/half_life_stuff/Half-Life/cstrike"

#use this for xz
#backup_script_extension=".tar.xz"

#use this for bzip2
backup_script_extension=".bz2"

github_backup_loc8ion="/mnt/FASTstorage/GithubFAST/my_amxx_plugins"

backup_locations=("/mnt/FASTstorage/GithubFAST/my_amxx_plugins" "/mnt/SUPER_CAVALEIRO/progsBackup" "/mnt/REBORN/FASTERprogs" "/mnt/FASTstorage/FASTprogs")

subfolders_of_backup=("models/shmod" "models/player" "sound/shmod" "media" "SAVE" "sound/misc"  "sound/QTM_CodMod"  "sound/weapons" "sound/warcraft3" "sound/zombie_plague" "models/kickball" "sprites" "addons" "configs" "scripts" "gfx" "txtfiles")

num_of_subfolders_of_backup=${#subfolders_of_backup[@]}

num_of_backup_locations=${#backup_locations[@]}

hero_pack_folder_name="superhero_pack_folder"

hero_pack_name="superhero_pack"


remove_ztmp_files(){
	
	rm -rfv $(find "{the_dir}" -name "*.ztmp")	

}
remove_bzip2_files(){
	
	rm -rfv $(find "{the_dir}" -name "*.bz2")	

}
remove_current_backup_folder_and_archive(){

	rm -rfv "${hero_pack_name}${backup_script_extension}"
	rm -rfv "./${hero_pack_folder_name}"

}
remove_folder_from_backup_locations(){

	for(( i=0; i< num_of_backup_locations; i++ ))
	do
		rm -rfv "${backup_locations[$i]}/${hero_pack_name}${backup_script_extension}"&
		rm -rfv "${backup_locations[$i]}/${hero_pack_folder_name}"&
	done
	wait

}
copy_folder_to_backup_locations(){

	for(( i=0; i< num_of_backup_locations; i++ ))
	do
		cp -rfv "${hero_pack_name}${backup_script_extension}" "${backup_locations[$i]}"&
		cp -rfv  "${hero_pack_folder_name}" "${backup_locations[$i]}"&
	done
	wait
	rm -rfv "/mnt/FASTstorage/GithubFAST/my_amxx_plugins/${hero_pack_name}${backup_script_extension}"

}
make_empty_pack_folder(){
	mkdir -p ./${hero_pack_folder_name}
	for(( i=0; i< num_of_subfolders_of_backup; i++ ))
	do
		mkdir -p "./${hero_pack_folder_name}/${subfolders_of_backup[$i]}"
	done
}
copy_stuff_to_pack_folder(){
	cp -rfv "${script_name}" "./scripts/${script_name}"
	read
	cp -rfv "./scripts/${script_name}" "${hero_pack_folder_name}"&
	cp -rfv *.gam "txtfiles"&
	cp -rfv ../*.sh "scripts"&
	cp -rfv ../*.debug_cmd "scripts"&
	cp -rfv *.cfg "configs"&
	cp -rfv mapcycle.txt "txtfiles"&
	cp -rfv motd.txt "txtfiles"&
	cp -rfv condump*.txt "txtfiles"&
	wait
	for(( i=0; i< num_of_subfolders_of_backup; i++ ))
	do
		cp --parents  -rfv  "./${subfolders_of_backup[$i]}" "./${hero_pack_folder_name}"/&
	done
	wait
	rm -rfv $(find "${hero_pack_folder_name}" -name "*.ztmp")
	rm -rfv $(find "${hero_pack_folder_name}" -name "*.bz2")
}

pushd $the_dir

remove_ztmp_files

remove_bzip2_files

remove_current_backup_folder_and_archive

make_empty_pack_folder

remove_folder_from_backup_locations

#this one makes it an xz compressed archive.
#much more compression. but much slower
#tar -cJvf "${hero_pack_name}${backup_script_extension}" ./"${hero_pack_folder_name}"/*

#this one makes it an bzip2 compressed archive.
#much less compression. but much faster
copy_stuff_to_pack_folder

tar -cjvf "${hero_pack_name}${backup_script_extension}" "./${hero_pack_folder_name}"

copy_folder_to_backup_locations

pushd "${github_backup_loc8ion}" && bash update*sh && popd
