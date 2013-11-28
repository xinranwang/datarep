import java.util.Map;
import java.util.Date;
import java.text.SimpleDateFormat;

import java.util.Collections;

PVector mousePos = new PVector();

//Table stopsTable, stoptimeTable;

//ArrayList<Stop> stopsList = new ArrayList();
HashMap<String, Stop> stopsMap = new HashMap();

//ArrayList<Stop_Time> stoptimeList = new ArrayList();
HashMap<String, ArrayList<Stop_Time>> stoptimesMap = new HashMap();

//ArrayList<Trip> tripsList = new ArrayList();
HashMap<String, ArrayList<Trip>> tripsMap = new HashMap();
HashMap<String, Route> routesMap = new HashMap();

void setup() {
	size(1280, 720, P3D);

	loadStops();
	loadStopTimes();
	loadTrips();
	loadRoutes();

	plotMap();
}

void draw() {
	mousePos.set(mouseX, mouseY);
	background(0);
	for (Map.Entry me : stopsMap.entrySet()) {
		Stop s = (Stop)me.getValue();
		s.update();
		//if(s.location_type == 1) 
		s.render();
	}
	for (Map.Entry me : tripsMap.entrySet()){
		Trip t = ((ArrayList<Trip>)me.getValue()).get(0);
		t.renderTrip();
	}
}

void plotMap() {
	//40.8793, 40.5660, -74.2223, -73.5507
	for (Map.Entry me : stopsMap.entrySet()){
		Stop s = (Stop)me.getValue();
		float x = map(s.stop_lon, -74.2223, -73.5507, 0, width);
		float y = map(s.stop_lat, 40.5660, 40.8793, height, 0);
		s.tpos.set(x, y);
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
			s.parent_station = stopsMap.get(s.parent_station_string);
			//println(stopsMap.get(s.parent_station_string).stop_name);
			stopsMap.get(s.parent_station_string).child_stations.add(s);
		}

		stopsMap.put(stop_id, s);
		//stopsList.add(s);
	}
}

void loadStopTimes() {
	SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");

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
		st.trip_id = trip_id;
		st.arrival_time = arrival_time;
		st.departure_time = departure_time;
		st.stop = stopsMap.get(stop_id);
		st.stop_sequence = stop_sequence;
		//stoptimeList.add(st);
		if(!stoptimesMap.containsKey(trip_id)) {
			ArrayList<Stop_Time> l = new ArrayList();
			stoptimesMap.put(trip_id, l);
		}
		stoptimesMap.get(trip_id).add(st);
	}
}

void loadTrips() {
	Table tripsTable = loadTable("google_transit/trips.txt", "header, csv");
	for (TableRow row : tripsTable.rows()){
		String route_id = row.getString("route_id");
		String trip_id = row.getString("trip_id");
		String trip_headsign = row.getString("trip_headsign");
		int direction_id = row.getInt("direction_id");

		Trip t = new Trip();
		t.route_id = route_id;
		t.trip_id = trip_id;
		t.trip_headsign = trip_headsign;
		t.direction_id = direction_id;
		t.stop_times = stoptimesMap.get(trip_id);

		if (!tripsMap.containsKey(route_id)){
			ArrayList<Trip> l = new ArrayList();
			tripsMap.put(route_id, l);
		}
		tripsMap.get(route_id).add(t);

		//tripsList.add(t);
	}
	println("tripsMap.get: "+tripsMap.get("1").get(0).stop_times.get(0).stop.stop_id);
	//println("tripsList.size(): "+tripsList.size());
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

		routesMap.put(route_id, r);
	}
}