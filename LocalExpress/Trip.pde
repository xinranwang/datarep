class Trip {
	String route_id;
	Route route;
	String service_id;
	String trip_id;
	String trip_headsign;
	int direction_id;
	ArrayList<Stop_Time> stop_times = new ArrayList();

	int[] calendar = new int[7];

	int index;
	long start;
	PVector vel = new PVector();
	ArrayList<PVector> plots = new ArrayList();

	void sortStopTimes() {
		for (Stop_Time st : stop_times){
			st.sortNumber = st.stop_sequence;
		}
		Collections.sort(stop_times);
	}

	void setupTrip() {
		plots.clear();
		//plots.add(stop_times.get(0).stop.tpos);	/////tpos!!!
		for (int i = 0; i<stop_times.size(); i++){
			index = i;
			if (stop_times.get(i).departure_time.getTime() > now){
				break;
			}
		}
		//plots.add()
		start = stop_times.get(0).departure_time.getTime();
	}

	void renderTrip() {

		if (now >= start){
			getPlots();

			stroke(route.route_color);
			strokeWeight(3);
			noFill();
			beginShape();

			for (PVector pos : plots){
				vertex(pos.x, pos.y, pos.z);
			}
			endShape();
			if (plots.size() > 0){
				fill(route.route_color);
				rect(plots.get(plots.size()-1).x, plots.get(plots.size()-1).y, 10, 10);
			}
		}


	}

	void getPlots() {
		if (index < stop_times.size() - 1){
			Stop_Time st1 = stop_times.get(index);
			Stop_Time st2 = stop_times.get(index+1);

			if (now > st1.departure_time.getTime()){
				long t = st2.arrival_time.getTime() - st1.departure_time.getTime();
      			float dist = st1.stop.tpos.dist(st2.stop.tpos);
      			float maxV = dist * 2 / t;

      			float v, d;
				if (now <= st1.departure_time.getTime() + t/2) {
					v = lerp(0, maxV, (float)(now - st1.departure_time.getTime()) * 2 / (float)t);
					d = (now - st1.departure_time.getTime()) * v / 2;
				} 
				else {
					v = lerp(0, maxV, (float)(st2.arrival_time.getTime() - now) * 2 / (float)t);
					d = dist - (st2.arrival_time.getTime() - now) * v / 2;
				}

				vel = PVector.sub(st2.stop.tpos, st1.stop.tpos);
				vel.setMag(d);

				PVector newPos = PVector.add(st1.stop.tpos, vel);
				plots.add(newPos);
			}

			if (now > st2.arrival_time.getTime()) {
				index++;
			}
		}
	}
}