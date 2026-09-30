# Week 8 Lab Report
Student name: Khem Ingkapat
Student ID: 66070503408
Date: 30/9/2026
GPU used: Tesla T4, 7.5
PCIe generation: 3
Environment: Colab
CUDA toolkit version: 12.8
Time spent: 4 hours

## Exercise 1 — Serial Baseline + Pinned Memory
RESULTS SUMMARY:
Variant A (Pageable) Time: 357.771 ms
Variant B (Pinned) Time:   137.753 ms
Pinned Speedup (A/B):      2.60x
Effective Bandwidth (Q3):  11150.40 MB/s (11.15 GB/s)

Q1: With Tesla T4 on Colab - PCIe Gen3 (x16)
Variant A (Pageable) Time: 357.771 ms
Variant B (Pinned) Time:   137.753 ms

Q2: Pinned Speedup (A/B): 2.60x

Q3: Effective Bandwidth :  11150.40 MB/s (11.15 GB/s) - from memory used at (1.5GB / time used)

## Exercise 2 — Multi-Stream Pipeline

| variant       | N_STREAMS | time (ms) | speedup vs serial pinned | correctness |
|:--------------|:----------|:----------|:-------------------------|:------------|
| naive         | 2         | 97.127    | 1.42                     | PASS        |
| naive         | 4         | 98.236    | 1.40                     | PASS        |
| naive         | 8         | 98.121    | 1.40                     | PASS        |
| interleaved   | 2         | 97.175    | 1.42                     | PASS        |
| interleaved   | 4         | 98.227    | 1.40                     | PASS        |
| interleaved   | 8         | 98.125    | 1.40                     | PASS        |
| serial pinned | —         | 137.604   | 1.00                     | PASS        |

[bar chart plot]
Q4: actually for interleaved (and naive) at about 1.42x speed up, which I think about 1.40 ish is the ceiling since increasing more stream doesn't equal the more speed up.

and for the ceiling analogy. I will make one transfer as one unit. so if we do 2 chunk on 1 stream, we need to copy 2 unit and copy back for one unit, so it would be 6 total transfer time unit(neglecting the compute time).

but for 2 stream or more, we copy 2 unit, and then compute and then copy back, why we compute and copy back, we could start the copy for the second stream right away. so now from 3 units per chunk it goes down to 2 units per chunk + one last copy back that we couldn't overlap, total to be 5 from 6, and if we do this pattern as `N_CHUNKS` increasing it will goes closer to 1.5 without those compute time included, which 1.4 is quite reasonable

Q5: from the slides, it seems like the stream would block other stream, but it doesn't seems to happen here(since naive and interleaved is quite similar) because in newer arch(like in this), now each stream has it own queue so no more blocking like that

Q6: for sure, if compute time is much longer, it would shows in the serial that it is much longer. and then old concept of hiding compute within the transfer time would show more speed up factor.

but on that idea, even though it would be correct on "longer" kernel, but it wouldn't be correct for all "longer kernel". since when the kernel time is significantly longer, now the transfer time is negligible, so now it would be like no speed up since we couldn't speed up the compute.

## Exercise 3 — CUDA Graphs
========================================================================
EXERCISE 3 RESULTS TABLE
========================================================================
| variant         | total_time (ms) | time_per_iter (us) | speedup |
|:----------------|:----------------|:-------------------|:--------|
| regular streams | 22.779          | 22.779             | 1.00    |
| cuda graph      | 20.074          | 20.074             | 1.13    |
========================================================================
Overall Correctness: PASS
Speedup Ratio: 1.13x faster with CUDA Graphs
========================================================================

Q7:
From the lab's numbers, using the lowest values: each iteration has 4 operations (memset + 3 kernels), so the regular version has about 4 * 5 = 20 us of launch overhead. The graph launches everything at once for about 1 us. So I expected to save about 19 us per iteration.

But I only saved 22.8 - 20.1 = 2.7 us (1.13x). The reason is that the CPU and GPU work at the same time. While the GPU runs one operation, the CPU is already launching the next one. So the time is set by whichever is slower, not by adding them together.

In the regular version, most of the launch overhead was already hidden behind the GPU work. The graph can only remove the small part that was not hidden. After the graph removed the launch cost, the time was still 20.1 us, which is most likely the time the GPU needs to run the 4 operations. A graph cannot make that part faster.


Q8: with our analogy from the previous part, I assume that this would follow the same trend. since overhead save is not significant when compare to how much our kernel actually done, so speed up factor will decrease down to 1.0x if we have larger kernel

Q9: if we talk about grpah pattern. I would take my senior project in here so 1. the LLM inference engine, since it will need to work repetitively during decode phase, so graph might help if we run it for like millions times

another example is I think simulation of physic - even though I have no prior experience about this, but from physic class I normally needing to calculate something again and again when with variable difference. So if we talk about like physics that require every part of the field calculated, this might help

## Exercise 4 — Cross-Stream Sync with Events
========================================================================
EXERCISE 4 RESULTS TABLE
========================================================================
| implementation            | time (ms) |
|:--------------------------|:----------|
| host-mediated sync        | 3.715     |
| event-based cross-stream  | 3.683     |
========================================================================
Verification: PASS (Both implementations produced identical, correct outputs)
Difference: 0.032 ms (0.85% difference)
========================================================================
Q10: in this certain works, it HAS NO NOTICIBLE difference, since CPU is not doing the other works, so very native way of doing it by synchornizing using host time and blocking host thread doesn't really have any effect on the total time

Q11:
refer to the previous question, so if we have some other things that host(CPU) can do during the waiting time of consumer, it would be better since we already have asynchronous called between both stream and we don't need to rely solely on host time, so we can free host to do some other things. so the implementation B it is
Q12:

```cuda
cudaEvent_t event_A_done, event_B_done;
cudaEventCreate(&event_A_done);
cudaEventCreate(&event_B_done);

// 1. Stream A produces data
kernel_A<<<grid, block, 0, stream_A>>>(d_A);
cudaEventRecord(event_A_done, stream_A);

// 2. Stream B waits for A, then consumes d_A and produces d_B
cudaStreamWaitEvent(stream_B, event_A_done, 0); // Non-blocking on host
kernel_B<<<grid, block, 0, stream_B>>>(d_A, d_B);
cudaEventRecord(event_B_done, stream_B);

// 3. Stream C waits for B, then consumes d_B and produces d_C
cudaStreamWaitEvent(stream_C, event_B_done, 0); // Non-blocking on host
kernel_C<<<grid, block, 0, stream_C>>>(d_B, d_C);

// CPU returns immediately after enqueuing; synchronizes only when results are needed:
cudaStreamSynchronize(stream_C); // or cudaDeviceSynchronize();

cudaEventDestroy(event_A_done);
cudaEventDestroy(event_B_done);
```

## Reflection (optional)
for this, I find it easier that normal Prof. Bird lab. Maybe most of them are borrowing the concepts from com arch and os. Normally I spent most of the time figuring out the answer for the question because I am not fully understand the concept from the class. but this time it is different

also many of the concept might not work as expected but it doesn't completely void the concepts
