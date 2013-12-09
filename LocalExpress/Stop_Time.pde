class Stop_Time implements Comparable {
	//String trip_id;
	Date arrival_time = new Date();
	Date departure_time = new Date();
	//String stop_id;
	int stop_sequence;

	Stop stop;
	Trip trip;
	Stop_Time nextStopTime;

	int sortNumber;

	int compareTo(Object o) {
		return sortNumber - ((Stop_Time)o).sortNumber;
	}
}