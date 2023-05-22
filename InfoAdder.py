import configparser
import sys
config = configparser.ConfigParser()

PackageToEdit = sys.argv[1]

IniFile = sys.argv[2]

InfoSection = sys.argv[3]

InfoToAdd = sys.argv[4:]
InfoToAdd = ' '.join(InfoToAdd) #if theres more than 1 word in the info then it needs to join all the args together to one string
config.read(IniFile)

try:
    print(config[PackageToEdit])
except:
    print("Invalid Package name: " + PackageToEdit + " ,check for a typo")
    sys.exit()


if (InfoSection == "v"):
    config[PackageToEdit]["version"] = InfoToAdd
elif (InfoSection == "a"):
    config[PackageToEdit]["architecture"] = InfoToAdd
elif (InfoSection == "m"):
    config[PackageToEdit]["maintainer"] = InfoToAdd
elif (InfoSection == "d"):
    config[PackageToEdit]["depends"] = InfoToAdd
elif (InfoSection == "u"):
    config[PackageToEdit]["url"] = InfoToAdd
elif (InfoSection == "de"):
    config[PackageToEdit]["description"] = InfoToAdd
    
with open(IniFile, "w") as configFile:
        config.write(configFile, True)