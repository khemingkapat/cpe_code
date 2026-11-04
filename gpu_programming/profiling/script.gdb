set pagination off
break weighted_sum
run
next
cuda thread (0,0,0)
print gid
cuda thread (5,0,0)
print gid
next
next
print sum
next
print k
continue
quit
