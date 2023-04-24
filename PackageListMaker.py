import configparser
import sys
config = configparser.ConfigParser()

IniFile = sys.argv[1]


config.read(IniFile)

Sections = config.sections()
for titles in Sections:
    print(titles)
