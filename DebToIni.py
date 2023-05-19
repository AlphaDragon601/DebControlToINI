import configparser
import sys
config = configparser.ConfigParser()

InputControlFile = sys.argv[1]

IniFile = sys.argv[2]

URL = sys.argv[3]

Override = sys.argv[4]

config.read(IniFile)


# define at blank in case they never get filled
SourcePkg = ""
VersionPkg = ""
ArchPkg = ""
MaintanerPkg = ""
DependsPkg = ""
DescTerm = ""



with open(InputControlFile, "r") as ControlFile:
    lines = ControlFile.readlines()
    for row in lines: #check each line
        SourceTerm = "Package: "
        VersionTerm = "Version: "
        ArchTerm = "Architecture: "
        MaintanerTerm = "Maintainer: "
        DependsTerm = "Depends: "
        DescTerm = "Description: "
        
        if row.find(SourceTerm) != -1:
            SourcePkg = row.replace(SourceTerm, "") # replace "source: " with nothing leaving just the title
            SourcePkg = SourcePkg.replace("\n", "") #remove newline
        
        if row.find(VersionTerm) != -1:
            VersionPkg = row.replace(VersionTerm, "")
            VersionPkg = VersionPkg.replace("\n", "") 
            
        if row.find(ArchTerm) != -1:
            ArchPkg = row.replace(ArchTerm, "")
            ArchPkg = ArchPkg.replace("\n", "") 
            
        if row.find(MaintanerTerm) != -1:
            MaintanerPkg = row.replace(MaintanerTerm, "")
            MaintanerPkg = MaintanerPkg.replace("\n", "") 
        
        if row.find(DependsTerm) != -1:
            DependsPkg = row.replace(DependsTerm, "")
            DependsPkg = DependsPkg.replace("\n", "") 
            
        if row.find(DescTerm) != -1:
            DescPkg = row.replace(DescTerm, "") # replace "source: " with nothing leaving just the title
            DescPkg = DescPkg.replace("\n", "") #remove newline
            


# check if the program is already listed in the config
if config.has_section(SourcePkg):
    #check if the reading from the control file doesn't match our config
    if config[SourcePkg]["version"] != VersionPkg:
        DiffVersion = True
    else:
        DiffVersion = False
        
    if config[SourcePkg]["architecture"] != ArchPkg:
        DiffArch = True
    else:
        DiffArch = False
        
    if config[SourcePkg]["maintainer"] != MaintanerPkg:
        DiffMaintainer = True
    else:
        DiffMaintainer = False
        
    if config[SourcePkg]["depends"] != DependsPkg:
        DiffDepends = True
    else:
        DiffDepends = False
        
    if config[SourcePkg]["description"] != DescPkg:
        DiffDesc = True
    else:
        DiffDesc = False
        
    if Override != "o":
        print(SourcePkg)
        for i in [DiffVersion,DiffArch,DiffMaintainer,DiffDepends, DiffDesc]:
            print(i)
        
else:
    config[SourcePkg] = {
        "Version" : VersionPkg,
        "Architecture" : ArchPkg,
        "Maintainer" : MaintanerPkg,
        "Depends" : DependsPkg,
        "URL" : URL,
        "Description" : DescPkg
    }
    
    with open(IniFile, "w") as configFile:
        config.write(configFile, True)
        
#for use by the bash script after the user has said "yes install anyways"
if Override == "o":
    config[SourcePkg] = {
        "Version" : VersionPkg,
        "Architecture" : ArchPkg,
        "Maintainer" : MaintanerPkg,
        "Depends" : DependsPkg,
        "URL" : URL,
        "Description" : DescPkg
    }
    
    with open(IniFile, "w") as configFile:
        config.write(configFile, True)



