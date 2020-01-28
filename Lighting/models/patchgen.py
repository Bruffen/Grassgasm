import numpy as np 

points = np.array([
    [ 1, 0,-1],
    [-1, 0,-1],
    [-1, 0, 1],
    [ 1, 0, 1]
])

print("4")
print("1")
print("n")
dim = 2
k = 0
for i in range(-dim,dim+1):
    for j in range(-dim,dim+1):
        k+=4
print(k)
for i in range(-dim,dim+1):
    for j in range(-dim,dim+1):
        for p in points:
            aux = p+[i*2,0,j*2]
            print(aux[0],aux[1],aux[2],sep=',')
#for  p in points:
#    print(p[0],p[1],p[2])