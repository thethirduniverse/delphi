#@s
a = [9991,6,3,4,7]
for i in range(len(a)):
    for j in range(i):
        if a[j] > a[i]:
            a[j],a[i] = a[i], a[j]
print a
#@e
