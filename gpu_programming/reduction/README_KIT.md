# Week 7 Lab Kit — Parallel Reduction

**One program, `reduction.cu`, and one control panel at the top of it.**

Every experiment in this lab is the same three steps:

```
change ONE line in the control panel  ->  make  ->  ./reduction
```

and copy the `RESULT` line it prints into your answer sheet.

## 0. Fill in the four TODOs first

| TODO | Where | The idea |
|---|---|---|
| 1 | `reduce_block`, Phase 1 | each thread sums `COARSE` elements before the tree |
| 2 | `reduce_block`, Phase 2 | one step of the reduction tree |
| 3 | `grid_blocks()` | how many blocks it takes to cover the input |
| 4 | `reduce_block`, Phase 3 | one result per block |

Search the file for `TODO`. While the control panel is at its **default**
settings the answer must come out exactly right, so the program checks
itself and stops if a TODO is wrong:

```
  STOP: the control panel is still at its DEFAULT settings, so this run
  must be exactly right - check TODO 1, 2, 3 and 4
```

Once the baseline run prints `MATCH`, you are ready to start breaking it.

## 1. Why the input is all ones

The program fills the input with 67,108,864 copies of `1.0f`, so the
correct answer is simply the number of elements. That is deliberate:

> **If a run prints a smaller sum, the shortfall tells you exactly how
> many values fell out of the reduction.**

A wrong answer is not just "wrong" — it is a count of what you lost.

## 2. The runs

The lab document gives the full table. In short:

| Run | Change | What you should see |
|---|---|---|
| 1 | nothing — the baseline | `MATCH`, and your GB/s |
| 2 | `BLOCK_SIZE` 256 → 100 | a wrong answer, and exactly how wrong |
| 3 | `GRID_PERCENT` 100 → 50 | a wrong answer |
| 4 | `USE_SYNC` 1 → 0 | a wrong answer that changes between runs |
| 5 | `INDEXING` 2 → 1 | the **right** answer, slower |
| 6 | `COARSE` 4 → 1 | the **right** answer, slower |
| 7 | tune `BLOCK_SIZE` and `COARSE` | your best GB/s |

Put the control panel back to the defaults between runs, unless the
instructions say otherwise.

## 3. Set your peak bandwidth

One control-panel line is not an experiment:

```c
#define PEAK_BW_GBS   360.0   // <<< YOUR GPU's peak, from Week 4
```

Set it once, from your own `device_query` output, before Run 1. The
`% of peak` column is meaningless until you do.

## 4. Check yourself before submitting

```bash
python3 selfcheck.py
```

It checks that your answer sheet is complete, your files are present and
your four TODOs are filled in. It does **not** check whether your numbers
are right — that is the part being marked.

## 5. Submit

```
answers.txt     reduction.cu     report.pdf     README.md
```

`reduction.cu` should be left in whatever state your **last** run used —
just say which configuration that was in your README.

## A note on ChatGPT and other coding assistants

The four TODOs are short, and an assistant can write them. But the marks
here are for what your own GPU printed and what you can explain about it:
why 100 threads keep only 64 of their values, why a run without a barrier
disagrees with itself, and why the slow version still gives the right
answer. An assistant cannot tell you what your machine did.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `STOP: ... must be exactly right` | A TODO is wrong. Put the control panel back to defaults and re-read the hints. |
| `STOP: every block returned 0` | TODO 1 or TODO 4 — nothing is being loaded, or nothing written out. |
| `out of host memory` | Lower `N_LOG2` to 24 and say so in your README. |
| `% of peak` above 100 | `PEAK_BW_GBS` is wrong — check your Week 4 output. |
| Timings jump around on Colab | Shared GPU. Run each three times, report the median, say so. |
