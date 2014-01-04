module Dashboard2

import CyclomaticComplexity;
import UnitSize;

import IO;
import List;
import Map;
import String;
import Set;
import util::Math;

import lang::java::jdt::m3::Core;

import vis::Figure;
import vis::Render;
import vis::KeySym;

import util::Editors;

private M3 model;
private map[loc, num] ccs;
private map[loc, num] sizes;

private str title;
private str content;
private loc parent;

private int minimumCC = 2;

public Color purple = rgb(128,0,128);
public Color white = rgb(255,255,255);
public Color yellow = rgb(255,255,0);
public Color beige = rgb(255,239,198);
public Color black = rgb(0,0,0);

public void run()
{
	model = createM3FromEclipseProject(|project://Karel|);
	ccs = getCyclomaticComplexity(model);
	sizes = getUnitSizes(model);

	renderProjectView();
}

list[Figure] methodBoxes(loc parent)
{
	relevantMethods = [ l[1] | l <- model@containment+, l[0] == parent, l[1].scheme == "java+method" ];
	println(relevantMethods);

	num maxCC = max(range(ccs));
	// CC magic number moet een constant worden bovenaan programma
	interestingMethods = [ <l,ccs[l]> | l <- relevantMethods, l in ccs, ccs[l] > minimumCC];
	boxes = [unitBox(sizes, l, toReal(n / maxCC)) | <l, n> <- interestingMethods];
	return(boxes);
}

Figure unitBox(sizes, l, interpolationValue) {
	bool hover = false;
	return box(
				area(sizes[l]),
				fillColor(Color() { return hover ? yellow
				 : interpolateColor(white, purple, interpolationValue); }),
				lineWidth(0),
				onMouseEnter(void () { hover = true; }),
				onMouseExit(void () { hover = false; }),
				onMouseUp(bool (int butnr, map[KeyModifier,bool] modifiers)
				{
					util::Editors::edit(l);
					return true;
				}
				));
}

private void renderProjectView()
{
	set[loc] packages = packagesContainingCode(model);

	render(vcat([
			text("Project overview", fontSize(20)),
			treemap([clearBox(
				vcat([
					treemap(boxes),
					text(cleanPath(pck.path), onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) { renderPackageView(curPck); }) )
				]), log(size(boxes), 1.2)+1
			) | pck <- packages, curPck := pck, boxes := methodBoxes(pck), size(boxes) > 0 ])
		],
		gap(10), vstartGap(true)
	));
}

bool returnToProjectView(int butnr, map[KeyModifier,bool] modifiers)
{
	renderProjectView();
	return true;
} 

str cleanPath(str path)
{
	if(path[0] == "/")
		return path[1..];
	else
		return path;
}

private set[loc] packagesContainingCode(M3 model)
{
	return { x[0] | x <- model@containment, x[0].scheme == "java+package" && x[1].scheme != "java+package" };
}

private void renderPackageView(loc package)
{
	set[loc] files = filesFromPackage(model, package);

	render(vcat([
		overlay([text("Package: <cleanPath(package.path)>", fontSize(20)), text("\u21AB", fontSize(20), left(), onMouseDown(returnToProjectView))], vresizable(false)),
		treemap([clearBox(
			vcat([
				treemap(boxes),
				text(size(pck.file)>12 ? pck.file[0..10] + ".." : pck.file, fontSize(8))
			]), log(size(boxes),1.1)+1
		) | pck <- files, curPck := pck, boxes := methodBoxes(pck), size(boxes) > 0 ])
	], gap(10), vstartGap(true)));
}

public set[loc] filesFromPackage(M3 model, loc package)
{
	return { x[1] | x <- model@containment, x[0] == package, x[1].scheme != "java+package" }; 
}

private Figure clearBox(Figure contents) = box(box(contents, shrink(0.9), lineColor(color("Red", 0.0))), lineColor(color("Red", 0.0)));
private Figure clearBox(Figure contents, num boxArea) = box(box(contents, shrink(0.9), lineColor(color("Red", 0.0))), area(boxArea), lineColor(color("Red", 0.0)));

private list[list[Figure]] gridify(list[Figure] figs)
{
	int height = round(sqrt(size(figs)));
	int width = height*(height) >= size(figs) ? height : height+1;

	return for(i <- [0..height])
	{
		append([ figs[j] | j <- [i*width..min(size(figs),i*width+width)] ]);
	}
}
