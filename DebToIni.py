import configparser
import sys
config = configparser.ConfigParser()

InputControlFile = sys.argv[1]
IniFile = sys.argv[2]

config.read(IniFile)

# define at blank in case they never get filled
SourcePkg = ""
VersionPkg = ""
ArchPkg = ""
MaintanerPkg = ""
DependsPkg = ""




with open(InputControlFile, "r") as ControlFile:
    lines = ControlFile.readlines()
    for row in lines: #check each line
        SourceTerm = "Package: "
        VersionTerm = "Version: "
        ArchTerm = "Architecture: "
        MaintanerTerm = "Maintainer: "
        DependsTerm = "Depends: "
        
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
            



config[SourcePkg] = {
    "Version" : VersionPkg,
    "Architecture" : ArchPkg,
    "Maintainer" : MaintanerPkg,
    "Depends" : DependsPkg

    
}




with open("test.ini", "w") as configFile:
    config.write(configFile, True)

Sections = config.sections()
for titles in Sections:
    print(titles)