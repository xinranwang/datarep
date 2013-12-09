class HalfTrail {
	HashMap<String, Vertex> vertexMap = new HashMap();

	long startTime;
	int day;

	Vertex startVertex;

	HalfTrail(int _day, long _startTime, String startStopId, StringList stopPool) {
		day = _day;
		startTime = _startTime;

		for (String stop_id : stopPool){
			Vertex v = new Vertex(stopMap.get(stop_id));
			vertexMap.put(stop_id, v);
		}
		startVertex = vertexMap.get(startStopId);
		startVertex.minDistance = 0; // very start
	}

	void computePaths() {
		d.computePaths(startVertex, day, startTime, vertexMap);
		for (Map.Entry me : vertexMap.entrySet()){
			Vertex v = (Vertex)me.getValue();
			for (Edge e : d.getShortestPathEdgesTo(v)){
				if (e.trip.route_id.equals("2") || e.trip.route_id.equals("3")){
					v.isExpressFaster = true;
				}
			}
		}
	}

	void printPaths() {
		for (Map.Entry me : vertexMap.entrySet()){
			Vertex v = (Vertex)me.getValue();
			if (d.getShortestPathEdgesTo(v).size()>0){
				println(d.getShortestPathEdgesTo(v), v, v.minDistance);
			}
			
		}
	}

	void setVertexPos(PVector center) {
		for (Map.Entry me : vertexMap.entrySet()){
			Vertex v = (Vertex)me.getValue();
			float z = map((float)v.minDistance, 0, 1500000, 0, -200);
			v.tpos = PVector.add(v.stop.tpos, PVector.sub(center, new PVector(width/2, height/2)));
			v.tpos.z = z;
		}
	}
}