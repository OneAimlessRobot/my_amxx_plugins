#!/bin/sh

echo "rehldsupdatetool v0.0.2"

if [ -z "$1" ] || [ -z "$2" ]; then
	echo "Usage: ./rehldsupdatetool.sh <game> <directory>"
	echo "Games: cstrike, czero, dmc, dod, gearbox, ricochet, tfc, valve"
	exit 1
fi

GAME="$1"
MOD=""
HLDS_DIR="$(readlink -mf "$2")"

case $GAME in
	cstrike | valve)
		;;
	czero | dmc | dod | gearbox | ricochet | tfc)
		MOD=1
		;;
	*)
		echo "rehldsupdatetool: Invalid game: "$1""
		echo "rehldsupdatetool: Valid games are: cstrike, czero, dmc, dod, gearbox, ricochet, tfc, valve"
		exit 1
		;;
esac

if [ ! -z "$MOD" ]; then
	if command -v unzip 2>&1 >/dev/null; then
		TOOL="unzip -oq mod_"$GAME".zip -d "$HLDS_DIR""
	elif command -v bsdtar 2>&1 >/dev/null; then
		TOOL="bsdtar -C "$HLDS_DIR" -xf mod_"$GAME".zip"
	elif command -v 7z 2>&1 >/dev/null; then
		TOOL="7z x -y -aoa -bso0 -bsp0 -o"$HLDS_DIR" mod_"$GAME".zip"
	elif command -v 7za 2>&1 >/dev/null; then
		TOOL="7za x -y -aoa -bso0 -bsp0 -o"$HLDS_DIR" mod_"$GAME".zip"
	else
		echo "rehldsupdatetool: No unzip tool found, need one of: 'unzip', 'bsdtar', or '7z'. Install one of them and re-run rehldsupdatetool."
		exit 1
	fi
fi

if [ -z "$HLDS_DIR" ]; then
	echo "rehldsupdatetool: Invalid directory: "$2""
	exit 1
fi

if ! mkdir -p "$HLDS_DIR"; then
	echo "rehldsupdatetool: Could not create directory: "$HLDS_DIR""
	exit 1
fi

echo "Installing to: "$HLDS_DIR""

if command -v wget 2>&1 >/dev/null; then
	if [ ! -s hlds_linux_8684.tar.gz ]; then
		echo "Downloading hlds_linux_8684.tar.gz ..." && \
		wget -q --show-progress -O hlds_linux_8684.tar.gz http://ftp.taco.cab/rehlds/hlds_linux_8684.tar.gz
	fi && \
	echo "Downloading rehlds_linux.tar.gz ..." && \
	wget -q --show-progress -O rehlds_linux.tar.gz http://ftp.taco.cab/rehlds/rehlds_linux.tar.gz && \
	echo "Downloading versioninfo.txt ..." && \
	wget -q --show-progress -O versioninfo.txt http://ftp.taco.cab/rehlds/versioninfo.txt && \
	if [ ! -z "$MOD" ]; then
		echo "Downloading mod_"$GAME".zip ..." && \
		wget -q --show-progress -O mod_"$GAME".zip http://ftp.taco.cab/rehlds/mod_"$GAME".zip
	fi
elif command -v curl 2>&1 >/dev/null; then
	if [ ! -s hlds_linux_8684.tar.gz ]; then
		echo "Downloading hlds_linux_8684.tar.gz ..." && \
		curl -f -L -# -o hlds_linux_8684.tar.gz http://ftp.taco.cab/rehlds/hlds_linux_8684.tar.gz
	fi && \
	echo "Downloading rehlds_linux.tar.gz ..." && \
	curl -f -L -# -o rehlds_linux.tar.gz http://ftp.taco.cab/rehlds/rehlds_linux.tar.gz && \
	echo "Downloading versioninfo.txt ..." && \
	curl -f -L -# -o versioninfo.txt http://ftp.taco.cab/rehlds/versioninfo.txt && \
	if [ ! -z "$MOD" ]; then
		echo "Downloading mod_"$GAME".zip ..." && \
		curl -f -L -# -o mod_"$GAME".zip http://ftp.taco.cab/rehlds/mod_"$GAME".zip
	fi
else
	echo "rehldsupdatetool: Neither 'wget' or 'curl' found. Install either of them and re-run rehldsupdatetool."
	exit 1
fi

if [ $? -ne 0 ] || [ ! -s hlds_linux_8684.tar.gz ] || [ ! -s rehlds_linux.tar.gz ] || [ ! -s versioninfo.txt ] || { [ ! -z "$MOD" ] && [ ! -s mod_"$GAME".zip ]; }; then
	echo "rehldsupdatetool: Download failed"
	rm -f hlds_linux_8684.tar.gz rehlds_linux.tar.gz versioninfo.txt
	if [ ! -z "$MOD" ]; then
		rm -f mod_"$GAME".zip
	fi
	exit 1
fi

echo "Extracting hlds_linux_8684.tar.gz ..." && \
tar --strip-components=1 -C "$HLDS_DIR" -xzf hlds_linux_8684.tar.gz && \
echo "Extracting rehlds_linux.tar.gz ..." && \
tar --strip-components=1 -C "$HLDS_DIR" -xzf rehlds_linux.tar.gz && \
if [ ! -z "$MOD" ]; then
	echo "Extracting mod_"$GAME".zip ..." && \
	eval "$TOOL"
fi

if [ $? -ne 0 ]; then
	echo "rehldsupdatetool: Extraction failed"
	exit 1
fi

chmod +x ""$HLDS_DIR"/hlds_linux"
chmod +x ""$HLDS_DIR"/hlds-cstrike.sh"
chmod +x ""$HLDS_DIR"/hlds-valve.sh"
if [ ! -z "$MOD" ]; then
	chmod +x ""$HLDS_DIR"/hlds-"$GAME".sh"
fi

echo "Done"
echo
echo "Version Info:"
echo
cat versioninfo.txt
echo

echo "Installation complete. Run \"hlds-"$GAME".sh\" to start the server."

exit 0
