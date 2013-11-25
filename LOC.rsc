module LOC

import lang::java::jdt::m3::Core;

import IO;
import Relation;
import List;
import String;

public num getLineCount(M3 model)
{
	sources = getSourceFiles(model);
	rawLinecount = getFileLOC(sources, model@documentation);
	return(rawLinecount);
}

public str rankVolumeSIG(num count)
{
	bounds = [<0, "++">, <66, "+">, <246, "o">, <665, "-">, <1310, "--">];

	ranking = "";
	
	for(<bnd, rank> <- bounds)
	{
		if(count/1000 >= bnd)
			ranking = rank;
	}
	
	return ranking;
}

private num getFileLOC(sources, docs)
{
	total = 0;
	
	// take each file
	for(f <- sources)
	{
		docLines = docs[f];         // documentation locations
		lines = readFileLines(f);   // actual file contents

		// take each doc location and replace with white space
		for(dl <- docLines)
			for(lineNum <- [dl.begin.line..dl.end.line+1])
			{
				begin = dl.begin.column;
				end = dl.end.column;
				
				if(lineNum != dl.end.line) end = size(lines[lineNum-1]);
				if(lineNum != dl.begin.line) begin = 0;
				
				lines[lineNum-1] = removeComment(lines[lineNum-1], begin, end);
			}

		// so now we can count all non-empty lines		
		total += size([ line | line <- lines, trim(line) != "" ]);
	}
	
	return total;
}

private str removeComment(str line, int begin, int end)
{
	spaces = stringChars([ 0 | x <- [0..(end-begin)] ]);
	return substring(line, 0, begin) + spaces + substring(line, end); 
}

private set[loc] getSourceFiles(model)
{
	return { i | i <- range(model@containment), i.scheme == "java+compilationUnit" };
}
