import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.*; 
import java.text.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Week3OkavangoHeartrate extends PApplet {




PShape heart;
PFont bigFont;
PFont smallFont;

String endPoint = "OkavangoHeartrate";

IntDict personDict = new IntDict();

HashMap<String, ArrayList> hrMap;

SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ");
SimpleDateFormat sdfPrint = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss Z");

boolean showChart = false;

long earliestTime = 2009090232000L;
long latestTime = 0;

int[] pIds = {0, 0, 0};
HRObject[] pHeartRates = new HRObject[3];
long[] now = new long[3];

public void setup() {
	//size(1280, 720, "processing.core.PGraphicsRetina2D");
    size(1280, 720, P3D);
    //hint(ENABLE_RETINA_PIXELS);
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

		for (HRObject o : (ArrayList<HRObject>)me.getValue()){
			o.tpos = new PVector(map((float)(o.dateTime.getTime() - earliestTime), 0, (float)(latestTime - earliestTime), 0, width),
								 map(o.hr, 0, 3, i * height / hrMap.size(), (i - 1) * height / hrMap.size()));
		}

		i++;
	}

}

public void draw() {
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
		for (HRObject o : (ArrayList<HRObject>)me.getValue()){
			// o.update();
			if(showChart) o.render();

			if((long)abs(o.dateTime.getTime() - pointedTime) < shortest && (long)abs(o.dateTime.getTime() - pointedTime) < 100000) {
				ids[i] = o.id;
				heartRates[i] = o;
				shortest = (long)abs(o.dateTime.getTime() - pointedTime);
				closest = o.dateTime;
			}
		}
		i++;
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
				text(PApplet.parseInt(heartRates[j].hr * 60), (j + 1) * width / 3 - width / 6, height / 3 * 2);
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

public void heartBeat(float x, float y) {
	fill(150, 0, 0);
	noStroke();
	pushMatrix();

	translate(x - heart.width / 2, y - heart.height / 2);
	//heart.scale(0.8);
	shape(heart, 0, 0);
	popMatrix();
}

public void keyPressed() {
	if(key == 's') showChart = !showChart;
}
class DateComparator implements Comparator<HRObject> {
	public @Override
	int compare(HRObject a, HRObject b) {
		return a.dateTime.compareTo(b.dateTime);
	}
}
class HRObject {
	int id;
	int seaLevelPressure;
	//String sampleType;
	//int t_utc; 
	int distance;
	
	float speed;
	float hr;
	String person;
	//int verticalSpeed;
	//String contentType;
	//String dateTime;
	Date dateTime;
	float energyConsumption;
	//float time;
	float temperature;
	int altitude;

	float period;

	PVector pos = new PVector();
	PVector tpos;// = new PVector();

	HRObject(float heartRate) {
		hr = heartRate;
		if(hr > 0) period = 1 / hr * 1000;
		else period = -1;
	}

	public void update() {
		pos.lerp(tpos, 0.1f);
	}

	public void render() {
		pushMatrix();
		translate(tpos.x, tpos.y);
		//text(person, 0, 0);
		fill(255);
		ellipse(0, 0, 1, 1);
		//line(0, 0, 0, height - pos.y);
		popMatrix();
	}
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Week3OkavangoHeartrate" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
