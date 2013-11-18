module LOC

import lang::java::jdt::m3::Core;

import IO;
import Relation;
import List;
import String;

void printRawLineCount(M3 model)
{
	sources = getSourceFiles(model);
	rawLinecount = getFileLOC(sources, model@documentation);
	print("Raw total line count is: ");
	println(rawLinecount);
}

set[loc] getSourceFiles(model)
{
	return { i | i <- range(model@containment), i.scheme == "java+compilationUnit" };
}

num getFileLOC(sources, docs)
{
	total = 0;
	
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

		// so now we can count all non-empty lines		
		total += countNonEmptyLines(lines);
	}
	
	return total;
}

str removeComment(str line, int begin, int end)
{
	spaces = stringChars([ 0 | x <- [0..(end-begin)] ]);
	return substring(line, 0, begin) + spaces + substring(line, end); 
}

num countNonEmptyLines(list[str] lines)
{
	return size([ line | line <- lines, trim(line) != "" ]);
}

