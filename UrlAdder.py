import configparser
import sys  
config = configparser.ConfigParser()

configFile = sys.argv[1]
PkgSection = sys.argv[2]
URL = sys.argv[3]

config.read(configFile)

config[PkgSection]["URL"] = URL

with open("test.ini", "w") as configFile:
    config.write(configFile, True)
