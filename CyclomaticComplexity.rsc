module CyclomaticComplexity

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Prelude;
import List;
import IO;



void printCyclomaticComplexity(M3 model, bool verbose)  {	
	list[num] riskTable = [0,0,0,0];
		
	for (<method,location> <- [<getMethodASTEclipse(l), l> | l <- methods(model)]) 
	{
		int cc = getCCForMethod(method);
		if (verbose) 
		{
			print(location);
			print(": ");
			println(cc);
		}
		riskTable[getCCCategory(cc)] += 1;
	}
	
	list[str] rankSymbols = ["++", "+", "o", "-", "--"];
	
	list[list[num]] lookup = [[1, 0.25, 0.00, 0.00],
	                          [1, 0.30, 0.05, 0.00],
	                          [1, 0.40, 0.10, 0.00],
	                          [1, 0.50, 0.15, 0.05]];
	
	num totalUnits = sum(riskTable) + 0.0;
	
	println("absolute values: ");
	println(riskTable);
	
	riskTable = [v / totalUnits | v <- riskTable];
	
	int rankSymbolIndex = 0;
	
	while (rankSymbolIndex < (size(lookup) - 1) 
	       || isSmallerOrEqual(lookup[rankSymbolIndex], riskTable)) {
				rankSymbolIndex += 1;
	}
	
	println("ratings: ");
	print(rankSymbols[rankSymbolIndex] + " ");
	
	
	
	println(riskTable);
}

bool isSmallerOrEqual(list[num] as, list[num] bs) {
	for (i <- [0..size(as)]) {
		if (as[i] > bs[i]) { 
			return false;
		}
	}
	return true;
}

int getCCCategory(int complexity) {
	list[int] bounds = [10,20,50];	
	return getIndexForBoundsList(complexity, bounds);
}

int getIndexForBoundsList(int v, list[int] bounds) {
	int index = 0;
	while (index < size(bounds)) {
		if (v <= bounds[index]) {
			return index;
		}
		index += 1;
	}
	return size(bounds);
}

int getCCForMethod(Declaration method) {
	int result = 1;
	visit (method) {
		   case \if(_, _): result += 1;
		   case \if(_, _, _): result += 1;
		   case \for(_, _, _): result += 1;
		   case \for(_, _, _, _): result += 1;
		   case \foreach(_, _, _): result += 1;
		   case \while(_, _): result += 1;
		   case \defaultCase(): result += 1;
		   case \case(_): result += 1;
		   case \catch(_, _): result += 1;
	}
	return result;
}