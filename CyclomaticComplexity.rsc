module CyclomaticComplexity

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;

import util::Math;

import Prelude;
import List;
import IO;



void printCyclomaticComplexity(M3 model, bool verbose)  {	
	list[num] riskTable = [0,0,0,0];
		
	for (<method,location> <- [<getMethodASTEclipse(l), l> | l <- methods(model)]) 
	{
		int cc = getCCForMethod(method);
		if(verbose)
		{
			print(location);
			print(": ");
			println(cc);
		}
		riskTable[getCCCategory(cc)] += 1;
	}
	
	list[str] rankSymbols = ["++", "+", "o", "-", "--"];
	
	list[list[num]] lookup = [[100, 25,  0, 0],
	                          [100, 30,  5, 0],
	                          [100, 40, 10, 0],
	                          [100, 50, 15, 5]];
	
	num totalUnits = sum(riskTable) + 0.0;
	
	//println("absolute values: ");
	//println(riskTable);
	
	riskTable = [toInt(v / totalUnits * 100) | v <- riskTable];
	
	int rankSymbolIndex = 0;
	
	while(rankSymbolIndex < (size(lookup) - 1) && exceeds(riskTable, lookup[rankSymbolIndex]))
	{
		rankSymbolIndex += 1;
	}
	
	println("  <riskTable>");

	print("  Rating: ");
	println(rankSymbols[rankSymbolIndex]);
}

bool exceeds(list[num] as, list[num] bs) {
	for (i <- [0..size(as)]) {
		if (as[i] > bs[i]) { 
			return true;
		}
	}
	return false;
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
		   case \switch(_, blocks): result += size(blocks);
		   case \catch(_, _): result += 1;
	}
	return result;
}