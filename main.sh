#!/bin/bash


DebToIniPrgm=$(readlink -f DebToIni.py)
RemovePkgPrgm=$(readlink -f RemovePkgFromIni.py)
PackageListerPrgm=$(readlink -f PackageListMaker.py)
UrlGetterPrgm=$(readlink -f UrlGetter.py)
IniFile=$(readlink -f test.ini)
RemovePkgPrgm=$(readlink -f RemovePkgFromIni.py)


trap cleanup 1 2 3 6
cleanup() {
    echo -e "\nRemoving temporary files..."
    rm -rf "$WrkDir"
    exit
}

installerFxn() {
    WrkDir=$(mktemp -d)
    wget $1 -P $WrkDir/

    cd $WrkDir

    PkgFile=$(ls | grep *.deb)
    echo $PkgFile

    ar -x $PkgFile

    tar -xf control.tar.xz
    dpkg --force-all -i $PkgFile
    python3 ${DebToIniPrgm} control ${IniFile} $1

}

uninstallerFxn(){
    dpkg -r $1
    python3 ${RemovePkgPrgm} ${IniFile} $1

}

builderFxn(){


    WrkDir=$(mktemp -d)
    cd $WrkDir
    dpkg-query -f '${binary:Package}\n' -W > packagesList.txt #list of installed packages
    python3 ${PackageListerPrgm} ${IniFile} > ConfigPackagesList.txt #list of packages in config

    PackagesInstalledNum=$(wc -l < ConfigPackagesList.txt) #count lines in packageList

    for Pkg in $(seq 1 $PackagesInstalledNum)
    do
        LineContent=$(head -n $Pkg ConfigPackagesList.txt | tail -1)
        if grep -q $LineContent packagesList.txt; then
            echo found $LineContent
        else
            URL=$(python3 ${UrlGetterPrgm} ${IniFile} ${LineContent})
            cd ..
            installerFxn $URL
        fi
    done
}


if [ x"$1" = "x" ]; then
    echo -e "no command entered, options are \n\t-u \n\t-r"
elif [ "$1" = "-i" ]; then
    installerFxn $2
elif [ "$1" = "-r" ]; then
    uninstallerFxn $2
elif [ "$1" = "-b" ]; then
    builderFxn
else
    echo "command: $1 not found"
fi