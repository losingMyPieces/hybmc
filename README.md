# Welcome to hybmc! (for ubuntu 20.04)

# Enviroment
Python3.6 && pynusmv

hybmc is a home-grown tool of Bounded Model Checking for Hyperproperties.
It includes several parts:

	1) NuSMV model parsing and Boolean encoding of transition relation and specification;
 
	2) HyperCTL* formula translation;
 
	3) QBF encoding of unfolding with bound k using specific semantics; and
 
	4) QBF solving with QBF solver QuAbs.  

QuAbs(https://github.com/ltentrup/quabs), is under AGPL license. (please see LICENSE.txt)  

## HOW TO USE
To run hybmc, execute ```parser.sh``` with the following scenario:

```sudo ./parser.sh <model_file_name.smv> <formula_file_name.hq> <k> ```

Note that <k> is a natural number specifies the length of unrolling.

## Run A Simple Example:
We now provide a demo example. To run, execute the followings:
  - Example 1: bakery with symmetry: 
```./parser.sh demo/bakery.smv demo/symmetry 10 pes```

## Run TACAS22 Tool Paper Experiments separately
(all models and formulas are in directory /cases)


[BAKERY]

-- 1.1 BAKERY 3PROC SYM1 --

  ./parser.sh cases/bakery_3procs.smv cases/bakery_formula_sym1_3proc.hq 10 pes
  
-- 1.2 BAKERY 3PROC SYM2 --

  ./parser.sh cases/bakery_3procs.smv cases/bakery_formula_sym2_3proc.hq 10 pes
  
-- 1.3 BAKERY 5PROC SYM1 --

  ./parser.sh cases/bakery_5procs.smv cases/bakery_formula_sym1_5proc.hq 10 pes
  
-- 1.4 BAKERY 5PROC SYM2 --

  ./parser.sh cases/bakery_5procs.smv cases/bakery_formula_sym2_5proc.hq 10 pes
  

[Mutation Testing]

  ./parser.sh cases/mutation_testing.smv cases/mutation_testing.hq 10 pes -find


[3-thread]

-- 3.1 3-thread incorrect --
  ./parser.sh cases/NI_incorrect.smv cases/NI_formula.hq 50 pes
  
-- 3.2 3-thread correct --
  ./parser.sh cases/NI_correct.smv cases/NI_formula.hq 50 opt


[并发程序无干扰性实验]

-- 4.1 3-thread incorrect NI_formula k=5、50、150、260、368 --

  ./parser.sh cases/NI_incorrect.smv cases/NI_formula.hq 5 pes
  
  ./parser.sh cases/NI_incorrect.smv cases/NI_formula.hq 50 pes
  
  ./parser.sh cases/NI_incorrect.smv cases/NI_formula.hq 150 pes

  ./parser.sh cases/NI_incorrect.smv cases/NI_formula.hq 260 pes

  ./parser.sh cases/NI_incorrect.smv cases/NI_formula.hq 368 pes

3-Threadincorrect	\phi ni	pes	368	5	0.664	0.163	0.045	0.872	0.512	0.749	0.261	1.522	SAT
3-Threadincorrect	\phi ni	pes	368	50	0.523	1.336	0.056	1.915	0.469	7.47	3.861	11.8	SAT
3-Threadincorrect	\phi ni	pes	368	150	0.475	3.031	0.102	3.608	0.497	25.484	16.681	42.662	SAT
3-Threadincorrect	\phi ni	pes	368	260	0.507	5.648	0.19	6.345	0.461	46.025	41.627	88.113	SAT
3-Threadincorrect	\phi ni	pes	368	368	0.482	7.519	0.344	8.345	0.5	66.878	71.528	138.906	SAT
![image](https://github.com/losingMyPieces/hybmc/assets/48757622/b0084c3f-58f3-44c2-b86c-da0874f04d6f)


