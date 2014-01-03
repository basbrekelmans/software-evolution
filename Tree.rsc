module Tree

import lang::java::jdt::m3::Core;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import CyclomaticComplexity;
import IO;
import UnitSize;
import Map;
import Set;
import List;
import String;
import util::Math;
import util::Editors;


data CodeTree = Method(loc location)
			    | Package(loc location, set[CodeTree] children)
			    | Class(loc location, set[CodeTree] children)
			    | Project(loc location, CodeTree packageRoot)
				;


set[str] validSchemes = { "java+package", 
						  "java+method", 
						  "java+compilationUnit", 
						  "java+class",
						  "java+constructor" };


public CodeTree getProjectStructure(loc projectLoc, rel[loc, loc] containment) {
	
	rel[loc, loc] filteredContainment = { <p,c> | <p,c> <- containment, c.scheme in validSchemes, p.scheme in validSchemes };
	return Project(projectLoc, getCodeStructure(|java+package:///|, filteredContainment));							 
}

public set[loc] getChildren(loc location, rel[loc, loc] containment) {
	
	set[loc] result = {};
	for (<p, c> <- containment, p == location, c.scheme != "java+field", c.scheme != "java+variable") {
		if (c.scheme == "java+compilationUnit") {
			result += { c2 | <p2, c2> <- containment, p2 == c, c2.scheme != "java+field"};
		} else {
			result += c;
		}
	}
	return result;

}


public CodeTree getCodeStructure(loc location, rel[loc, loc] containment) {

	if (location.scheme == "java+constructor" || location.scheme == "java+method") {
		return Method(location);
	}
	set[CodeTree] children = {getCodeStructure(c, containment) 
								| c <- getChildren(location, containment)};
	return getItemUsingLoc(location, children);

}

public CodeTree getItemUsingLoc(loc item, set[CodeTree] children) {

	if (item.scheme == "java+class") {
		return Class(item, children);
	} else if (item.scheme == "java+package") {
		return Package(item, children);
	} else if (item.scheme == "java+project" || item.scheme == "project") {
		return Project(item, children);
	} else {
		throw "Unknown scheme: " + item.scheme + " for " + item.uri;
	}
}