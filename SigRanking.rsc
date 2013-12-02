module SigRanking

import List;

public int getCategory(list[num] bounds, num val) {
    int result = 0;
    while (result < size(bounds) && val >= bounds[result]) {
    	result += 1;
    }
    return result;
}

public int getRank(list[list[num]] lookup, list[num] values) {

	int rankSymbolIndex = 0;
	while(rankSymbolIndex < (size(lookup)) 
		&& exceeds(values, lookup[rankSymbolIndex]))
	{
		rankSymbolIndex += 1;
	}
	return rankSymbolIndex; 
}

public str getRankSymbol(int score) {

	list[str] rankSymbols = ["++", "+", "o", "-", "--"];
	return rankSymbols[score];
}

private bool exceeds(list[num] as, list[num] bs) {
	for (i <- [0..size(as)]) {
		if (as[i] > bs[i]) { 
			return true;
		}
	}
	return false;
}