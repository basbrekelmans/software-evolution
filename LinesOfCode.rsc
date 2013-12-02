module LinesOfCode

import lang::java::jdt::m3::Core;

import IO;
import Relation;
import List;
import String;
import FileHelper;
import SigRanking;

public num getLineCount(M3 model)
{
	sources = getSourceFiles(model);
	rawLinecount = getFileLinesOfCode(sources, model@documentation);
	return(rawLinecount);
}

public str rankVolumeSIG(num count)
{
	count = count / 1000;
	bounds = [66,246,665];
	index = getCategory(bounds, count);
	return getRankSymbol(index);
}

private num getFileLinesOfCode(sources, docs)
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


