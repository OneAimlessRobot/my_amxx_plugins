#!/bin/bash



while IFS= read -r filename
do
 echo "echo successfully executed ${filename}!" >> "${filename}"


done < <(find * -name  "sh_*.cfg")
