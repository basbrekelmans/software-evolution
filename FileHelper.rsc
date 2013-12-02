module FileHelper

import lang::java::jdt::m3::Core;

import IO;
import Relation;
import String;
import List;
import Map;
import Set;

@memo 
public list[loc] getSortedSourceFileLocations(M3 model) {
	return sort(getSourceFiles(model));
}

@memo
public map[loc, list[str]] getPhysicalFilesWithoutComments(M3 model) {
	
	list[loc] files = getSortedSourceFileLocations(model);
	map[loc, list[str]] contents = ();
	hashes = {};
	for(f <- [0..size(files)])
	{
		lines = getFileLines(files[f], model@documentation);
		contents[files[f]] = lines;
	}
	return contents;
}

//gets all lines of a source file 
//excluding documentation
private list[str] getFileLines(f, docs)
{
	lines = readFileLines(f);   // actual file contents
	docLines = docs[f];         // documentation locations

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
	
   	return lines;
}

public list[str] removeEmptyLines(list[str] input) {
	result = [];
	for(line <- input)
	{
		if(trim(line) != "")
			result += trim(line);
	}
	return(result);
}

//replace all characters from begin to end in line
//by the NULL character.
public str removeComment(str line, int begin, int end)
{
	spaces = stringChars([ 0 | x <- [0..(end-begin)] ]);
	return substring(line, 0, begin) + spaces + substring(line, end); 
}

// resolves all source file locations (compilation units) out of an 
// M3 model. 
public set[loc] getSourceFiles(model)
{
	return { i | i <- range(model@containment), i.scheme == "java+compilationUnit" };
}

//counts lines that are nonempty
num countNonEmptyLines(list[str] lines)
{
	return countNonEmptyLines(lines, 0, size(lines));
}

//counts lines between begin and end that are nonempty
num countNonEmptyLines(list[str] lines, int begin, int end) 
{
	return size([i | i <- [begin..end], size(trim(lines[i])) > 0]);
	  	   	    
}