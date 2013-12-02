module CyclomaticComplexity

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;

import util::Math;

import Prelude;
import List;
import IO;
import UnitSize;
import FileHelper;
import Map;
import SigRanking;

map[loc, num] getCyclomaticComplexity(M3 model)  {	
	map[loc, num] complexities = ();
	map[loc, num] sizes = getUnitSizes(model);
	
	list[num] riskTable = [0,0,0,0];
	for (<method,location> <- [<getMethodASTEclipse(m), l> |  <m,l> <- model@declarations, m.scheme == "java+method"]) 
	{
		int cc = getCCForMethod(method);
		complexities[location] = cc;
		int category = getCCCategory(cc);
		riskTable[getCCCategory(cc)] += sizes[location];
	}
	
	
	
	list[list[num]] lookup = [[100, 25,  0, 0],
	                          [100, 30,  5, 0],
	                          [100, 40, 10, 0],
	                          [100, 50, 15, 5]];
	
	num totalUnits = sum(riskTable) + 0.0;
	
	riskTable = [toInt(v / totalUnits * 100) | v <- riskTable];
	
	
	
	println("<riskTable>");

	print("  Rating: ");
	println(getRankSymbol(getRank(lookup, riskTable)));
	return complexities;
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
	return getCategory(bounds, complexity);
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
		   case \switch(_, blocks): result += 1;
		   case \catch(_, _): result += 1;
	}
	return result;
}