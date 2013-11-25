module RollingDup

import Util;
import IO;
import List;
import String;
import Relation;
import Map;
import Set;

import lang::java::jdt::m3::Core;

alias RollingHash = rel[list[str], tuple[int, int]];

public num getDuplicateLineCount(M3 model)
{
	list[loc] files = sort(getSourceFiles(model));
	println("  Number of files: <size(files)>");
	
	// calculate rolling hashes for each line in every file
	contents = ();
	hashes = {};
	for(f <- [0..size(files)])
	{
		lines = getFileLines(files[f], model@documentation);
		contents[files[f]] = lines;
		hashes += roll(f, lines);
	}
	println("  Number of hashes: <size(hashes)>");
	
	// create hash table from rolling hashes
	table = index(hashes);
	println("  Number of unique hashes: <size(table)>");
	
	// remove hashes having only one occurence
	table = ( x:table[x] | x <- table, size(table[x]) > 1 );
	println("  Number of unique hashes with duplicates: <size(table)>");
	
	dupes = {};
	for(hash <- table)
	{
		locations = table[hash];		
		while(size(locations) > 0)
		{
			<elt, locations> = takeOneFrom(locations);
			for(elt2 <- locations, sameLine2(files, contents, elt, elt2))
			{
				locations -= elt2;
				dupes += elt; // this is inefficient
				dupes += elt2;
			}
		}
	}
	dupeIndex = index(dupes);
	
	finalCount = 0;
	for(blu <- dupeIndex)
		finalCount += size(extendl(sort(dupeIndex[blu])));
	
	return(finalCount);
	
}

public str rankDupSIG(int percentage)
{
	bounds = [<0, "++">, <3, "+">, <5, "o">, <10, "-">, <20, "--">];

	ranking = "";
	
	for(<bnd, rank> <- bounds)
	{
		if(percentage >= bnd)
			ranking = rank;
	}
	
	return ranking;
}

private rel[tuple[int,int],tuple[int,int]] combinations(table)
{
	return { <<x[0],y[0]>,<x[1],y[1]>> | x <- table, y <- table - x, x[0] < y[0] };
}

private list[int] extendl(list[int] locations)
{
	extended = [head(locations)];
	prevLoc = head(locations);
	
	for(location <- tail(locations))
	{
		if(location != 1 + prevLoc)
			extended += nextl(prevLoc);
		
		extended += location;
		prevLoc = location;
	}
	
	extended += nextl(prevLoc);
	return extended;
}

private list[int] nextl(int location)
{
	return( [ location + i | i <- [1..6] ] );
}

private bool sameLine2(list[loc] files, contents, tuple[int,int] elt, tuple[int,int] elt2)
{
	lines  = contents[files[elt[0]]];
	lines2 = contents[files[elt2[0]]];
	return(reducer( [lines[elt[1]-1+range] == lines2[elt2[1]-1+range] | range <- [0..6]], and, true ));
}

private bool and(bool fst, bool snd) = fst && snd;

private lrel[int,int] foldList(list[int] numbers)
{
	cur = head(numbers);
	len = 1;
	
	rtn = [];
	
	for(l <- tail(numbers))
	{
		if(l == cur + len)
		{
			len += 1;
		}
		else
		{
			rtn += <cur,len>;
			cur = l;
			len = 1;
		}
	}
	
	rtn += <cur,len>;
	
	return rtn;
}

private RollingHash roll(int fileNum, list[str] lines)
{
	window = 6;
	
	// early escape for short files	
	if(size(lines) < window) return {};
	
	// calculate hash for first 6 lines
	nextHash = lines[0..6];
	
	rollingHashes = {};
	rollingHashes += <nextHash, <fileNum, 1>>;
		
	for(ln <- [1..size(lines)-(window-1)])
	{
		nextHash = tail(nextHash);
		nextHash += lines[ln + window - 1];
		rollingHashes += <nextHash, <fileNum, ln+1>>;
	}

	return rollingHashes;
}

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
	
	result = [];
	for(line <- lines)
	{
		if(trim(line) != "")
			result += trim(line);
	}
	return(result);
}

private str removeComment(str line, int begin, int end)
{
	spaces = stringChars([ 0 | x <- [0..(end-begin)] ]);
	return substring(line, 0, begin) + spaces + substring(line, end); 
}
