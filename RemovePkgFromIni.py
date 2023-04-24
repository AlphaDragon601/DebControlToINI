import configparser
import sys
config = configparser.ConfigParser()

IniFile = sys.argv[1]
PkgToRemove = sys.argv[2]

config.remove_section(PkgToRemove)

with open(IniFile, "w") as configFile:
    config.write(configFile, True)