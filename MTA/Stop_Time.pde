class Stop_Time implements Comparable {
	String trip_id;
	Date arrival_time = new Date();
	Date departure_time = new Date();
	String stop_id;
	int stop_sequence;

	Stop stop;

	int compareTo(Object o) {
		return stop_sequence - ((Stop_Time)o).stop_sequence;
	}
}