import configparser
import sys  
config = configparser.ConfigParser()

configFile = sys.argv[1]

config.read(configFile)
ListOfDeps = []
for Pkg in config:
    try:
        ListOfDeps += "\n" + Pkg + ":\n" + config[Pkg]["depends"] #this was pure trial and error to look right idk
    except:
        print(str(config[Pkg]) + " has no depends listed")
ListOfDeps = ("".join(ListOfDeps)).split(", ") # ListOfDeps starts as a list of every letter, join it all and then split it at the commas
for i in ListOfDeps:
    print(i)