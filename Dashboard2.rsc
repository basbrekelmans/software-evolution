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

private map[loc, M3] modelCache = ();
private map[loc, map[loc, num]] ccCache = ();
private map[loc, map[loc, num]] sizesCache = ();
public map[loc, CodeTree] codeTreeCache = ();

private bool initialized = false;
private M3 model;
private map[loc, num] ccs;
private map[loc, num] sizes;
public CodeTree codeTree;

private loc home = head(toList(projects()));
private loc location;

private int minimumCC = 2;

public Color purple = rgb(50,77,95);
public Color white = rgb(255,255,255);
public Color yellow = rgb(244,202,131);
public Color beige = rgb(255,239,198);
public Color black = rgb(0,0,0);
public Color background = white; //rgb(166,130,116);
public Color eclipseGray = rgb(240,236,224);

//project selection and loading:
public void renderProjectSelectionView() {
	b = button("Go", void() { 
	
		location = home;
		list[str] messages = [];
		println("initialized: <initialized>");
		println("model cache: <domain(modelCache)>");
		if (initialized && location in domain(modelCache)) 
		{
			model = modelCache[home];
			ccs = ccCache[home];
			sizes = sizesCache[home];
			codeTree = codeTreeCache[home];
		}
		else {
			messages += "Loading project: <home.authority> ";
			messageBox(messages);				
			model = createM3FromEclipseProject(home);
			modelCache[home] = model;
			
			messages += "Analysing model";
			messageBox(messages);	
			ccs = getCyclomaticComplexity(model);
			ccCache[home] = ccs;
			sizes = getUnitSizes(model);
			sizesCache[home] = sizes;
			codeTree = getProjectStructure(home, model@containment);
			codeTreeCache[home] = codeTree;
			initialized = true;
		}
		
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
			fillColor(white),
			lineWidth(0)
		)
	);
}

private CodeTree getPackageOrClassNode(loc packageLoc) {
	visit (codeTree) {
		case Package(l, children): 
			if (l == packageLoc) {
				return Package(l, children);
			}
		case Class(l, children): 
			if (l == packageLoc) {
				return Class(l, children);
			}			
	}
	throw "No package exists with name: <packageLoc.uri>";
}


private void messageBox(list[str] messages) {
	
	messages = [ text(s) | s <- messages];
	render(box(
			vcat(messages,
				 vresizable(false),
				 vgap(10)
				 ),
			shrink(0.5,0.5),
			fillColor(eclipseGray),
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
	CodeTree tree = getPackageOrClassNode(parent);
	set[loc] relevantMethods = {};
	visit (tree) {
		case Method(loc methodLoc): relevantMethods += methodLoc;
	}


	num maxCC = max(range(ccs));
	interestingMethods = [ <l,ccs[l]> | l <- relevantMethods, l in ccs, ccs[l] > minimumCC];
	boxes = [unitBox(sizes, l, toReal(n)) | <l, n> <- interestingMethods];
	return(boxes);
}


Figure unitBox(sizes, l, interpolationValue) {
	bool hover = false;
	loc methodLocation = l;
	return box(
		//text(sizes[l] > 50 ? "<methodLocation.file>" : "", fontColor(interpolateColor(purple, white, log2(interpolationValue)/log2(10)*60/100)), fontSize(8)),
		area(pow(sizes[l]/10,2)+5),
		fillColor(Color() { return hover ? yellow : interpolateColor(white, purple, log2(interpolationValue)/log2(10)*60/100); }),
		lineWidth(1), lineColor(white),
		onMouseEnter(void () { hover = true; 
			println("Method information");
			println("name: <methodLocation.file>"); 
			println("full path: <methodLocation.path>"); 
			println("cc: <ccs[l]>");
			println("loc: <sizes[l]>");			
			}),
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
			box(fillColor(background), lineWidth(0)),
			vcat([
				navigationTitle(),
				treemap(
					[
						clearBox(
							vcat([
								treemap(boxes),
								box(
										text("<cleanPath(pck.path)> \u2192", onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) { location = curPck; renderPackageView(curPck); }) ),
										gap(2), resizable(true, false), lineWidth(0), fillColor(eclipseGray)
								)
							]),
							1 + log(size(boxes), 1.2)
						) 
					| pck <- packages, curPck := pck, boxes := methodBoxes(pck), size(boxes) > 0
					]
				)
			], gap(10), vstartGap(true))
		])
	);
}


private set[loc] classesInPackage(loc package) {

	CodeTree packageNode = getPackageOrClassNode(package);
	set[loc] classes = {};
	
	visit (packageNode) {
		case Class(l, _): classes += l;
	}
	
	return classes;

}

private void renderPackageView(loc package)
{
	set[loc] files = classesInPackage(package);

	render(
		overlay([
			box(fillColor(background), lineWidth(0)),
		vcat([
		navigationTitle(),
		treemap([clearBox(
			vcat([
				treemap(boxes),
				box(
					text(size(pck.file)>12 ? pck.file[0..10] + ".." : pck.file, fontSize(8)),
					gap(2), resizable(true, false), lineWidth(0), fillColor(eclipseGray)
				)
			]), log(size(boxes),1.1)+1
		) | pck <- files, curPck := pck, boxes := methodBoxes(pck), size(boxes) > 0 ])
	], gap(10), vstartGap(true))]));
}

private Figure navigationTitle()
{
	if(location != home)
		return hcat(
			[
				button("\u21A9", returnToProjectView, left(), fontSize(20), hshrink(0.1), fillColor(background)),
				box(text("Package <cleanPath(location.path)>: all methods in classes", fontSize(20)), lineWidth(0), fillColor(background)),
				box(hshrink(0.1), lineWidth(0), fillColor(background))
			],
			vresizable(false)
		);
	else
		return hcat(
			[
				button("\u21A9", run, left(), fontSize(20), hshrink(0.1), fillColor(background)),
				box(text("Project <location.authority>: all methods in packages", fontSize(20)), lineWidth(0), fillColor(background)),
				box(hshrink(0.1), lineWidth(0), fillColor(background))
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
	box(contents, lineWidth(10), lineColor(eclipseGray)),
	area(boxArea),
	lineWidth(0),
	gap(8),
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
