import re

setRegexp = '[A-Za-z_]+\s*=\s*\{\s*[A-Za-z_d]+\s*[,\s*[A-Za-z_d]+\s*]*\}'
#setRegexp = '([A-Za-z_0-9])+\s*=\s*\{\s*[A-Za-z_0-9]+\s*[,\s*[A-Za-z_0-9]+\s*]*\}'
#tRegexp = '\s+[A-Za-z]+\s*=\s*\{\s*[A-Za-z]+\s*,\s*[A-Za-z]+\s*\}'
i = 0
txt = ''
with open('SysAlim.mch','r') as myFile:
    ##line = myFile.readline()
    setContentArray = dict()
    setToPut = dict()
    #txt = ''
    for line in myFile:
        #setContentArray = dict()
        #setToPut = dict()
        #print("LINELINE")
        fp = re.findall(setRegexp, line)
        if fp :
            setElt = fp[0].split('=')
            setName = setElt[0]
            setCont = re.sub('{', '', setElt[1])
            setCont = re.sub('}', '', setCont).split(',')
            for c in setCont:
                i = i+1
                setContentArray[c] = str(i)
            setToPut[setName] = setContentArray
             #print(setToPut)
            
        for key in setContentArray.keys():
           # print('sutition de '+key+' par '+setContentArray[key])
           line = re.sub(key.strip(), setContentArray[key], line)
        #les remplacements des élements de Sets
        #print(line)
        txt = txt+line
    print(txt)
with open('robot.pmch','w') as pFile:
    pFile.write(txt)


        
