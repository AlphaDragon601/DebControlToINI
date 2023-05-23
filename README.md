# DebianIniPkg (name pending)

## Description:
  A shell + python script that can install debian packages via an ini config file. Using the command to install .deb packages via url the data is logged to an Ini for reproduction of that systems package setup.
  
 
## Command Options (visible with -h)
```
  -h for this list
  -i to install a url [main.sh -i **pkg-name**]
  -r to remove packages [main.sh -r **pkg-name**]
  -u to check for a program for updates [main.sh -u **pkg-name**]
  -d to list config dependencies [main.sh -d]
  -a add info to a package [main.sh -a **pkg-name**]
  -l to list installed (based on config) [main.sh -l]
  -c to copy current packages into the config [main.sh -c]"
```
