import configparser
import sys  
config = configparser.ConfigParser()

configFile = sys.argv[1]

PrgmSection = sys.argv[2]
RequestedVal = sys.argv[3]
config.read(configFile)

try:
    print(config[PrgmSection])
except:
    print("Unable to find program: " + PrgmSection + " ,is it installed?")
    sys.exit()

if RequestedVal == "v":
    print(config[PrgmSection]["version"])
elif RequestedVal == "a":
    print(config[PrgmSection]["architecture"])
elif RequestedVal == "m":
    print(config[PrgmSection]["maintainer"])
elif RequestedVal == "d":
    print(config[PrgmSection]["depends"])
elif RequestedVal == "u":
    print(config[PrgmSection]["URL"])
elif RequestedVal == "de":
    print(config[PrgmSection]["description"])
elif RequestedVal == "l":
    for Section in config:
        if Section != "DEFAULT":
            print(Section)
