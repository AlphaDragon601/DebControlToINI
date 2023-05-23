# DebianIniPkg (name pending)

## Description:
  A shell + python script that can install debian packages via an ini config file. Using the command to install .deb packages via url the data is logged to an Ini for reproduction of that systems package setup.
  
 
## Command Options (visible with -h)
```
  -h for this list
  -i to install a url [main.sh -i ${ItalicsStart}pkg-name${ReturnToNorm}]
  -r to remove packages [main.sh -r ${ItalicsStart}pkg-name${ReturnToNorm}]
  -u to check for a program for updates [main.sh -u ${ItalicsStart}pkg-name${ReturnToNorm}]
  -d to list config dependencies [main.sh -d]
  -a add info to a package [main.sh -a ${ItalicsStart}pkg-name${ReturnToNorm}]
  -l to list installed (based on config) [main.sh -l]
  -c to copy current packages into the config [main.sh -c]"
```
