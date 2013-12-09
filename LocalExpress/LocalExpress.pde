import java.util.Map;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.util.TimeZone;
import java.util.Collections;
import java.util.PriorityQueue;
import java.util.LinkedList;

SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
PFont font;

HashMap<String, Cal> calendarMap = new HashMap(); // for construction only
HashMap<String, Route> routeMap = new HashMap(); // for construction only
HashMap<String, Stop> stopMap = new HashMap();
HashMap<String, Trip> tripMap = new HashMap();

Dijkstra d = new Dijkstra();

StringList uptownStopPool = new StringList();
StringList downtownStopPool = new StringList();
StringList routePool = new StringList();

StringList downtownPool = new StringList();

ArrayList<Stop> myStops = new ArrayList();

boolean showStopName = true; 
boolean showTrails = false;
boolean renderAll = false;
long now = 0;
int day = 0;
int timeSpeed = 100;

boolean runOnce = true;

Trail[] trails = new Trail[720]; // from 9 to 9
long beginTime = 32400000;

ArrayList<Trip> redDowntown = new ArrayList();

ArrayList<Trip> allTrips = new ArrayList();

PVector zoom = new PVector();
PVector tzoom = new PVector();

void setup() {
	size(1280, 720, P3D);
	smooth();
	sdf.setTimeZone(TimeZone.getTimeZone("UTC"));
	font = createFont("Helvetica.ttf", 14);
	textFont(font, 14);

	// load everything
	loadCalendar();
	loadRoutes();
	loadStops();
	loadTrips();
	loadStopTimes();

	// setup everything
	setupPools();
	getMyStops();
	plotMap();

	getSelectedTrips(day, routePool, 1);
	getAllTrips(day);

	for (int i = 0; i<trails.length; i++){
		trails[i] = new Trail(day, beginTime, "120", downtownPool, downtownPool);
		Trail t = trails[i];
		float x = map((float)i, 0, (float)trails.length, 500, width);
		float y = height/2;
		t.tpos.set(x, y);
		t.setVertexPos();
		beginTime+=60000;
		t.downtown.printPaths();
	}
	

}

void draw() {
	background(0);
	now = millis()*timeSpeed;
	zoom.lerp(tzoom, 0.1);
	Date nowDate = new Date(now);
	fill(255);
	text(sdf.format(now) + " - MONDAY", 50, 50);

	// translate(width / 2, height / 2);
	// 	rotateX( map(mouseY, 0, height, 0, PI/2) );
	// 	rotateZ( map(mouseX, 0, width, 0, TAU) ); // TWO_PI
	// translate(-width / 2, -height);
	translate(zoom.x, zoom.y, zoom.z);

	//draw stops
	for (Stop s : myStops){
		s.update();
		s.render();
	}

	if (showTrails){
		for (Trail t : trails){
			t.update();
			t.render();
		}
	}


	if (runOnce){
		setupAllTrips();
		runOnce = false;
	}

	if (renderAll){
		for (Trip t : allTrips){
			t.renderTrip();
		}
	} else {
		for (Trip t : redDowntown){
			t.renderTrip();

		}
	}



}


void keyPressed() {
	if (key == 'n'){
		showStopName = !showStopName;
	} else if (key == 'a') {
		renderAll = !renderAll;
		setupAllTrips();
	} else if (key == 'z') {
		tzoom.z = -1000 - tzoom.z;
	} else if (key == 't') {
		showTrails = !showTrails;
	}
}

void getSelectedTrips(int day, StringList routePool, int direction) {
	for (Map.Entry me : tripMap.entrySet()){
		Trip t = (Trip)me.getValue();
		if (t.calendar[day] == 1 && routePool.hasValue(t.route_id) && t.direction_id == direction){
			redDowntown.add(t);
		}
	}
}

void getAllTrips(int day) {
	for (Map.Entry me : tripMap.entrySet()){
		Trip t = (Trip)me.getValue();
		if (t.calendar[day] == 1){
			allTrips.add(t);
		}
	}
}

void setupAllTrips() {
	for (Trip t : allTrips){
		t.setupTrip();
	}
}

void plotMap() {
	// 40.8013, 40.7093, -74.0891, -73.8511
	for (Map.Entry me : stopMap.entrySet()){
		Stop s = (Stop)me.getValue();
		float x = map(s.stop_lon, -74.0891, -73.8511, 0, width);
		float y = map(s.stop_lat, 40.7093, 40.8013, height, 0);
		s.tpos.set(x, y);
	}
}

void setupPools() {
	routePool.append("1");
	routePool.append("2");
	routePool.append("3");

	uptownStopPool.append("127N");
	uptownStopPool.append("126N");
	uptownStopPool.append("125N");
	uptownStopPool.append("124N");
	uptownStopPool.append("123N");
	uptownStopPool.append("122N");
	uptownStopPool.append("121N");
	uptownStopPool.append("120N");

	// for (String stop_id : uptownStopPool){
	// 	Vertex v = new Vertex(stopMap.get(stop_id));
	// 	uptownVertexMap.put(stop_id, v);
	// }

	downtownStopPool.append("127S");
	downtownStopPool.append("128S");
	downtownStopPool.append("129S");
	downtownStopPool.append("130S");
	downtownStopPool.append("131S");
	downtownStopPool.append("132S");
	downtownStopPool.append("133S");
	downtownStopPool.append("134S");
	downtownStopPool.append("135S");
	downtownStopPool.append("136S");
	downtownStopPool.append("137S");

	downtownPool.append("120S");
	downtownPool.append("121S");
	downtownPool.append("122S");
	downtownPool.append("123S");
	downtownPool.append("124S");
	downtownPool.append("125S");
	downtownPool.append("126S");
	downtownPool.append("127S");
	downtownPool.append("128S");
	downtownPool.append("129S");
	downtownPool.append("130S");
	downtownPool.append("131S");
	downtownPool.append("132S");
	downtownPool.append("133S");
	downtownPool.append("134S");
	downtownPool.append("135S");
	downtownPool.append("136S");
	downtownPool.append("137S");

	// for (String stop_id : downtownStopPool){
	// 	Vertex v = new Vertex(stopMap.get(stop_id));
	// 	downtownVertexMap.put(stop_id, v);
	// }
}

void getMyStops() {
	for (String stop_id : uptownStopPool){
		myStops.add(stopMap.get(stop_id));
	}
	for (String stop_id : downtownStopPool){
		myStops.add(stopMap.get(stop_id));
	}
}

void loadCalendar() {
	Table calendarTable = loadTable("google_transit/calendar.txt", "header, csv");

	for (TableRow row : calendarTable.rows()){
		String service_id = row.getString("service_id");

		Cal c = new Cal();
		c.service_id = service_id;

		for (int i = 1; i<8; i++){
			c.calendar[i-1] = row.getInt(i);
		}
		calendarMap.put(service_id, c);
	}
}

void loadStops() {
	Table stopsTable = loadTable("google_transit/stops.txt", "header, csv");

	for (TableRow row : stopsTable.rows()){
		String stop_id = row.getString("stop_id");
		String stop_name = row.getString("stop_name");
		float stop_lat = row.getFloat("stop_lat");
		float stop_lon = row.getFloat("stop_lon");
		int location_type = row.getInt("location_type");
		String parent_station_string = row.getString("parent_station");

		Stop s = new Stop();
		s.stop_id = stop_id;
		s.stop_name = stop_name;
		s.stop_lat = stop_lat;
		s.stop_lon = stop_lon;
		s.location_type = location_type;
		s.parent_station_string = parent_station_string;

		if (s.location_type == 0){
			s.parent_station = stopMap.get(s.parent_station_string);
			//stopMap.get(s.parent_station_string).child_stations.add(s);
		}

		stopMap.put(stop_id, s);
	}
}

void loadRoutes() {
	Table routesTable = loadTable("google_transit/routes.txt", "header, csv");
	for (TableRow row : routesTable.rows()){
		String route_id = row.getString("route_id");
		String route_long_name = row.getString("route_long_name");
		color route_color = color(unhex("FF" + row.getString("route_color")));

		Route r = new Route();
		r.route_id = route_id;
		r.route_long_name = route_long_name;
		r.route_color = route_color;

		routeMap.put(route_id, r);
	}
}

void loadTrips() {
	Table tripsTable = loadTable("google_transit/trips.txt", "header, csv");
	for (TableRow row : tripsTable.rows()){
		String route_id = row.getString("route_id");
		String service_id = row.getString("service_id");
		String trip_id = row.getString("trip_id");
		String trip_headsign = row.getString("trip_headsign");
		int direction_id = row.getInt("direction_id");

		Trip t = new Trip();
		t.route_id = route_id;
		t.route = routeMap.get(route_id);
		t.service_id = service_id;
		t.trip_id = trip_id;
		t.trip_headsign = trip_headsign;
		t.direction_id = direction_id;
		t.calendar = calendarMap.get(service_id).calendar;

		tripMap.put(trip_id, t);
	}
}

void loadStopTimes() {
	Table stoptimeTable = loadTable("google_transit/stop_times.txt", "header, csv");

	for (TableRow row : stoptimeTable.rows()){
		String trip_id = row.getString("trip_id");
		Date arrival_time = new Date(); 
		Date departure_time = new Date();
		try {
			arrival_time = sdf.parse(row.getString("arrival_time"));
			departure_time = sdf.parse(row.getString("departure_time"));
		} catch (Exception e) {
			println("e: "+e);
		}
		String stop_id = row.getString("stop_id");
		int stop_sequence = row.getInt("stop_sequence");
		
		Stop_Time st = new Stop_Time();
		//st.trip_id = trip_id;
		st.trip = tripMap.get(trip_id);
		st.arrival_time = arrival_time;
		st.departure_time = departure_time;

		st.stop = stopMap.get(stop_id);
		st.stop_sequence = stop_sequence;

		tripMap.get(trip_id).stop_times.add(st);
		stopMap.get(stop_id).stList.add(st);
	}

	// sortStopTimes within Trips
	for (Map.Entry me : tripMap.entrySet()){
		Trip t = (Trip)me.getValue();
		t.sortStopTimes();

		for (int i = 0; i<t.stop_times.size() - 1; i++){
			t.stop_times.get(i).nextStopTime = t.stop_times.get(i+1);
		}
	}

	// sortStopTimes within Stops
	for (Map.Entry me : stopMap.entrySet()){
		Stop s = (Stop)me.getValue();
		s.sortStopTimes();
	}
}

