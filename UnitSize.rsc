module UnitSize

import lang::java::jdt::m3::Core;

import IO;
import Relation;
import List;
import String;
import Util;
import util::Math;
import FileHelper;


void test123(M3 model)
{
        sources = getSourceFiles(model);
        unitSizes = getFileUnitSize(sources, model);
        println("volume per method");
        methodLines = sum([lc | <m, lc> <- unitSizes]);
        println("total lines of code in methods: <methodLines>");
        println("number of methods: <size(unitSizes)>");
        println("sorted output: <sort([lc | <m, lc> <- unitSizes])>");
        sizes = [0,0,0,0];
        bounds = [30, 44, 74];
        for (<m, lc> <- unitSizes) {
        	     int cat = getSigCategory(bounds, lc);
        	  	   sizes[cat] += 1;
        }
        
        real sumSizes = toReal(sum(sizes));
        sizes = [toInt(i / sumSizes * 100) | i <- sizes];
        
        println(sizes);
        
        
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