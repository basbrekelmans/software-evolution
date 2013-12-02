module UnitSize

import lang::java::jdt::m3::Core;

import IO;
import Relation;
import List;
import String;
import Util;
import util::Math;


private set[loc] getSourceFiles(model)
{
        return { i | i <- range(model@containment), i.scheme == "java+compilationUnit" };
}

public void printUnitSize(M3 model)
{
        sources = getSourceFiles(model);
        unitSizes = getFileUnitSize(sources, model);
        println("volume per method");
        methodLines = sum([lc | <m, lc> <- unitSizes]);
        println("total lines of code in methods: <methodLines>");
        println("number of methods: <size(unitSizes)>");
        println("sorted output: <sort([lc | <m, lc> <- unitSizes])>");
        riskTable = [0,0,0,0];
        
        for (<m, lc> <- unitSizes) {
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

list[tuple[loc, num]] getFileUnitSize(sources, model)
{
        list[tuple[loc, num]] result = [];
        ms = [<c.path, <m, c.begin.line, c.end.line>> | <m,c> <- model@declarations, m.scheme == "java+method"];
        docs = model@documentation;
        // take each file
        for(f <- sources)
        {
                docLines = docs[f];         // documentation locations
                lines = readFileLines(f);   // actual file contents

                // take each doc location
                for(dl <- docLines)
                {
                        // replace the doc with white space
                        for(lineNum <- [dl.begin.line..dl.end.line+1])
                        {
                                begin = dl.begin.column;
                                end = dl.end.column;
                                
                                if(lineNum != dl.end.line)
                                        end = size(lines[lineNum-1]);
                                if(lineNum != dl.begin.line)
                                        begin = 0;
                                
                                lines[lineNum-1] = removeComment(lines[lineNum-1], begin, end);
                        }
                }

				                str path = f.path;

			                for (<m, begin, end> <- ms[path]) {
			                	    result = result + <m, max([countNonEmptyLines(lines, begin, end + 1), 1])>;
			                }
        }
        
        return result;
}

str removeComment(str line, int begin, int end)
{
        spaces = stringChars([ 0 | x <- [0..(end-begin)] ]);
        return substring(line, 0, begin) + spaces + substring(line, end); 
}

num countNonEmptyLines(list[str] lines)
{
		       return countNonEmptyLines(lines, 0, size(lines));
}

num countNonEmptyLines(list[str] lines, int begin, int end) 
{
	  	   return size([i | i <- [begin..end], size(trim(lines[i])) > 0]);
	  	   	    
}