class Trip {
	String route_id;
	String trip_id;
	String trip_headsign;
	int direction_id;

	ArrayList<Stop_Time> stop_times = new ArrayList();

	void sortStopTimes() {
		Collections.sort(stop_times);
	}

	void renderTrip() {
		stroke(routesMap.get(route_id).route_color);
		strokeWeight(3);
		noFill();
		beginShape();
		for (int i = 0; i<int(frameCount/10) % stop_times.size(); i++){
			Stop_Time st = stop_times.get(i);
			Stop s = st.stop;
			vertex(s.pos.x, s.pos.y, s.pos.z);
		}
		endShape();
	}
}