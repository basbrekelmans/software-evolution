Software Evolution Lab 2
==============

Hoofdactiviteit: het vinden van onderdelen die potentieel negatief bijdragen
aan de maintainability van het systeem op basis van beschikbare metrics van
Lab1.

De metrics die per onderdeel te berekenen zijn, unit cc en unit size, gebruiken
we voor de detectie.

Mogelijkheden met deze twee metrics:

- individuele functies vinden die potentieel negatief bijdragen
- modules met veel van dergelijke functies
- packages met veel van dergelijke functies

Beschikbare dimensies voor visualisatie:

- locatie in systeem (project -> package -> module -> unit)
- unit cc
- unit size

Technische mogelijkheden:

- omdat interactiviteit mogelijk is kunnen we heen en weer schakelen tussen verschillende niveau's

- er moet niet te weinig en niet teveel op één scherm staan

  - we kunnen niet alle bovengenoemde voorbeelden op één scherm zetten

  - maar voor inschatting van de ernst is makkelijk vergelijken wel nodig, bijvoorbeeld tussen packages

Conclusie views:

- geef meerdere niveaus:
  - het project met alle packages
  - een package met alle modules
- laat in- en uitzoomen
- laat op elk niveau de potentiële problemen zien op unitniveau
- Treemap laat twee dimensies combineren:
  - unit cc als kleurbereik
  - unit size als grootte

Usability:

- bij "inzoomen" meer detail weergeven zodat uiteindelijk niets verborgen
  blijft (menselijke controle van de algoritmische interpretatie)

- zorg dat de verschillende onderdelen van het systeem herkenbaar blijven bij
  in- en uitzoomen -- dit geeft de gebruikers een "sense of location"

- op ieder moment moet de gebruiker naar de code van opvallende units kunnen
  springen, naast het in- en uitzoomen

- het kleurbereik in de treemap moet een goede representatie zijn van de
  risico's van CC. daarom een logaritmische functie die zorgt dat een CC van 20
  op 75% kleur komt en een CC van 50 (of hoger) op 100% kleur. dit is conform
  de grenzen in het SIG-model.

- op basis van bovenstaande kleurbereik kunnen grote modules enigszins
  wegvallen tussen het kleurgeweld. daarom wordt de grootte enigszins
  overdreven middels een polynomiale functie. Erg grote code met een relatief
  lage CC wordt zo beter zichtbaar.

- Geef niet teveel en niet te weinig niveaus. Zowel `smallsql` als `hsqldb`
  kunnen af met het laten zien van alle packages (ook subpackages) in één view.
  Probleem ligt eerder bij grote hoeveelheden classes in één packages, maar dat
  kunnen we niet direct opdelen. Scrollen zou misschien slim zijn, niet gedaan.
  Relatief kleine classes vallen nu gewoon weg uit de view.

  Hierdoor kunnen we af met 2 views, waardoor de navigatie van een groot
  project ernstig versimpeld wordt ten opzichte van de complete hierarchie.

- laat goed zien waar we zijn: project of package? en waar kijken we naar?
  classes of packages? handig voor first-time users.

Bron heuristics: http://www.nngroup.com/articles/ten-usability-heuristics/

Aesthetics:

- zorg voor voldoende witruimte rondom onderdelen, geeft een rustig beeld en de
  vis library doet dit niet automatisch

- zorg voor bij elkaar passende kleuren die een prettig beeld geven (Adobe
  Kuler)









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
  |----|-----------------|
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
