//

fileName = "NT1N-48h-Z-Series";
sourceDir = "E:/OtherProjects/fiji/";
saveDir = "E:/OtherProjects/fiji/save_figs/";

// read raw nd2 file
sourcePath = sourceDir + fileName + ".nd2";
run("Bio-Formats Importer", "open="+sourcePath);

// split channels
run("Split Channels");
selectImage("C2-" + sourcePath);
sliceNum = nSlices;
close();

//
selectImage("C1-" + sourcePath);
run("Z Project...", "start=1 stop=50 projection=[Max Intensity]");
close("C1-" + sourcePath);
selectImage("MAX_C1-" + sourcePath);
run("RGB Color");

//
//for (i=0;i<3;i++){
avgSize = 0;
minThreshold = 50;
while (avgSize < 145 || avgSize > 155){
	
	selectImage("MAX_C1-" + sourcePath);
	run("Duplicate...", " ");
	run("HSB Stack");
	run("Convert Stack to Images");
	
	selectImage("Hue");
	setThreshold(0, 255);
	run("Convert to Mask");
	
	selectImage("Saturation");
	setThreshold(0, 255);
	run("Convert to Mask");
	
	selectImage("Brightness");
	setThreshold(minThreshold, 255);
	run("Convert to Mask");
	
	imageCalculator("AND create", "Hue", "Saturation");
	imageCalculator("AND create", "Result of Hue", "Brightness");
	
	close("Hue");
	close("Saturation");
	close("Brightness");
	close("Result of Hue");
	selectWindow("Result of Result of Hue"); rename("Thresholded");
	
	run("Analyze Particles...", "size=100-1000 clear summarize");
	avgSize = Table.get("Average Size", -1, "Summary");
	
	if (avgSize < 145 && minThreshold > 0) {
        minThreshold -= 10; // Decrease threshold if avgSize is too small
    } 
    else if (avgSize > 155 && minThreshold < 255) {
        minThreshold += 10; // Increase threshold if avgSize is too large
    }
	
	if (minThreshold <= 0 || minThreshold >= 255) {
        print("Threshold adjustment out of bounds. Exiting loop.");
        break;
    }
	close("Thresholded");

}
close("*");
