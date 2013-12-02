module LinesOfCode

import lang::java::jdt::m3::Core;

import Map;
import List;
import FileHelper;
import SigRanking;

public num getLineCount(M3 model)
{
	return sum([size(removeEmptyLines(f)) | f <- range(getPhysicalFilesWithoutComments(model))]);
}

public str rankVolumeSIG(num count)
{
	count = count / 1000;
	bounds = [66,246,665];
	index = getCategory(bounds, count);
	return getRankSymbol(index);
}