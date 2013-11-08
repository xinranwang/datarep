ArrayList<Hotel> hotelList = new ArrayList();
IntDict starsDict = new IntDict();

void setup() {
	size(1280, 720, P3D);
	background(0);

	BufferedReader reader = createReader("hotelsbase.csv");
	
	//IntDict colsDict = new IntDict();
	try {
		String line;
		while((line = reader.readLine()) != null) {
			//doSomething(line);

			String[] cols = line.split("~");
			//colsDict.increment(Integer.toString(cols.length));
			if(cols.length == 22) {
				//starsDict.increment(cols[2]);
				try {
					float stars = Float.parseFloat(cols[2]);
				} catch (NumberFormatException e) {
					println("cols[2]: "+cols[2]);
				}
				
			}
		}
	} catch (Exception e) {
		println(e);
	}

	println(starsDict);
}

// void draw() {

// }

