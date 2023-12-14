//

fileName = "NT1N-48h-Z-Series";
sourceDir = "E:/OtherProjects/fiji/";
saveDir = "E:/OtherProjects/fiji/save_figs/";

// read raw nd2 file
sourcePath = sourceDir + fileName + ".nd2";
run("Bio-Formats Importer", "open="+sourcePath);
//open(sourcePath);

// split channels
run("Split Channels");

// stack [all] slices for channel 1
selectImage("C1-" + sourcePath);
run("Z Project...", "projection=[Max Intensity]");
selectImage("C1-" + sourcePath);
close();

// stack [all] slices for channel 2
selectImage("C2-" + sourcePath);
run("Z Project...", "projection=[Max Intensity]");
selectImage("C2-" + sourcePath);
close();

// merge channels
run("Merge Channels...", "c2=MAX_C2-"+sourcePath+" c3=MAX_C1-"+sourcePath+" create keep");

// save stacked channel 1 w/ & w/o scale bar
selectImage("MAX_C1-" + sourcePath);
saveAs("PNG", saveDir + "/Max_C1-" + fileName + ".png");
run("Scale Bar...", "width=200 height=200 thickness=10 font=20 bold overlay");
saveAs("PNG", saveDir + "/Max_C1-" + fileName + "-bar.png");
close();

// save stacked channel 2 w/ & w/o scale bar
selectImage("MAX_C2-" + sourcePath);
saveAs("PNG", saveDir + "/Max_C2-" + fileName + ".png");
run("Scale Bar...", "width=200 height=200 thickness=10 font=20 bold overlay");
saveAs("PNG", saveDir + "/Max_C2-" + fileName + "-bar.png");
close();

// save Composite 2 w/ & w/o scale bar
selectImage("Composite");
saveAs("PNG", saveDir + "/Composite-" + fileName + ".png");
run("Scale Bar...", "width=200 height=200 thickness=10 font=20 bold overlay");
saveAs("PNG", saveDir + "/Composite-" + fileName + "-bar.png");
close();


