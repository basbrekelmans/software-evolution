module UnitSize

import lang::java::jdt::m3::Core;

import IO;
import Relation;
import List;
import Set;
import String;
import FileHelper;
import Map;
import util::Math;


public void printUnitSize(M3 model)
{
        sources = getSourceFiles(model);
        unitSizes = getUnitSizes(model);
        println("volume per method");
        methodLines = sum(range(unitSizes));
        println("total lines of code in methods: <methodLines>");
        println("number of methods: <size(unitSizes)>");
        riskTable = [0,0,0,0];
        
        for (lc <- range(unitSizes)) {
        	     int cat = getUSCategory(lc);
        	  	   riskTable[cat] += 1;
        }
        
        //real sumSizes = toReal(sum(sizes));
        //riskTable = [toInt(i / sumSizes * 100) | i <- sizes];
        //
        //println(riskTable);
        
        
        
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


int getUSCategory(int methodSize) {
    bounds = [30, 44, 74];
    int result = 0;
    while (result < size(bounds) && methodSize >= bounds[result]) {
    		    result += 1;
    }
    return result;
        
}

map[loc, num] getUnitSizes(model)
{
        list[tuple[loc, num]] result = [];
        ms = [<c.path, <c, c.begin.line, c.end.line>> | <m,c> <- model@declarations, m.scheme == "java+method"];
        fileContents = getPhysicalFilesWithoutComments(model);
        // take each file
        for(f <- domain(fileContents))
        {
	       	str path = f.path;
	        lines = fileContents[f];
	        for (<m, begin, end> <- ms[path]) {
	        	    result = result + <m, max([countNonEmptyLines(lines, begin, end), 1])>;
	        }
        }
        
        return toMapUnique(result);
}