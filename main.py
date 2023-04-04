import configparser

config = configparser.ConfigParser()
config.read("test.ini")
print(config.sections())

config['testertest'] = {
    "silly" : ":3"
}

with open("test.ini", "w") as configFile:
    config.write(configFile, True)