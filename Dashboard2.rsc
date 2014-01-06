module Dashboard2

import CyclomaticComplexity;
import UnitSize;
import Tree;

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
import util::Resources;

private M3 model;
private map[loc, num] ccs;
private map[loc, num] sizes;

private loc home = head(toList(projects()));
private loc location;

private int minimumCC = 2;

public Color purple = rgb(50,77,95);
public Color white = rgb(255,255,255);
public Color yellow = rgb(244,202,131);
public Color beige = rgb(255,239,198);
public Color black = rgb(0,0,0);
public Color background = rgb(166,130,116);

//project selection and loading:
public void renderProjectSelectionView() {
	b = button("Go", void() { 
	
		location = home;
		list[str] messages = [];
		messages += "Loading project: <home.authority> ";
		messageBox(messages);				
		model = createM3FromEclipseProject(home);
		
		messages += "Analysing model";
		messageBox(messages);	
		ccs = getCyclomaticComplexity(model);
		sizes = getUnitSizes(model);
		codeTree = getProjectStructure(home, model@containment);
		messages += "Preparing to render";
		renderProjectView();		
	});
	projs = sort([l.authority | l <- projects()]);
	t = choice(projs, void(str s) { home = toLocation("project://<s>"); });
	
	render(box(
			vcat([text("Select project:"), t,b],
				 vresizable(false),
				 vgap(10)
				 ),
			shrink(0.5,0.5),
			fillColor(rgb(235, 235, 235)),
			lineWidth(0)
		)
	);
}

private void messageBox(list[str] messages) {
	
	messages = [ text(s) | s <- messages];
	render(box(
			vcat(messages,
				 vresizable(false),
				 vgap(10)
				 ),
			shrink(0.5,0.5),
			fillColor(rgb(235, 235, 235)),
			lineWidth(0)
		)
	);
}

public void run()
{
	renderProjectSelectionView();
}

list[Figure] methodBoxes(loc parent)
{
	relevantMethods = [ l[1] | l <- model@containment+, l[0] == parent, l[1].scheme == "java+method" ];

	num maxCC = max(range(ccs));
	interestingMethods = [ <l,ccs[l]> | l <- relevantMethods, l in ccs, ccs[l] > minimumCC];
	boxes = [unitBox(sizes, l, toReal(n)) | <l, n> <- interestingMethods];
	return(boxes);
}

private str methodName = "";

Figure unitBox(sizes, l, interpolationValue) {
	bool hover = false;
	loc methodLocation = l;
	return box(
		area(pow(sizes[l]/10,2)+5),
		fillColor(Color() { return hover ? yellow : interpolateColor(white, purple, log2(interpolationValue)/log2(10)*60/100); }),
		lineWidth(0),
		onMouseEnter(void () { hover = true; methodName = methodLocation.file; println(methodName); }),
		onMouseExit(void () { hover = false; }),
		onMouseUp(bool (int butnr, map[KeyModifier,bool] modifiers)
		{
			util::Editors::edit(l);
			return true;
		})
	);
}

private void renderProjectView()
{
	set[loc] packages = packagesContainingCode(model);

	render(
		overlay([
			box(fillColor(background)),
			vcat([
				navigationTitle(),
				treemap(
					[
						clearBox(
							vcat([
								treemap(boxes),
								box(
									text("<cleanPath(pck.path)> \u2192", onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) { location = curPck; renderPackageView(curPck); }) ),
									gap(10), resizable(false), lineWidth(0)
								)
							]),
							1 + log(size(boxes), 1.2)
						) 
					| pck <- packages, curPck := pck, boxes := methodBoxes(pck), size(boxes) > 0
					]
				),
				text("<methodName>", 
				fontSize(20), fontColor(black))
			], gap(10), vstartGap(true))
		])
	);
}

private void renderPackageView(loc package)
{
	set[loc] files = filesFromPackage(package);

	render(
		overlay([
			box(fillColor(background)),
		vcat([
		navigationTitle(),
		treemap([clearBox(
			vcat([
				treemap(boxes),
				box(
					text(size(pck.file)>12 ? pck.file[0..10] + ".." : pck.file, fontSize(8)),
					gap(10), resizable(false), lineWidth(0)
				)
			]), log(size(boxes),1.1)+1
		) | pck <- files, curPck := pck, boxes := methodBoxes(pck), size(boxes) > 0 ])
	], gap(10), vstartGap(true))]));
}

private Figure navigationTitle()
{
	if(location != home)
		return overlay(
			[
				text("Class <cleanPath(location.path)>: all methods in classes", fontSize(20)),
				button(void() { returnToProjectView(); }, text("\u21A9", fontSize(20)), left())
			],
			vresizable(false)
		);
	else
		return overlay(
			[
				text("Package <cleanPath(location.path)>: all methods in classes", fontSize(20)),
				button(void() { run(); }, text("\u21A9", fontSize(20)), left())
			],
			vresizable(false)
		);
}

void returnToProjectView()
{
	location = home;
	renderProjectView();
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

public set[loc] filesFromPackage(loc package)
{
	return { x[1] | x <- model@containment, x[0] == package, x[1].scheme != "java+package" }; 
}

private Figure clearBox(Figure contents, num boxArea) = box(
	box(contents, lineWidth(20), lineColor(white)),
	area(boxArea),
	lineWidth(0),
	gap(20),
	fillColor(background)
);

private list[list[Figure]] gridify(list[Figure] figs)
{
	int height = round(sqrt(size(figs)));
	int width = height*(height) >= size(figs) ? height : height+1;

	return for(i <- [0..height])
	{
		append([ figs[j] | j <- [i*width..min(size(figs),i*width+width)] ]);
	}
}
