---
tags:
  - uni
  - nlp
---
# Data
from this, we could go to make a very simple Naive Bayes Classifier and we wouldn't need any of the program of code, I think we could do it quite easily

# Process
this should be rather simple, given the Bayes' Rule

and pushed forward for Naive Bayes Classifier

# Naive Me
so before we getting to the actual work. I would like to do some prediction from me myself. from what I read, I can quickly assume that the $T_{1}$ surely be for sport match - the rationale is that it is about ***Team*** and ***Match*** so it is more likely to be about ***Sports*** but let's see if the calculation does work

# Text Data Preprocessing
from the Text Preparation, I will use my judgement to work around the preparation, since we won't be using any code or program. I will try to justify all my decision

1. to lower case
2. Tokenize -> by space as normal English
3. Remove Special Characters
4. Remove Stop Words of this `["a", "about", "an", "and", "are", "is", "the", "was"]`
5. Lemmatize

so after that we get this

|**id**|**list_of_vocab**|**class**|
|---|---|---|
|1|[match, thrill, team, win]|Sports|
|2|[stock, market, experience, downturn]|Finance|
|3|[player, score, amaze, goal]|Sports|
|4|[investor, concern, rise, inflation]|Finance|
|5|[coach, praise, team, performance]|Sports|
|6|[economic, report, predict, slow, growth]|Finance|

# Calculate Probability
using very simple Conditional Probability as this
$$
P(w|C) = \frac{\text{count}(w,C)}{n(C)}
$$
as the count of that distinct token in the class proportionated by total number of distinct token in that class

|**Vocabulary (w)**|**count(w,Sports)**|**count(w,Finance)**|**P(w∣Sports)**|**P(w∣Finance)**|
|---|---|---|---|---|
|**amaze**|1|0|$\frac{1}{12} \approx 0.0833$|$0$|
|**coach**|1|0|$\frac{1}{12} \approx 0.0833$|$0$|
|**concern**|0|1|$0$|$\frac{1}{13} \approx 0.0769$|
|**downturn**|0|1|$0$|$\frac{1}{13} \approx 0.0769$|
|**economic**|0|1|$0$|$\frac{1}{13} \approx 0.0769$|
|**experience**|0|1|$0$|$\frac{1}{13} \approx 0.0769$|
|**goal**|1|0|$\frac{1}{12} \approx 0.0833$|$0$|
|**growth**|0|1|$0$|$\frac{1}{13} \approx 0.0769$|
|**inflation**|0|1|$0$|$\frac{1}{13} \approx 0.0769$|
|**investor**|0|1|$0$|$\frac{1}{13} \approx 0.0769$|
|**market**|0|1|$0$|$\frac{1}{13} \approx 0.0769$|
|**match**|1|0|$\frac{1}{12} \approx 0.0833$|$0$|
|**performance**|1|0|$\frac{1}{12} \approx 0.0833$|$0$|
|**player**|1|0|$\frac{1}{12} \approx 0.0833$|$0$|
|**praise**|1|0|$\frac{1}{12} \approx 0.0833$|$0$|
|**predict**|0|1|$0$|$\frac{1}{13} \approx 0.0769$|
|**report**|0|1|$0$|$\frac{1}{13} \approx 0.0769$|
|**rise**|0|1|$0$|$\frac{1}{13} \approx 0.0769$|
|**score**|1|0|$\frac{1}{12} \approx 0.0833$|$0$|
|**slow**|0|1|$0$|$\frac{1}{13} \approx 0.0769$|
|**stock**|0|1|$0$|$\frac{1}{13} \approx 0.0769$|
|**team**|2|0|$\frac{2}{12} \approx 0.1667$|$0$|
|**thrill**|1|0|$\frac{1}{12} \approx 0.0833$|$0$|
|**win**|1|0|$\frac{1}{12} \approx 0.0833$|$0$|

# Calculate the Final Class
so finally, we will do the total calculation for the test class $T_{1}$

so if we do the same process, list of vocab in that $T_{1}$ is just
`[team,play,fantastic,match]`

> to deal with **OOV**, we will ignore and discard that term in the calculation to **not** make it total of zero, we can do smoothing by adding something to both numerator and denominator when working with [[#Calculate Probability]] but this is way simpler

|**Vocabulary (w)**|**P(w∣Sports)**|**P(w∣Finance)**|
|---|---|---|
|**team**|$\frac{2}{12} \approx 0.1667$|$\frac{0}{13} = 0$|
|**play**|$\frac{0}{12} = 0$|$\frac{0}{13} = 0$|
|**fantastic**|$\frac{0}{12} = 0$|$\frac{0}{13} = 0$|
|**match**|$\frac{1}{12} \approx 0.0833$|$\frac{0}{13} = 0$|

and then by that, we can see that the 
$$
\begin{align}
P(\text{Sports} | T_{1}) &= 0.1667 \times 0.0833 \\
P(\text{Finance} | T_{1}) &= 0
\end{align}
$$
and we can discard the $P(\text{Sports}),P(\text{Finance})$ since it is equal at $0.5$

# Conclusion
with the Probabilities calculated, we can see that 
$$
P(\text{Sports} | T_{1}) > P(\text{Finance} | T_{1})
$$
so we could conclude that the $T_{1}$ belongs to $\text{Sports}$ class
> and the [[#Naive Me]] actually make a correct prediction, or you could say that Naive Bayes Classifier make the correct prediction when compare to [[#Naive Me]]
