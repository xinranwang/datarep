/*

Data Representation Assignment: 
Pick a data set from the Guardian Data Store, export it as a .CSV via Google Spreadsheets, and bring the data into Processing.

Data from: Death penalty statistics, country by country
http://www.theguardian.com/news/datablog/2011/mar/29/death-penalty-countries-world

09/30/2013

*/


Table table;

void setup() {
	size(1280, 720);
	background(0);

	PFont font = loadFont("HelveticaNeue-Bold-8.vlw");
	textFont(font);

	table = loadTable("Death penalty - EXECUTIONS BY COUNTRY.csv", "header");
	//println(table.getRowCount());
	int n = table.getRowCount();

	//for (TableRow row : table.rows()){
	for (int i = 1; i < n - 1; i++) {
		String country = table.getRow(i).getString("Country");
		String countryCode = table.getRow(i).getString("Code");
		int totalSentenced;
		String totalSentencedString = table.getRow(i).getString("TOTAL SENTENCED TO DEATH, 2007-2012");

		fill(255);
		textSize(8);
		text(countryCode, 10, (i+1) * height / n - 2);

		// remove comma
		String[] pieces = split(totalSentencedString, ',');
		totalSentencedString = join(pieces, "");
		
		// cast to int
		if (totalSentencedString.equals("THOUSANDS")){
			totalSentenced = int(1000 * random(1, 9));
			fill(255, 100);
			rect(30, i * height / n, width, height / n);
			fill(255);
			text("THOUSANDS", width / 2 + 30, (i + 1) * height / n - 2);
		}
		else {
			totalSentenced = int(totalSentencedString);
			fill(255);
			rect(30, i * height / n, map(totalSentenced, 0, 3000, 0, width), height / n);
		}

		println(country + ":" + totalSentenced);
	}
}