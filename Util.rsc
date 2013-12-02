module Util

import lang::java::jdt::m3::Core;

import Relation;

set[loc] getSourceFiles(model)
{
	return { i | i <- range(model@containment), i.scheme == "java+compilationUnit" };
}
