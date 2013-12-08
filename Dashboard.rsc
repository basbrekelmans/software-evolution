module Dashboard

import IO;
import List;
import util::Math;

import lang::java::jdt::m3::Core;

import vis::Figure;
import vis::Render;

public void run()
{
	model = createM3FromEclipseProject(|project://hsqldb|);
	packs = packagesContainingCode(model);
	println(packs);
	
	render(vcat([
		overview(model),
		grid(gridify([ clearBox(overlay([ellipse(shrink(arbReal()), fillColor("blue")), text(pck.path)])) | pck <- packs ]))
	]));
}

private Figure clearBox(Figure contents) = box(box(contents, shrink(0.9), lineColor(color("Red", 0.0))), lineColor(color("Red", 0.0)));

private list[list[Figure]] gridify(list[Figure] figs)
{
	int height = round(sqrt(size(figs)));
	int width = height*(height) >= size(figs) ? height : height+1;

	return for(i <- [0..height])
	{
		append([ figs[j] | j <- [i*width..min(size(figs),i*width+width)] ]);
	}
}

public list[list[int]] gridify2(list[int] figs)
{
	int height = round(sqrt(size(figs)));
	int width = height*(height) >= size(figs) ? height : height+1;

	return for(i <- [0..height])
	{
		append([ figs[j] | j <- [i*width..min(size(figs),i*width+width)] ]);
	}
}

private set[loc] packagesContainingCode(M3 model)
{
	return { x[0] | x <- model@containment, x[0].scheme == "java+package" && x[1].scheme != "java+package" };
}



private Figure overview(M3 model)
{
	return hcat([overviewLoc(model), overviewDup(model), overviewCC(model), overviewUnit(model)], vshrink(0.2));
}

private Figure overviewLoc(M3 model)
{
	totalLoc = 33000;
	return clearBox(vcat([
		text("Code volume"),
		clearBox(hcat([
			box(fillColor("red"), vshrink(0.3)),
			box(fillColor("yellow"), vshrink(0.3)),
			text("  33K")
		]))
	]));
}

private Figure overviewDup(M3 model)
{
	return clearBox(vcat([
		text("Duplication"),
		clearBox(hcat([
			box(fillColor("red"), hshrink(0.1), vshrink(0.3)),
			box(fillColor(color("red", 0.1)), vshrink(0.3)),
			text("  10%")
		]))
	]));		
}

private Figure overviewCC(M3 model)
{
	return clearBox(vcat([
		text("Cyclomatic complexity"),
		clearBox(hcat([
			space(size(20)),
			box(vshrink(0.5), fillColor(color("red", 0.1)), bottom()),
			box(vshrink(0.3), fillColor(color("red", 0.2)), bottom()),
			box(vshrink(0.1), fillColor(color("red", 0.3)), bottom()),
			box(vshrink(0.2), fillColor(color("red", 0.4)), bottom()),
			space(size(20))
		]))
	]));		
}

private Figure overviewUnit(M3 model)
{
	return clearBox(vcat([
		text("Unit size"),
		clearBox(hcat([
			space(size(20)),
			box(vshrink(0.5), fillColor(color("red", 0.1)), bottom()),
			box(vshrink(0.3), fillColor(color("red", 0.2)), bottom()),
			box(vshrink(0.1), fillColor(color("red", 0.3)), bottom()),
			box(vshrink(0.2), fillColor(color("red", 0.4)), bottom()),
			space(size(20))
		]))
	]));		
}
