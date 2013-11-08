import java.util.*;
import java.text.*;

PShape heart;
PFont bigFont;
PFont smallFont;

//String endPoint = "OkavangoHeartrate";
String endPoint = "http://intotheokavango.org/api/timeline?date=20130916&types=ambit";

IntDict personDict = new IntDict();

HashMap<String, ArrayList> hrMap;

SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ");
SimpleDateFormat sdfPrint = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss Z");

boolean showChart = true;

long earliestTime = 2009090232000L;
long latestTime = 0;

int[] pIds = {0, 0, 0};
HRObject[] pHeartRates = new HRObject[3];
long[] now = new long[3];

void setup() {
	//size(1280, 720, "processing.core.PGraphicsRetina2D");
    size(1280, 720, P3D);
    //hint(ENABLE_RETINA_PIXELS)
	background(0);
	stroke(255);
	fill(255);

	sdfPrint.setTimeZone(TimeZone.getTimeZone("GMT+2:00"));

	heart = loadShape("heart.svg");
	heart.disableStyle();

	bigFont = createFont("Futura Condensed.ttf", 48);
	smallFont = createFont("Futura Condensed.ttf", 14);

	JSONObject myJSON = loadJSONObject(endPoint);

	JSONArray features = myJSON.getJSONArray("features");
	//println("features.size(): "+features.size());

	// Get personDict
	for (int i = 0; i<features.size(); i++){
		JSONObject feature = features.getJSONObject(i);
		JSONObject properties = feature.getJSONObject("properties");

		String person = properties.getString("Person");
		personDict.increment(person);
	}

	String[] keys = personDict.keyArray();
	hrMap = new HashMap(keys.length);
	
	// Get data to hashmap
	for (int i = 0; i<features.size(); i++){
		JSONObject feature = features.getJSONObject(i);
		JSONObject properties = feature.getJSONObject("properties");
		HRObject hro = new HRObject(properties.getFloat("HR", -1));
		
		hro.id = feature.getInt("id");
		hro.distance = properties.getInt("Distance");
		// assign -1 to those that don't have speed and HR field
		hro.speed = properties.getFloat("Speed", -1);
		//hro.hr = properties.getFloat("HR", -1);

		try { 
          	hro.dateTime = sdf.parse(properties.getString("DateTime"));
        	//println(hro.date); 
      	} catch (ParseException e) { 
        	System.out.println("Unparseable using " + properties.getString("DateTime")); 
    	}

		hro.energyConsumption = properties.getFloat("EnergyConsumption");

		hro.person = properties.getString("Person");
		if(!hrMap.containsKey(hro.person)) {
			hrMap.put(hro.person, new ArrayList<HRObject>());
		}
		hrMap.get(hro.person).add(hro);

		if(hro.dateTime.getTime() > latestTime) latestTime = hro.dateTime.getTime();
		if(hro.dateTime.getTime() < earliestTime) earliestTime = hro.dateTime.getTime();
	}


	int i = 1;
	for (Map.Entry me : hrMap.entrySet()){
		//ArrayList l = (ArrayList)me.getValue();
		Collections.sort((ArrayList)me.getValue(), new DateComparator());
		println(me.getKey() + ": " + ((ArrayList)me.getValue()).size());	

		// println(((ArrayList<HRObject>)me.getValue()).get(0).dateTime);
		// println(((ArrayList<HRObject>)me.getValue()).get(((ArrayList<HRObject>)me.getValue()).size() - 1).dateTime);
		println("earliestTime: "+earliestTime);
		println("latestTime: "+latestTime);
		for (HRObject o : (ArrayList<HRObject>)me.getValue()){
			o.tpos = new PVector(map((float)(o.dateTime.getTime() - earliestTime), 0, (float)(latestTime - earliestTime), 0, width), 
								 map(o.hr, 0, 3, i * height / hrMap.size(), (i - 1) * height / hrMap.size()));
			println("o.dateTime.getTime(): "+ (float) o.dateTime.getTime());
			println("o.tpos.x: "+o.tpos.x);
		}

		i++;
		//noLoop();
	}

}

void draw() {
	//background(0);

	long pointedTime = (long)map(mouseX, 0, width, earliestTime, latestTime);
	noStroke();

	fill(0, 20);
  	rect(0, 0, width, height);

  	// draw timeline
  	strokeWeight(3);
	stroke(150, 0, 0);
	if(showChart) {
		line(mouseX, 0, mouseX, height - 80);
	}
	line(mouseX, height - 50, mouseX, height);

	stroke(255);
	strokeWeight(1);
	for (int j = 0; j<=width; j+=10){
		line(j, height - 20, j, height);
	}

	noStroke();
	fill(0);
	rect(0, height - 75, width, 20);

	fill(255);
	textFont(smallFont, 14);
	textAlign(CENTER);
	if(mouseX < 50) textAlign(LEFT);
	else if(mouseX > width - 50) textAlign(RIGHT);
	text(sdfPrint.format(new Date(pointedTime)), mouseX, height - 60);


  	fill(200);
	textAlign(CENTER);

	// Loop through all objects and get the closest time
	int i = 0;
	int[] ids = {0, 0, 0};
	HRObject[] heartRates = new HRObject[3];

	for (Map.Entry me : hrMap.entrySet()){
		// int id = 0;
		textFont(bigFont, 48);
		text(((String)me.getKey()).toUpperCase(), (i + 1) * width / 3 - width / 6, height / 3 + 30);
		//text(((String)me.getKey()).toUpperCase(), 50, (i + 1) * height / 3 - height / 6);

		Date closest = new Date();
		long shortest = 2009090232000L;

		strokeWeight(2);
		stroke(255);
		noFill();
		//beginShape();
		for (HRObject o : (ArrayList<HRObject>)me.getValue()){
			o.update();
			if(showChart) {
				o.render();
				//vertex(o.pos.x, o.pos.y, o.pos.z);
			}

			if((long)abs(o.dateTime.getTime() - pointedTime) < shortest && (long)abs(o.dateTime.getTime() - pointedTime) < 100000) {
				ids[i] = o.id;
				heartRates[i] = o;
				shortest = (long)abs(o.dateTime.getTime() - pointedTime);
				closest = o.dateTime;
			}
		}
		i++;
		//endShape();
		noStroke();
	}


	// draw hearts
	textFont(bigFont, 48);
	for(int j = 0; j < pHeartRates.length; j++) {
		if(pIds[j] == ids[j] && ids[j] != 0) {
			if(millis() - now[j] > heartRates[j].period && heartRates[j].period > 0) {
				heartBeat((j + 1) * width / 3 - width / 6, height / 2);
				now[j] = millis();
			}
			fill(200);
			
			if(heartRates[j].hr > 0) {
				text(int(heartRates[j].hr * 60), (j + 1) * width / 3 - width / 6, height / 3 * 2);
				textFont(smallFont, 14);
				text("BPM", (j + 1) * width / 3 - width / 6 + 42, height / 3 * 2 - 25);
				textFont(bigFont, 48);
			}
		} 
		else if (pIds[j] == ids[j] && ids[j] == 0) text("N/A", (j + 1) * width / 3 - width / 6, height / 3 * 2);
		else {
			now[j] = millis();
		}
	}

	for(int j = 0; j < pHeartRates.length; j++) {
		pHeartRates[j] = heartRates[j];
		pIds[j] = ids[j];
	}

}

void heartBeat(float x, float y) {
	fill(150, 0, 0);
	noStroke();
	pushMatrix();

	translate(x - heart.width / 2, y - heart.height / 2);
	//heart.scale(0.8);
	shape(heart, 0, 0);
	popMatrix();
}

void keyPressed() {
	if(key == 's') showChart = !showChart;
}
