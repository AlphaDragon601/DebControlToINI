#!/bin/bash

#get absolute paths to all the programs we need
IniFile=$(readlink -f test.ini)


DebToIniPrgm=$(readlink -f DebToIni.py)
RemovePkgPrgm=$(readlink -f RemovePkgFromIni.py)
PackageListerPrgm=$(readlink -f PackageListMaker.py)
UrlGetterPrgm=$(readlink -f UrlGetter.py)
RemovePkgPrgm=$(readlink -f RemovePkgFromIni.py)
ReadIniPrgm=$(readlink -f ReadIni.py)

#default these to y so the user can spam enter
yn1="y"
yn2="y"
yn3="y"
yn4="y"

#cleanup the temporary dir
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
    # outputs the status of config vs control differences to a temp file
    python3 ${DebToIniPrgm} control ${IniFile} $1 n >> PyOut
    # put the info from the file to variables
    PkgName=$(head -n 1 PyOut | tail -1)
    DiffVersion=$(head -n 2 PyOut | tail -1)
    DiffArch=$(head -n 3 PyOut | tail -1)
    DiffMaintainer=$(head -n 4 PyOut | tail -1)
    DiffDepends=$(head -n 5 PyOut | tail -1)
    #check each variable to see if there was a difference we need to ask the user about
    if [ "$DiffVersion" = "True" ]; then
        read -p "New package has a different version than current, overwrite the old? " yn1
        if [ "$yn1" = "" ]; then
            yn1="y"
        fi
    fi
    if [ "$DiffArch" = "True" ]; then
        read -p "New package has a different architecture than current, overwrite the old? " yn2
        if [ "$yn2" = "" ]; then
          yn2="y"
        fi
    fi
    if [ "$DiffMaintainer" = "True" ]; then
        read -p "New package has a different maintainer than current, overwrite the old? " yn3
        if [ "$yn3" = "" ]; then
            yn3="y"
        fi
    fi
    if [ "$DiffDepends" = "True" ]; then
        read -p "New package has different depends than current, overwrite the old? " yn4
        if [ "$yn4" = "" ]; then
            yn4="y"
        fi
    fi

    if [ "$yn1" = "y"  ] && [ "$yn2" = "y"  ] && [ "$yn3" = "y"  ] && [ "$yn4" = "y"  ]; then
        python3 $DebToIniPrgm control ${IniFile} $1 o 
        dpkg --force-all -i $PkgFile
    fi
    # if the file said no difference just install it like normal
    if [ "$DiffVersion" = "False" ] && [ "$DiffArch" = "False" ] && [ "$DiffMaintainer" = "False" ] && [ "$DiffDepends" = "False" ]; then
        dpkg --force-all -i $PkgFile
    fi

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

    ConfigPackagesNum=$(wc -l < ConfigPackagesList.txt) #count lines in packageList
    echo "checking for packages to install..."
    for Pkg in $(seq 1 $ConfigPackagesNum)
    do
        LineContent=$(head -n $Pkg ConfigPackagesList.txt | tail -1)
        if grep -qw $LineContent packagesList.txt; then # grep needs option -q to make it a boolean output and w for whole world search
            echo $LineContent is installed
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