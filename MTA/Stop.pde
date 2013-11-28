class Stop {
	String stop_id;
	String stop_name;
	float stop_lat;
	float stop_lon;
	int location_type;
	String parent_station_string;
	Stop parent_station;
	ArrayList<Stop> child_stations = new ArrayList();

	PVector tpos = new PVector();
	PVector pos = new PVector(random(width), random(height));

	void update() {
		pos.lerp(tpos, 0.1);
		if (mousePressed && mousePos.dist(pos) < 10 && location_type == 1){
			for (Stop cs : child_stations){
				println(stop_name, cs.stop_id);
			}
		}
	}

	void render() {
		pushMatrix();
		translate(pos.x, pos.y, pos.z);
		noStroke();
		fill(255);
		rectMode(CENTER);
		rect(0, 0, 5, 5);
		popMatrix();
	}
}