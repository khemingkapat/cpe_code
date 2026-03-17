# 1. SKN Club
## Question
 Joe, June and Jack belong to the SKN Club. Every member of the SKN Club is either a runner or a footballer or both. No footballer likes rain, and all runners like sunny. Joe dislikes whatever Jack likes and likes whatever Jack dislikes. June likes rain and sunny.

## Original Clauses
$$
\begin{align}
&1. inClub(Joe,SKN)\\
&2. inClub(June,SKN)\\
&3. inClub(Jack,SKN) \\
&4. \forall_{x} InClub(x,SKN)\implies (is(x,Runner) \lor is(x,Footballer)) \\
&5. \forall_{x} is(x,Footballer)\implies \neg like(x,Rain) \\
&6. \forall_{x} is(x,Runner)\implies like(x,Sunny) \\
&7. \forall_{x} \neg like(Joe,x)\implies like(Jack,x) \\
&8. \forall_{x} like(Joe,x)\implies \neg like(Jack,x) \\
&9. like(June,Rain) \\
&10. like(June,Sunny)
\end{align}
$$
## CNF Form
$$
\begin{align}
C_{1} &= inClub(Joe,SKN) \\
C_{2} &= inClub(June,SKN) \\
C_{3} &= inClub(Jack,SKN) \\
C_{4}&=\neg inClub(x,SKN) \lor is(x,Runner) \lor is(x,Footballer) \\
C_{5}&=\neg is(x,Footballer) \lor \neg like(x,Rain)\\
C_{6}&=\neg is(x,Runner) \lor like(x,Sunny) \\
C_{7}&=like(Joe,x) \lor like(Jack,x) \\
C_{8}&=\neg like(Joe,x) \lor \neg like(Jack,x)\\
C_{9}&=like(June,Rain)\\
C_{10}&=like(June,Sunny)\\
\end{align}
$$
then we add
$$
\begin{align}
C_{11}&=\neg\exists_{x} inClub(x,SKN)\land \\
&(is(x,Footballer)\land \neg is(x,Runner)) \\
&= \neg inClub(x,SKN) \lor \neg is(x,Footballer) \lor is(x,Runner)
\end{align}
$$
## Refutation
$$
\begin{align}
12. & \neg is(Joe, Footballer) \lor is(Joe,Runner) & (11, 1, \{x=Joe\}) \\
13. & \neg is(Joe, Footballer) \lor like(Joe, Sunny) & (12, 6, \{x=Joe\}) \\
14. & \neg like(Joe, Rain) \lor like(Joe, Sunny) & (13, 5, \{x=Joe\}) \\
15. & like(Jack, Rain) \lor like(Joe, Sunny) & (14, 10, \{x=Rain\}) \\
16. & like(Jack, Rain) \lor \neg like(Jack, Sunny) & (15, 9, \{x=Sunny\}) \\
17. &\neg is(Jack,Footballer) \lor \neg like(Jack,Sunny)&(16,5,\{ x=Jack \}) \\
18. &\neg is(Jack,Footballer) \lor \neg is(Jack,Runner)&(17,6,\{ x = Jack \}) \\
19. &\neg inClub(Jack,SKN)&(18,4,\{ x=Jack \}) \\
20. &\text{False}&(19,3,\{ x=Jack \})
\end{align}
$$
# 2. Axioms
$$
\begin{align}
1.&\text{Grandchild(x,y)} \iff \exists_{z}(\text{child}(x,z)\land \text{child(z,y)}) \\
2.& \text{Daughter}(t,u) \iff \text{Female}(t) \land \text{child}(t,u) \\
3.&\text{Son}(r,s) \iff \text{Male}(r) \land \text{child}(r,s) \\
4. & \text{AuntOrUncle}(k,l) \iff \exists_{x} \text{Sibling}(k,x) \land \text{child}(x,l) \\
5. & \text{Aunt}(k,l) \iff \exists_{x} \text{Female}(k)\land\text{Sibling}(k,x) \land \text{child}(x,l) \\
6. & \text{Uncle}(g,h) \iff \text{Male}(g) \land \exists_{x}(\text{Sibling}(g,x) \land \text{Child}(h,x)) \\
7. & \text{BrotherInLaw}(e,f) \iff \text{Male}(e) \land \exists_{z}(\text{Spouse}(e,z) \land \text{Sibling}(z,f)) \\
8. & \text{SisterInLaw}(c,d) \iff \text{Female}(c) \land \exists_{z}(\text{Spouse}(c,z) \land \text{Sibling}(z,d)) \\
9. & \text{Cousin}(a,b) \iff \exists_{p1, p2}(\text{Child}(a,p1) \land \text{Child}(b,p2) \land \text{Sibling}(p1,p2))
\end{align}
$$


# 3. 7-11's Snacks and Drinks
## Clauses
$$
\begin{align}
1.& \neg Soda(s_{1}) \lor \neg Chips(c_{1}) \lor Cheaper(s_{1},c_{1}) \\
2.& \neg Chips(c_{2}) \lor \neg Cereals(c_{3}) \lor Cheaper(c_{2},c_{3}) \\
3.&\neg Cheaper(x,y) \lor \neg Cheaper(y,z) \lor Cheaper(x,z)
\end{align}
$$
## Refutation Clause
$$
\begin{align}
&\neg\exists_{x}\text{Cheaper}(x,Cheerios) \\
&=\forall_{x}\neg\text{Cheaper}(x,Cheerios) \\
&=\neg Cheaper(x,Cheerios)&(4)
\end{align}
$$
## Refutation Process
$$
\begin{align}
5. & \neg Chips(c_2) \lor \neg Cereals(Cheerios) && (2, 4, \{c_3 = Cheerios\}) \\ 6. & \neg Chips(c_2) && (5, \text{Fact: Cereals(Cheerios)}) \\ 7. & \text{False} && (6, \text{Fact: Chips(Lay's)}, \{c_2 = Lay's\}) \\
6. & \neg Cheaper(x, y) \lor \neg Cheaper(y, Cheerios) && (3, 4, \{z = Cheerios\}) \\ 9. & \neg Cheaper(x, Lay's) && (8, \text{Step 7 result}, \{y = Lay's\}) \\ 10. & \neg Soda(x) \lor \neg Chips(Lay's) && (9, 1, \{c_1 = Lay's, s_1 = x\}) \\ 11. & \neg Soda(x) && (10, \text{Fact: Chips(Lay's)}) \\ 12. & \text{False} && (11, \text{Fact: Soda(Zero)}, \{x = Zero\})
\end{align}
$$

so we could get that both $Zero$ and $Lay's$ is cheaper than cheerios
