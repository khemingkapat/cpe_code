# Break A
so basically from the clampped version, unlike zero padding that apply zero contribution to final result, it re-reads from the nearest edge pixel, so that's why it shows error on the edge of output where the mask(r=2) overlapped into the void

prediction : error element = size * 2 + (size-2) * 4 +(size -4) * 2 = 128 * 2 + 126 * 4 + 124 * 2(just try to account from size and r to the edge where it could overlap)

# Question 1
because when it fetched from the global memory and using cached, it doesn't like read SINGLE VALUE at a time, it does fetch like a block, so in row-majored store matrix,the neighbor iteration gets what's already cached so that's why the peak bandwidth is not so accurate

let's say that at thread id by out index (x,y), that is 5x5(at r=2) around that, which we could say other threads also read that at the same time and IT GOT CACHED already, so for one thread, it only read ONE NEW PIXEL at 4bytes in and 4bytes out, and at 5x5 it is 49 ops, we could find AI at

AI = 49 / 8 = 6.125

then the actual peak bandwidth is at 6.125 * 320 GB/s = 1960 GFLOPS so that's plenty when compare to our peak calculated before at 370.2

# Break B
this is due to that we use input tile dimension instead of output, so that out = in -2r ,so when we calculate, we missed a block so that's why on the right and bottom that is missed on the calculation

# Break C
this is quite simple, race condition, when we read before write - we get any garbage value sits in that memory address, that's why the output is not correct. it will be correct if we run it multiple times since the correct value will be sitting there but on the first time for sure it wouldn't be correct

# Question 2
since the tile = 16 that we found the fastest, even though it shows that the halo percentage is lowest on the biggest. the concept of warp swaping that could hide the latency due to warp swaping is  not exist at tile=32 since we could only launch one block per per sm, and that's allow overhead to show in the calculation by waiting for memory since there is nothing to do concurrently in that sm

# Break D
since we updated inplace, when thread proceed to the next one it kinda got overwrote by another thread that finished before. and that's why inplace doesnt work

# Question 3
since we already mentioned the break D, why syncthread doesn't prevent it is that syncthreads only sync within block, so different block is still asynchronuous. with scheduling is not the same everytime, it would be not identical - it is up to scheduler where the memory is there to ready to calculate. it would always happen where the tile overlap. and the rule stated in the code that we never update inplace because of this

# Question 4
when we can parallel and reuse the input data, to calculate iteratively again and again. so that's when  we reach the  compute bound, which GPU is very fast on the computation and that shows why more layer =>  more reuse would fit better in GPU. The real CNN, I actually don't know what  about the ACTUAL one since the C is like hyper-params that got tune to the use case, but  I could say that the higher C is more popular due to the extraction of more complex pattern. And higher the layer the easier to make it fast since we completely remove the memory bound due to reuse of  data - less  memory transfer.



