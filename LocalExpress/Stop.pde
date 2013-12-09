class Stop {
	String stop_id;
	String stop_name;
	float stop_lat;
	float stop_lon;
	int location_type;
	String parent_station_string;
	Stop parent_station;

	ArrayList<Stop_Time> stList = new ArrayList();

	PVector tpos = new PVector();
	PVector pos = new PVector(random(width), random(height));

	void update() {
		pos.lerp(tpos, 0.1);
	}

	void render() {
		pushMatrix();
		translate(pos.x, pos.y, pos.z);
		noStroke();
		fill(255);
		rectMode(CENTER);
		rect(0, 0, 5, 5);
		if(showStopName) text(stop_name, 5, 5);
		popMatrix();
	}

	void sortStopTimes() {
		for (Stop_Time st : stList){
			st.sortNumber = (int)st.departure_time.getTime();
		}
		Collections.sort(stList);
	}

	Stop_Time getComingTrainStopTime(int day, long startTime, String route_id) {
		for (Stop_Time st : stList){
			if (st.trip.calendar[day] == 1 && st.departure_time.getTime() >= startTime && st.trip.route_id.equals(route_id)){
				return st;
			}
		}
		return null;
	}

	int getNumRoutes(StringList routePool) {
		IntDict routeDict = new IntDict();
		for (Stop_Time st : stList){
			if (routePool.hasValue(st.trip.route_id)){
				routeDict.increment(st.trip.route_id);
			}
		}
		println("routeDict: "+routeDict);
		return routeDict.size();
	}
}