class Vertex implements Comparable<Vertex> {
	Stop stop;
	ArrayList<Edge> adjacencies = new ArrayList();
	long minDistance = (long)Double.POSITIVE_INFINITY;
  	Vertex previous;
  	Edge previousEdge;

  	//boolean flag = false; // visited by local

  	Vertex(Stop s) {
  		stop = s;
  	}

  	int compareTo(Vertex other) {
  		return Long.compare(minDistance, other.minDistance);
  	}

  	String toString() { 
		return stop.stop_name;
	}

	void getEdges(int day, long startTime, HashMap<String, Vertex> vertexMap) {
		// local
		Stop_Time st1 = stop.getComingTrainStopTime(day, startTime, "1");
		if (st1 != null && vertexMap.containsKey(st1.nextStopTime.stop.stop_id)){
			Vertex v1 = vertexMap.get(st1.nextStopTime.stop.stop_id);
			Edge e1 = new Edge();
			e1.target = v1;
			e1.weight = st1.nextStopTime.arrival_time.getTime() - startTime;
			e1.trip = st1.trip;
			adjacencies.add(e1);
		}

		// express
		Stop_Time st2 = stop.getComingTrainStopTime(day, startTime, "2");
		Stop_Time st3 = stop.getComingTrainStopTime(day, startTime, "3");
		
		Vertex v2;
		Edge e2 = new Edge();
		if (st2 != null && st3 != null){
			if (st2.departure_time.getTime() < st3.departure_time.getTime()){
				if (vertexMap.containsKey(st2.nextStopTime.stop.stop_id)){
					v2 = vertexMap.get(st2.nextStopTime.stop.stop_id);
					e2.weight = st2.nextStopTime.arrival_time.getTime() - startTime;
					e2.trip = st2.trip;
					e2.target = v2;
					adjacencies.add(e2);
				}
				
			} else {
				if (vertexMap.containsKey(st3.nextStopTime.stop.stop_id)){
					v2 = vertexMap.get(st3.nextStopTime.stop.stop_id);
					e2.weight = st3.nextStopTime.arrival_time.getTime() - startTime;
					e2.trip = st3.trip;
					e2.target = v2;
					adjacencies.add(e2);
				}
			}
		}
		else if (st2 != null && vertexMap.containsKey(st2.nextStopTime.stop.stop_id)) {
			v2 = vertexMap.get(st2.nextStopTime.stop.stop_id);
			e2.weight = st2.nextStopTime.arrival_time.getTime() - startTime;
			e2.trip = st2.trip;
			e2.target = v2;
			adjacencies.add(e2);
		} else if (st3 != null && vertexMap.containsKey(st3.nextStopTime.stop.stop_id)) {
			v2 = vertexMap.get(st3.nextStopTime.stop.stop_id);
			e2.weight = st3.nextStopTime.arrival_time.getTime() - startTime;
			e2.trip = st3.trip;
			e2.target = v2;
			adjacencies.add(e2);
		}

		// for (Edge e : adjacencies){
		// 	int stopDiff = Integer.parseInt(e.target.stop.parent_station_string) - Integer.parseInt(stop.parent_station_string);
		// 	if (abs(stopDiff) == 1){
		// 		e.target.flag = true;
		// 	}
		// 	if (uptownStopPool.hasValue(e.target.stop.stop_id) && !q.contains(e.target)){
		// 		q.add(e.target);
		// 	}
		// }
	}

	void printPathsToAdjacencies() {
		for (Edge e : adjacencies){
			Vertex v = e.target;
			println(d.getShortestPathEdgesTo(v), v.minDistance, e.target.stop.stop_name);
		}
	}
}