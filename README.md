# Welcome to hybmc! (for ubuntu 20.04)

# Enviroment
Python3.6 && pynusmv

hybmc is a home-grown tool of Bounded Model Checking for Hyperproperties.
It includes several parts:
	1) NuSMV model parsing and Boolean encoding of transition relation and specification;
	2) HyperCTL* formula translation;
	3) QBF encoding of unfolding with bound k using specific semantics; and
	4) QBF solving with QBF solver QuAbs.  

QuAbs, is under AGPL license. (please see LICENSE.txt)  

## HOW TO USE
To run hybmc, execute ```parser.sh``` with one the following scenario:

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
