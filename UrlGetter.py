import configparser
import sys
config = configparser.ConfigParser()

IniFile = sys.argv[1]

Pkg = sys.argv[2]

config.read(IniFile)

print(config[Pkg]["URL"])