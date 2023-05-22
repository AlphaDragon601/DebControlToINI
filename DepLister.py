import configparser
import sys  
config = configparser.ConfigParser()

configFile = sys.argv[1]

config.read(configFile)
ListOfDeps = []
for Pkg in config:
    try:
        ListOfDeps += "\n" + Pkg + ":\n" + config[Pkg]["depends"]
    except:
        print(str(config[Pkg]) + " has no depends listed")
ListOfDeps = ("".join(ListOfDeps)).split(", ")
# ListOfDeps = set(ListOfDeps)
for i in ListOfDeps:
    print(i)