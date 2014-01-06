module Drawing

import Tree;
import lang::java::jdt::m3::Core;
import vis::Figure;
import vis::Render;
import CyclomaticComplexity;
import UnitSize;
import Map;
import String;
import List;
import Set;
import util::Math;
import util::Resources;

public void renderProject(loc projectLoc) {

	list[str] messages = [];
	messages += "Loading project: <projectLoc.authority> ";
	messageBox(messages);				
	model = createM3FromEclipseProject(projectLoc);
	
	messages += "Analysing model";
	messageBox(messages);	
	ccs = getCyclomaticComplexity(model);
	sizes = getUnitSizes(model);
	codeTree = getProjectStructure(projectLoc, model@containment);
	messages += "Preparing to render";
	messageBox(messages);	
	renderMethods(projectLoc.authority, codeTree, ccs, sizes); 
}

private loc project = head(toList(projects()));

public void run() {
	b = button("Go", void() { 
		renderProject(project);
	});
	projs = sort([l.authority | l <- projects()]);
	t = choice(projs, void(str s) { project = toLocation("project://<s>"); });
	
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

private Color purple = rgb(128,0,128);
private Color white = rgb(255,255,255);
private Color yellow = rgb(255,255,0);
private Color beige = rgb(255,239,198);
private Color black = rgb(0,0,0);

Figure createBox(sizes, l, interpolationValue) {
	bool hover = false;
	return box(
				area(sizes[l]),
				fillColor(Color() { return hover ? yellow
				 : interpolateColor(white, purple, interpolationValue); }),
				lineWidth(0),
				onMouseEnter(void () { hover = true; }),
				onMouseExit(void () { hover = false; })
				);
}

void renderMethods(str projName, CodeTree tree, map[loc, num] ccs, map[loc, num] sizes) { 

	
	num maxCC = max(range(ccs));
	
		
	interestingMethods = [<l,ccs[l]> | l <- ccs, ccs[l] >2];
	
	
	boxes = [createBox(sizes, l, toReal(n / maxCC)) | <l, n> <- interestingMethods];


	render(vcat([
				//header
				box(
					text("Complexity per method for <projName>", 
						fontSize(20)),
					vresizable(false),
					lineWidth(0),
					gap(5)
				),
				//map
				box(
					treemap(boxes),
					size(100, 100)
				),
				//footer
				box(
					hcat([
						vcat([
							box(
								text("hover over a method to view details"),
								fillColor(beige),
								lineWidth(0),
								gap(20)
								)
						],
								lineWidth(0)),
						vcat([
							box(
								text("Legend", 
								vresizable(false)),
								lineWidth(0),
								vgap(10)
							),
						 	vcat([
							 	box(text("high CC",
										 fontColor(white)), 
									fillColor(purple),
									vgap(10),
									lineWidth(0)
									),
								box(text("low CC"), 
									fillColor(white),
									vgap(10),
									lineWidth(0)),
								box(text("(size indicates LOC)"),
									vgap(10), hgap(5),
									lineWidth(0))
						 	], 
							vresizable(false))							
						], 
						hresizable(false))
					]),
					lineWidth(0),
					vresizable(false)
				)
			])
		);
}