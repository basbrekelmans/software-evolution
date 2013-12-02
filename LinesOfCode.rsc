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

public str rankVolumeSIG(int count)
{
	bounds = [66,246,665];
	i = getCategory(bounds, count / 1000);
	return getRankSymbol(i);
}