module Runner

import lang::java::jdt::m3::Core;
import util::Math;
import IO;

import CyclomaticComplexity;
import LinesOfCode;
import RollingDup;
import UnitSize;

void run()
{
	println("Loading project...");
	model = createM3FromEclipseProject(|project://smallersql|);

	print("Calculating line count:  ");
	lineCount = getLineCount(model);
	println(lineCount);
	print("  Code volume ranking:    ");
	println(rankVolumeSIG(lineCount));
	
	println("Calculating dupe lines:  ");
	dupeLines = getDuplicateLineCount(model);
	percentage = toInt(dupeLines/lineCount*100);
	println("  Actual dupe line count: <dupeLines>  (<percentage>%)");  
	print("  Duplicate ranking:     ");
	println(rankDupSIG(percentage));
	
	println("Calculating cyclomatic complexity: ");
	cc = getCyclomaticComplexity(model);
	
	println("Calculating unit size: ");
	printUnitSize(model);
	
}
