import os
import fileinput

for f in os.listdir('.'):
    if ".md" in f:
        # Read in the file
        with open(f, 'r') as file :
            filedata = file.read()

        # Replace the target string
        filedata = filedata.replace('\n', '  \n')
        filedata = filedata.replace(' ?', chr(160)+"?")
        filedata = filedata.replace(' !', chr(160)+"!")

        # Write the file out again
        with open(f, 'w') as file:
            file.write(filedata)
