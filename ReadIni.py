import configparser
import sys
config = configparser.ConfigParser()

configFile = sys.argv[1]

config.read(configFile)

# print(config.sections())
for section in config.sections():
    print(section)
    print("\t" + config[section]["version"])
    print("\t" + config[section]["architecture"])
    print("\t" + config[section]["maintainer"])
    print("\t" + config[section]["depends"])
    print("\n*********\n")

