#!/bin/bash


cd $(dirname $(readlink -f $0)) #take us to the directory of the script and its friends :)


#fun text stuff
ItalicsStart="\e[3m"
ReturnToNorm="\e[0m"

#get absolute paths to all the programs we need
IniFile=$(readlink -f config.ini)

DebToIniPrgm=$(readlink -f DebToIni.py)
RemovePkgPrgm=$(readlink -f RemovePkgFromIni.py)
PackageListerPrgm=$(readlink -f PackageListMaker.py)
UrlGetterPrgm=$(readlink -f UrlGetter.py)
RemovePkgPrgm=$(readlink -f RemovePkgFromIni.py)
ReadIniPrgm=$(readlink -f ReadIni.py)
InfoAdderPrgm=$(readlink -f InfoAdder.py)
DepLister=$(readlink -f DepLister.py)
#default these to y so the user can spam enter
yn1="y"
yn2="y"
yn3="y"
yn4="y"

#cleanup the temporary dir
trap cleanup 1 2 3 6
cleanup() {
    echo "\nRemoving temporary files..."
    rm -rf "$WrkDir"
    exit
}


archFinderFxn(){
    Search=$(lscpu | grep Architecture)

    case $Search in
    "Architecture:                    x86_64")
        arch="amd64"
        ;;
    "Architecture:          i386")
        arch="i386"

    esac

}



updaterFxn() {
    if [ x"$1" != "x" ];then
        PkgDesc=$(python3 ${ReadIniPrgm} ${IniFile} $1 "de") #this needs to be run first because it checks of $1 is a package as well as grabs data
        if [ "$PkgDesc" = "Unable to find program: ${1} is it installed?" ];then
            echo "Unable to find package: ${1}"
        else
            WrkDir=$(mktemp -d)
            wget https://packages.debian.org/bullseye/amd64/allpackages?format=txt.gz -P $WrkDir/
            cd $WrkDir
            ListFile=$(ls *.gz)
            gzip -d $ListFile
            ListFile=$(ls)
            PkgResult=$(grep -w "$1" $ListFile | grep "$PkgDesc" $ListFile)
            PkgVer=$(echo $PkgResult | awk -F"[()]" '{print $2}') #extract version # from btwn ()
            echo "Found Version: $PkgVer"
            UpVersion=$(python3 ${ReadIniPrgm} ${IniFile} $1 "v")
            UpVersion=${UpVersion#"<Section: ${1}>"}
            echo "Found Version: $UpVersion"
            if [ "$PkgVer" = "$UpVersion" ]; then
                echo "Program is up to date"
            else
                echo "Found version: $PkgVer online, installed is version $UpVersion"
            fi
        fi

        else
            echo "no program entered"

    fi
    
}



installerFxn() {
    WrkDir=$(mktemp -d)
    # wget $1 -P $WrkDir/
    archFinderFxn
    wget https://packages.debian.org/bullseye/amd64/allpackages?format=txt.gz -P $WrkDir/

    

    cd $WrkDir


    ListFile=$(ls *.gz)
    gzip -d $ListFile
    ListFile=$(ls)

    name=$(grep -m 1 "${1} (" $ListFile)
    info=$(echo $name | awk -F"[()]" '{print $2}')
    firstChar=$(echo $name | cut -c1-1)
    # echo $firstChar
    # echo $info


    PkgUrl="http://http.us.debian.org/debian/pool/main/${firstChar}/${1}/${1}_${info}_${arch}.deb"


    wget $PkgUrl


    PkgFile=$(ls *.deb)
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
        python3 $DebToIniPrgm control ${IniFile} ${PkgUrl} o 
        dpkg --force-all -i $PkgFile
        else
            echo "exiting..."
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
    python3 ${ReadIniPrgm} ${IniFile} null l > ConfigPackagesList.txt #list of packages in config

    ConfigPackagesNum=$(wc -l < ConfigPackagesList.txt) #count lines in packageList
    packagesListNum=$(wc -l < packagesList.txt)
    echo "checking for packages to install..."
    for Pkg in $(seq 1 $ConfigPackagesNum)
    do
        LineContent=$(head -n $Pkg ConfigPackagesList.txt | tail -1)
        echo $LineContent
        if grep -qw $LineContent packagesList.txt; then # grep needs option -q to make it a boolean output and w for whole world search
            echo $LineContent is installed
        else
            URL=$(python3 ${ReadIniPrgm} ${IniFile} ${LineContent} "u") #Get the url from the config
            cd ..
            installerFxn $URL
        fi
    done
    echo "checking for packages to uninstall..."
    for Pkg in $(seq 1 $packagesListNum)
    do
        LineContent=$(head -n $Pkg packagesList.txt | tail -1)
        if grep -qw $LineContent ConfigPackagesList.txt; then # grep needs option -q to make it a boolean output and w for whole world search
            echo $LineContent is in config
        else
            read -p "$LineContent is not in config, would you like to uninstall it?(y/n)" $yn1
            if [ "$yn1" == "y" ]; then
                uninstallerFxn $LineContent
            fi
        fi
    done

}

DpkgBackupFxn(){
    WrkDir=$(mktemp -d)
    cd $WrkDir

    dpkg-query -f '${binary:Package}\n' -W > packagesList.txt #list of installed packages
    python3 ${ReadIniPrgm} ${IniFile} null l > ConfigPackagesList.txt #list of packages in config
    packagesListNum=$(wc -l < packagesList.txt)
    ConfigPackagesNum=$(wc -l < ConfigPackagesList.txt) #count lines in packageList
    for Pkg in $(seq 1 $packagesListNum)
    do
    LineContent=$(head -n $Pkg packagesList.txt | tail -1)
        if grep -qw "$LineContent" ConfigPackagesList.txt; then
            echo "found $LineContent"
        else
            echo "\n[$LineContent]" >> $IniFile
        fi
    done
}

infoAdderFxn(){
    echo "What info do you want to add? \n-(v)version\n-(a)architecture\n-(m)maintainer\n-(d)depends\n-(u)url\n-(de)description\n-(p)new package"
    read ChosenInfo
    case $ChosenInfo in
        v)
            echo "you have selected version"
            InfoSelection="version"
            ;;
        a)
            echo "you have selected architecture"
            InfoSelection="architecture"
            ;;
        m)
            echo "you have selected maintainer"
            InfoSelection="maintainer"
            ;;
        d)
            echo "you have selected depends"
            InfoSelection="depends"
            ;;
        de)
            echo "you have selected description"
            InfoSelection="description"
            ;;
        p)
            echo "you have selected new package"
            InfoSelection="new package"
            ;;
        *)
            echo "unkown request, please enter either v, a, m, d, or de"
            ;;

    esac
    read -p "info to add in $InfoSelection: " info
    if [ x"$1" != x ];then
        python3 ${InfoAdderPrgm} ${1} ${IniFile} ${ChosenInfo} ${info}
    else
        python3 ${InfoAdderPrgm} placeholder ${IniFile} ${ChosenInfo} ${info}
    fi

}

CmdInfo="
 \t-h for this list
 \t-i to install a url [main.sh -i ${ItalicsStart}pkg-name${ReturnToNorm}]
 \t-r to remove packages [main.sh -r ${ItalicsStart}pkg-name${ReturnToNorm}]
 \t-u to check for a program for updates [main.sh -u ${ItalicsStart}pkg-name${ReturnToNorm}]
 \t-d to list config dependencies [main.sh -d]
 \t-a add info to a package [main.sh -a ${ItalicsStart}pkg-name${ReturnToNorm} or if selecting option p main.sh -a]
 \t-l to list installed (based on config) [main.sh -l]
 \t-c to copy current packages into the config [main.sh -c]" 


if [ x"$1" = "x" ]; then
    echo "no command entered, options are: $CmdInfo"
else
    case $1 in
        -h)
            echo "Command options are: $CmdInfo"
            ;;
        -i)
            #loop through each entry and run the installer on them
            shift
            for var in "$@"; do
                echo "\n$var"
                installerFxn $var
            done
            ;;
        -r)
            #loop through each entry and run the uninstaller on them
            shift
            for var in "$@"; do
                echo "\n$var"
                uninstallerFxn $var
            done
            ;;
        -u)
            updaterFxn $2
            ;;
        -d)
            python3 ${DepLister} ${IniFile}
            ;;
        -a)
            infoAdderFxn $2
            ;;
        -b)
            builderFxn
            ;;
        -l)
            python3 ${ReadIniPrgm} ${IniFile} n l
            ;;
        -c)
            DpkgBackupFxn
            ;;
        *)
            echo "option: $1 not found"
            ;;
    esac

fi