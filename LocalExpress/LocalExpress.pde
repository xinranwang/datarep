import java.util.Map;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.util.TimeZone;
import java.util.Collections;
import java.util.PriorityQueue;
import java.util.LinkedList;

SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");

HashMap<String, Cal> calendarMap = new HashMap(); // for construction only
HashMap<String, Route> routeMap = new HashMap(); // for construction only
HashMap<String, Stop> stopMap = new HashMap();
HashMap<String, Trip> tripMap = new HashMap();


Dijkstra d = new Dijkstra();
StringList uptownStopPool = new StringList();
StringList downtownStopPool = new StringList();
StringList routePool = new StringList();

HashMap<String, Vertex> uptownVertexMap = new HashMap();
HashMap<String, Vertex> downtownVertexMap = new HashMap();

ArrayList<Stop> myStops = new ArrayList();

boolean showStopName = false; 
long now = 0;

void setup() {
	size(1280, 720, P3D);
	smooth();
	sdf.setTimeZone(TimeZone.getTimeZone("UTC"));

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

	// dijkstra
	long startTime = 0L;
	int day = 0;

	Vertex startVertex = uptownVertexMap.get("127N");
	startVertex.minDistance = 0; // very start
	d.computePaths(startVertex, day, startTime, uptownVertexMap);

	for (Map.Entry me : uptownVertexMap.entrySet()){
		Vertex v = (Vertex)me.getValue();
		println(d.getShortestPathEdgesTo(v), v, v.minDistance);
	}

}

void draw() {
	background(0);
	// draw stops
	for (Stop s : myStops){
		s.update();
		s.render();
	}
}

void keyPressed() {
	if (key == 'n'){
		showStopName = !showStopName;
	}
}

void plotMap() {
	// 40.8013, 40.7093, -74.0891, -73.8511
	for (Stop s : myStops){
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

	for (String stop_id : uptownStopPool){
		Vertex v = new Vertex(stopMap.get(stop_id));
		uptownVertexMap.put(stop_id, v);
	}

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

	for (String stop_id : downtownStopPool){
		Vertex v = new Vertex(stopMap.get(stop_id));
		downtownVertexMap.put(stop_id, v);
	}
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

