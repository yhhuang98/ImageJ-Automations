//

fileName = "NT8N-24h-Z-Series_194";
sourceDir = "E:/OtherProjects/fiji/";
saveDir = "E:/OtherProjects/fiji/save_figs/" + fileName + "/";

File.makeDirectory(saveDir);

// close all windows
close("*");

// read raw nd2 file
sourcePath = sourceDir + fileName + ".nd2";
run("Bio-Formats Importer", "open="+sourcePath);
sliceNum = nSlices;

// split channels
run("Split Channels");

// remove slices till sliceNum <= 150
selectImage("C1-" + sourcePath);
if (sliceNum>150) {
	run("Slice Remover", "first=151 last=" + sliceNum + " increment=1");
}
selectImage("C2-" + sourcePath);
if (sliceNum>150) {
	run("Slice Remover", "first=151 last=" + sliceNum + " increment=1");
}

// z profile for C1
run("Plots...", "width=600 height=340 font=14 draw_ticks list minimum=0 maximum=0 interpolate");
selectImage("C1-" + sourcePath);
run("Plot Z-axis Profile");
saveAs("Results", saveDir + "Plot Values.csv");

// merge channels
run("Merge Channels...", "c2=" + "C2-" + sourcePath + " c3="+"C1-" + sourcePath + " creat");

// reslice
selectImage("RGB");
run("Reslice [/]...", "output=3.45 start=Left");
close("RGB");

// 3D project
selectImage("Reslice of RGB");
run("3D Project...", "projection=[Brightest Point] axis=Y-Axis slice=3.45 initial=0 total=360 rotation=10 lower=1 upper=255 opacity=0 surface=100 interior=50");
close("Reslice of RGB");

// save image sequence and gif
selectImage("Projection of  Reslice");
run("Image Sequence... ", "dir=" + saveDir + " format=PNG name=Projection_ digits=2");
saveAs("Gif", saveDir + "Projections.gif");

// save data points from curve
selectImage("C1-" + sourcePath + "-0-0");



