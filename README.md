Software Evolution Lab 1
========================

The program at hand will measure Java code per the metrics proposed by Heitlager, Kuipers and
Visser in [[1]]. The metrics that will be implemented are: code volume, unit complexity, 
duplication and unit size.

Metrics
----------

### Code volume

The volume is measure in *man years through backfiring function points*. The total lines of code
is compared to other programs in a heuristic that provides the associated number of man years 
given the language at hand. This number is directly projected onto a ranking.

Needed:

* lines of source code in full project: do not count comments and blank lines

* conversion table to ranking:

  |rank|Java 1.000 loc|
  |----|--------------|
  |++  |0-66          |
  |+   |66-246        |
  |o   |246-665       |
  |-   |655-1310      |
  |--  |1310-         |
  
  (the border values are ambiguous in the paper, so we should pick inclusive or exclusive end)

Questions:

* do we count Java source files only, or also configuration files, makefiles? other things we
  should or should not count?

### Complexity per unit

A histogram is made of the cyclomatic complexity per unit. The percentage of units that have 
at max 'moderate', 'high' or 'very high' complexity define bounds on the ranking.

Needed:

* cyclomatic complexity for all individual units


* lookup table for risk evaluation categories:

  |complexity|category      |
  |----------|--------------|
  |1-10      |not much risk |
  |11-20     |moderate risk |
  |21-50     |high risk     |
  |51-       |very high risk|

* calculation of histogram

* lookup table for conversion of histogram values to ranking:

  |rank|max moderate|max high|max very high|
  |----|------------|--------|-------------|
  |++  |25%         |0%      |0%           |
  |+   |30%         |5%      |0%           |
  |o   |40%         |10%     |0%           |
  |-   |50%         |15%     |5%           |
  |--  |-           |-       |-            |

### Duplication

Very simple measure: all blocks of code that are duplicated, where blocks are at least 6 lines of 
code. Exact string matching can be used, apart from indentation ("leading spaces").

Needed:

* total lines of code

* count of all code that is repeated elsewhere, with a minimum of 6 lines

* ranking table:

  |rank|% duplicated code|
  |++  |0-3              |
  |+   |3-5              |
  |o   |5-10             |
  |-   |10-20            |
  |--  |20-100           |
  
  (border values are ambiguous again)

Questions:

* do we count only code inside units or can method headers also be part of this (could be relevant 
  if complete interfaces are duplicated)

### Unit size

This one is a little underspecified in the paper.

Needed:

* lines of code per unit

* ranking table, not specified in paper

Questions:

* is lines of code per unit the *average* lines of code per unit?

* do we work based on a histogram? the paper suggests a link to the complexity calculation

[1]: http://ieeexplore.ieee.org/xpl/articleDetails.jsp?reload=true&arnumber=4335232
