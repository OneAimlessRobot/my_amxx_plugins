#!/bin/bash



while IFS= read -r filename
do
	mv "${filename}" "sh_${filename}"


done < <(find * -name  "*.cfg")
