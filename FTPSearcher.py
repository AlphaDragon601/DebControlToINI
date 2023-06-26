from ftplib import FTP
import sys


FirstLetter = sys.argv[1]
FileName = sys.argv[2]
PkgName = sys.argv[3]
Mirror = sys.argv[4]



ftp = FTP(Mirror)

ftp.login()
found = False

MainUrl = 'debian/pool/main/' + FirstLetter + "/"
FileNameNoArch = ""
ScoreNum = 0
for letter in FileName:
    if letter == "_":
        ScoreNum += 1
    if ScoreNum == 2:
        break
    FileNameNoArch = FileNameNoArch + letter    
    
# print(FileNameNoArch)

ftp.cwd(MainUrl)
# print(ftp.pwd())
try:
    ftp.cwd(PkgName)

except:
    for folder in ftp.nlst():
        # print(folder + ":")
        ftp.cwd(folder)
        for file in ftp.nlst():
            if (file == FileName):
                print(MainUrl + folder + "/" + file)
                found = True
                ftp.close()
                sys.exit()
            elif (file == (FileNameNoArch + "_all.deb")):
                print(MainUrl + folder + "/" + (FileNameNoArch + "_all.deb"))
                found = True
        # print(ftp.pwd())
        ftp.cwd("..")
        
        

else:
    for file in ftp.nlst():
        if (file == FileName):
            print(MainUrl + PkgName + "/" + file)
            found = True
            ftp.close()
            sys.exit()
        elif (file == (FileNameNoArch + "_all.deb")):
                print(MainUrl + PkgName + "/" + (FileNameNoArch + "_all.deb"))
                found = True
            
            
if found == False:
    print("Couldn't find it :(")
    ftp.cwd("..")
    