import configparser
import sys  
config = configparser.ConfigParser()

configFile = sys.argv[1]

PrgmSection = sys.argv[2]
RequestedVal = sys.argv[3]
config.read(configFile)

#list doesn't take a program section input so it can be done without checking
if RequestedVal == "l":
    for Section in config:
        if Section != "DEFAULT":
            print(Section)
    sys.exit()
    
# check to make sure that program is in the config
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
    try:
        print(config[PrgmSection]["URL"])
    except:
        print("no url")
elif RequestedVal == "de":
    print(config[PrgmSection]["description"])
