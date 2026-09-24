# Q1
it is weird for me but that is the capability of float, in that such a high number, float ran out of space to increase each by one, so it would increase by 2 instead. an that exact number is the limit with we couldn't increase by one so it fails

for GPU, it doesn't do that because we don't increase by one, we sum up as pair and go up and up so that doesn't suffer the same problem
# Q2
this is the problem with the block size, so think of it as we half the thread every time, and from 100 / 2 = 50 - clean, 50/2 = 25 - clean again, but when 25 / 2 = 12, so on the condition we actually need it to be 13 to cover every thread, but as we use int and divided by 2 it leave out the thread - the last one got ignored so that's why the partial sum at those point got discared

and from my own experience, I would prioritize the error rather than manually checking every answer myself. and that's why it could be problematic, if the accuracy is the priority, having wrong or no answer could potentially be the same, this is the case where we could blindly take the wrong answer since it gives no sign
# Q3
`__syncthreads` would lock down the step. with the nonexistence of it could cause a random calculation, that purely on whether which thread is happens to be faster at a certain run would finished first and there could be no preliminary result from those neighboring thread

and as I said, the order of execution is up to the scheduler, which couldn't be known before the compile time, it is up to which data is there ready to use and scheduler would go up at that point. so that is totally random for each individual run, that's why it might finished but answer might not be correct - it could be correct but would rarely be - and it would varied from each run
# Q4
in the code that we make the tid % 2*s == 0, that's mean we only allow a certain thread in the warp. for example at first round at s=128, which means only index 0 of each block would be working, and we launch 8 warps(8*32 = 256) but only one thread in the first warp actually run. I assume that my result got faster because the divergence penalty that only one warp means less divergence.

the run 6 is very simple, we did not do the multiple-element per thread so we will have to run more round to get the sum of whole accuracy
# Q5
at about 87%(279/320)GBs, since there is no optimization on the arithmetic, I would say that the 320GBs is the theorethical peak, which launching kernel would surely has some overhead that couldn't be reduce. so this might be the closest we could get because other might be irreducible overhead.
