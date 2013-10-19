import java.util.*;
//import java.util.Map;
import java.text.*;
//import java.text.SimpleDateFormat;

String endPoint = "OkavangoHeartrate";

IntDict personDict = new IntDict();

HashMap<String, ArrayList> hrMap;

SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ");

int noHRcount = 0;
int noSpeedcount = 0;
int noHRSpeed = 0;

void setup() {
	//size(1280, 720, "processing.core.PGraphicsRetina2D");
    size(1280, 720, P3D);
    //hint(ENABLE_RETINA_PIXELS);
	background(0);
	stroke(255);
	fill(255);

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
		HRObject hro = new HRObject();
		
		hro.id = feature.getInt("id");
		hro.distance = properties.getInt("Distance");
		// assign -1 to those that don't have speed and HR field
		hro.speed = properties.getFloat("Speed", -1);
		hro.hr = properties.getFloat("HR", -1);

		if (hro.hr == -1){
			noHRcount++;
		}
		if (hro.speed == -1){
			noSpeedcount++;
		}
		if (hro.hr == -1 && hro.speed == -1){
			noHRSpeed++;
		}

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
	}

	println("hrMap: "+hrMap.size());
	//println(hrMap.get("Steve").size());
	for (Map.Entry me : hrMap.entrySet()){
		//ArrayList l = (ArrayList)me.getValue();
		Collections.sort((ArrayList)me.getValue(), new DateComparator());
		println(me.getKey() + ": " + ((ArrayList)me.getValue()).size());	

		for (HRObject o : (ArrayList<HRObject>)me.getValue()){
			//println(me.getKey() + " dateTime: "+o.dateTime);
			//println("o.dateTime.getTime(): "+o.dateTime.getTime());

			o.tpos = new PVector(map(o.dateTime.getTime(), 1379051558000L, 1379090232000L, 0, width), 
								 map(o.hr, 0, 3, height, 0));
			
			// o.tpos = new PVector(random(width), random(height));
		}
	}
	println("noHRcount: "+noHRcount);
	println("noSpeedcount: "+noSpeedcount);
	println("noHRSpeed: "+noHRSpeed);
}

void draw() {
	background(0);

	// Loop through all objects
	for (HRObject o : (ArrayList<HRObject>)hrMap.get("Steve")){
		o.update();
		o.render();
	}
}
