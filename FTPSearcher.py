from ftplib import FTP
import sys


FirstLetter = sys.argv[1]
FileName = sys.argv[2]
Mirror = sys.argv[3]

ftp = FTP(Mirror)

ftp.login()


MainUrl = 'debian/pool/main/' + FirstLetter + "/"

ftp.cwd(MainUrl)
# print(ftp.pwd())

for folder in ftp.nlst():
    # print(folder + ":")
    ftp.cwd(folder)
    # print(folder + ":")
    for file in ftp.nlst():
        if (file == FileName):
            print(MainUrl + folder + "/" + file)
            ftp.close()
            sys.exit()
    # print(ftp.pwd())
    ftp.cwd("..")