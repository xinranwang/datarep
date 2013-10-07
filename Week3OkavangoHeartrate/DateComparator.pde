class DateComparator implements Comparator<HRObject> {
	@Override
	int compare(HRObject a, HRObject b) {
		return a.dateTime.compareTo(b.dateTime);
	}
}