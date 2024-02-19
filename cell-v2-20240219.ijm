//

fileName = "150-24h-Z-Series_190";
sourceDir = "C:/Confocal20231220/";
saveDir = "C:/Confocal20231220/save_figs/";

// read raw nd2 file
for (i=0;i<10;i++){
	sourcePath = sourceDir + fileName + ".nd2";
	run("Bio-Formats Importer", "open="+sourcePath);
	
	// split channels
	run("Split Channels");
	selectImage("C2-" + sourcePath);
	sliceNum = nSlices;
	
	// calculate start/end slices
	start_slice = 1 + 15*i;
	end_slice = 15*(i+1);
	print(start_slice + '-' + end_slice);
	
	// break the loop if start_slice exceeds sliceNum
	if (start_slice > sliceNum){
		break;
	}
	
	// stack and save c2 channel
	selectImage("C2-" + sourcePath);
	run("Z Project...", "start=" + start_slice + " stop=" + end_slice + " projection=[Max Intensity]");
	save_name_c2 = "Max_C2-" + fileName + "-" + start_slice + "-" + end_slice + ".png";
	saveAs("PNG", saveDir + save_name_c2);
	close("C2-" + sourcePath);

	// stack and save c1 channel
	selectImage("C1-" + sourcePath);
	run("Z Project...", "start=" + start_slice + " stop=" + end_slice + " projection=[Max Intensity]");
	run("Duplicate...", " ");
	save_name_c1 = "Max_C1-" + fileName + "-" + start_slice + "-" + end_slice + ".png";
	saveAs("PNG", saveDir + save_name_c1);
	close("C1-" + sourcePath);
	
	// merge channel and save
	run("Merge Channels...", "c2=" + save_name_c2 + " c3="+save_name_c1+" create keep");
	saveAs("PNG", saveDir + "Composite-" + fileName + "-" + start_slice + "-" + end_slice + ".png");
	close(); close("MAX_C2-" + sourcePath);
	close(save_name_c1); close(save_name_c2);
	
	// for following stuffs
	selectImage("MAX_C1-" + sourcePath);
	run("RGB Color");
	
	// color thresholding
	avgSize = 0;
	iter = 0;
	minThreshold = 125; //254
	while (avgSize < 100 || avgSize > 300){
		iter += 1;
		//print(minThreshold);
		
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
		selectWindow("Result of Result of Hue"); rename("Thresholded-"+iter);
		
		run("Analyze Particles...", "size=50-2000 clear summarize overlay");
		avgSize = Table.get("Average Size", -1, "Summary");
		
		if (avgSize < 100 && minThreshold > 0) {
	        minThreshold -= 10;
	        Table.deleteRows(Table.size-1, Table.size-1, "Summary");
	        //close("Thresholded-"+iter);
	    } 
	    else if (avgSize > 300 && minThreshold < 255) {
	        minThreshold += 10;
	        Table.deleteRows(Table.size-1, Table.size-1, "Summary");
	        //close("Thresholded-"+iter);
	    }
		
		if (minThreshold <= 0 || minThreshold >= 255) {
	        print("Threshold adjustment out of bounds. Exiting loop.");
	        break;
	    }
	    selectImage("Thresholded-" + iter);
	    saveAs("PNG", saveDir + "Thresholded-" + fileName + "-" + start_slice + "-" + end_slice + ".png");
		close("Thresholded-" + iter);
	
	}
	
close("*");
}