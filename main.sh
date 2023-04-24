#!/bin/bash

trap cleanup 1 2 3 6
cleanup() {
    echo -e "\nRemoving temporary files..."
    rm -rf "$WrkDir"
    exit
}

installerFxn() {
    WrkDir=$(mktemp -d)
    wget $1 -P $WrkDir/

    DebToIniPrgm=$(readlink -f DebToIni.py)
    IniFile=$(readlink -f test.ini)
    cd $WrkDir

    PkgFile=$(ls | grep *.deb)
    echo $PkgFile

    ar -x $PkgFile

    tar -xf control.tar.xz
    dpkg --force-all -i $PkgFile
    python3 ${DebToIniPrgm} control ${IniFile}
}

installerFxn http://http.us.debian.org/debian/pool/main/n/neovim/neovim_0.4.4-1_amd64.deb
