instfix -i > newpatch
awk '/AIX_ML/ {print $4}' newpatch > patch_name
awk '/AIX_ML/ {print}' patch_name > patch_names
