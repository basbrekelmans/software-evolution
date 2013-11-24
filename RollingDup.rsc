module RollingDup

import Util;
import IO;
import List;
import String;
import Relation;
import Map;
import Set;

import lang::java::jdt::m3::Core;

alias RollingHash = rel[int, tuple[loc, int]];

void printDup()
{
	M3 model = createM3FromEclipseProject(|project://Karel|);
	set[loc] files = getSourceFiles(model);
	
	// calculate rolling hashes for each line in every file
	hashes = {};
	for(f <- files)
	{
		lines = readFileLines(f);	
		hashes += roll(f, lines);
	}
	
	// create hash table from rolling hashes
	map[int, rel[loc,int]] table = index(hashes);
	
	// create a set of locations that have the same hash
	dupes = union({ combinations(table[x]) | x <- table, size(table[x]) > 1 });
	print("Number of potential 6-line duplicates: ");
	println(size(dupes));
	
	// group all combinations that have the same files
	count = 0;
	groups = {};
	
	for(x <- dupes)
	{
		// make sure locations are in alphabetical order for later comparison
		element = sort(x);
		
		loc1 = element[0][0];
		loc2 = element[1][0];
		pos1 = element[0][1];
		pos2 = element[1][1];
		
		groups += <<loc1, loc2>, <pos1, pos2>>;
		
		// report progress to user
		count+= 1;
		if(count % 10000 == 0) println("Progress: <count>");
	}

	combos = index(groups);
	print("Number of file combinations: ");
	println(size(combos));
	
	// analyze all the potential combinations
	finalDupeLocs = {}; 
	
	for(fl <- combos)
	{
		// augment the location list of lines to be compared
		locations = extendLoc(sort(toList(combos[fl]), cmpHead));
		lines = [ readFileLines(fl[0]), readFileLines(fl[1]) ];
		
		// count matched lines in this combo
		count = 0;
		lastLoc = <-10,-10>;
		
		for(ll <- locations)
		{
			if(incr(lastLoc) != ll || !sameLine(lines, ll))
			{
				if(count >= 6)
				{
					finalDupeLocs += { <fl[0], lastLoc[0]-1-j> | j <- [0..count] };
					finalDupeLocs += { <fl[1], lastLoc[1]-1-j> | j <- [0..count] };
				}
				count = 0;
			}
			else
				count += 1;
			
			lastLoc = ll;
		}

		if(count >= 6)
		{
			finalDupeLocs += { <fl[0], last(locations)[0]-1-j> | j <- [0..count] };
			finalDupeLocs += { <fl[1], last(locations)[1]-1-j> | j <- [0..count] };
		}
	}
	
	dupeIndex = index(finalDupeLocs);
	
	for(blu <- dupeIndex)
	{
		println(blu);
		println(foldList(sort(dupeIndex[blu])));
	}
}

set[rel[loc,int]] combinations(table)
{
	return( { {x,y} | x <- table, y <- table - x } );
}

lrel[int,int] extendLoc(lrel[int,int] locations)
{
	extended = [head(locations)];
	prevLoc = head(locations);
	
	for(location <- tail(locations))
	{
		if(location != incr(prevLoc))
			extended += nextLocs(prevLoc);
		
		extended += location;
		prevLoc = location;
	}
	
	extended += nextLocs(prevLoc);
	return extended;
}

lrel[int,int] nextLocs(tuple[int,int] location)
{
	return(zip([location[0]+1..location[0]+6],[location[1]+1..location[1]+6]));
}

bool sameLine(list[list[str]] lines, tuple[int,int] locations)
{
	return( lines[0][locations[0]-1] == lines[1][locations[1]-1] );
}

bool cmpHead(tuple[int,int] a, tuple[int,int] b) = a[0] < b[0];

lrel[int,int] foldList(list[int] numbers)
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

tuple[int,int] incr(<int x, int y>) { return <x+1,y+1>; }
tuple[loc,int] incr(<loc l, int x>) { return <l,x + 1>; }

RollingHash roll(f, list[str] lines)
{
	hashes = mapper(lines, hashLine);
	cursor = 0;
	window = 6;
	
	// skip big comments at start of file
	while(hashes[cursor] == 99)
		cursor += 1;

	// early escape for short files	
	if(size(lines) < cursor + window) return {};
	
	// calculate hash for first 6 lines
	first = hashes[cursor];
	
	for(i <- [cursor+1..cursor+window])
	{
		first *= 100;
		first += hashes[i];
	}

	rollingHashes = {};
	rollingHashes += <first, <f, cursor+1>>;
	
	nextHash = first;
	
	powWindow = pow(window);
	
	for(ln <- [cursor+1..size(lines)-(window-1)])
	{
		nextHash = (nextHash * 100) % powWindow;
		nextHash += hashes[ln + window - 1];
		rollingHashes += <nextHash, <f, ln+1>>;
	}
	
	return rollingHashes;
}

int hashLine(str line)
{
	line = trim(line);

	if(startsWith(line, "/*") || startsWith(line,"*"))
		// big comments get hash 99
		return 99;
	else
	{
		// other lines get the line length
		modulo = 88;
		content = size(line);
		return 11 + content % modulo;
	}
}

int pow(int exp)
{
	if (exp == 0)
	{
		return 1;
	}
	else
	{
		return 100 * pow(exp - 1);
	}
}




