/*
Article Search API Key: FBE2D451C771722E7C18A8A566DB0A92:5:68364049
*/

import java.util.Map;
import java.util.Comparator;
import java.util.Collections;
import java.util.Date;
import java.text.SimpleDateFormat;

String base = "http://api.nytimes.com/svc/search/v2/articlesearch.json?";
String apiKey = "FBE2D451C771722E7C18A8A566DB0A92:5:68364049";

String globalQuery = "Beijing";
String filterType = "glocations";
String filterQuery = "BEIJING (CHINA)";

int beginYear = 1986;
int endYear = 2013;

long beginTime;
long endTime;

int threshold = 1;
int index = 1986;

int mostCount = 0;

PFont yearFont;
PFont labelFont;

boolean useLocalData = true;

PVector mousePos = new PVector();

HashMap<String, ArrayList<Date>> keywordMap = new HashMap(); 
ArrayList<Keyword> keywordList = new ArrayList();
//ArrayList<Keyword> showList = new ArrayList();

//1986-11-26T00:00:00Z
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");

boolean overview = false;

void setup() {
	size(1280, 720, P3D);
	noStroke();
	colorMode(HSB, 360, 100, 100);
	yearFont = createFont("Futura Condensed.ttf", 200);
	labelFont = createFont("Futura Condensed.ttf", 14);

	try {
		beginTime = (sdf.parse(beginYear + "-01-01T00:00:00Z")).getTime();
		endTime = (sdf.parse(endYear + "-12-01T23:59:59Z")).getTime();
	} catch (Exception e) {
		println(e);
	}

	println("beginTime: "+beginTime);
	println("endTime: "+endTime);
	
	
	for (int i = beginYear; i<=endYear; i++){
		Query q = new Query(globalQuery);
		q.filterType = filterType;
		q.filterQuery = filterQuery;
		q.sortType = "oldest";
		q.beginDate = Integer.toString(i) + "0101";
		q.endDate = Integer.toString(i) + "1231";

		getKeywords(q, i);

	}

	// add all keywords to arraylist
	
	for(Map.Entry me : keywordMap.entrySet()) {
		Keyword k = new Keyword();
		k.keywordString = (String)me.getKey();
		k.dateList = (ArrayList<Date>)me.getValue();
		k.birthOrder = k.dateList.size();
		keywordList.add(k);
		println(k.keywordString, k.dateList.size());
	}
	updateKeywordList();

	// changeList(map.get(index));
	smooth(4);
}

void draw() {
	background(0);

	mousePos.set(mouseX, mouseY);

	//if(overview) positionOverview();
	// if (overview){
	// 	for (Keyword k : keywordList){
	// 		if (mousePos.y > height * 2 / 3){
	// 			k.tpos.y -= 5;
	// 		} else if (mousePos.y < height / 3){
	// 			k.tpos.y += 5;
	// 		}
	// 	}
	// }


	if (!overview){
		fill(255);
		textFont(yearFont, 200);
		textAlign(RIGHT);
		text(index, width - 10, height - 10);
	} else {
		fill(255, 128);

		textFont(labelFont, 14);
		for (int i = beginYear; i<=endYear; i++){
			try {
				long getTime = (sdf.parse(i + "-01-01T00:00:00Z")).getTime();
				float x = map((float)(getTime - beginTime), 0, endTime - beginTime, 100, width - 300);
				stroke(255, 128);
				strokeWeight(0.5);
				line(x, 50, x, height);
				noStroke();
				text(i, x, 40);
			} catch (Exception e) {
				println("e: "+e);
			}
		}
	}

	for (Keyword k : keywordList){
		k.update();
		if(k.tbarSize >= threshold || overview) k.render();
	}



}

void getKeywords(Query q, int indexYear) {
	//String url = (page == 0) ? q.getEndPoint() : q.getEndPoint() + "&page=" + page;
	int page = 0;
	//HashMap<String, Keyword> wordMap = new HashMap();

	while (page < 100){
		String url;
		if(!useLocalData) url = q.getEndPoint() + "&page=" + page;
		else url = "data/json/" + indexYear + nf(page, 3) + ".json";

		//println("url: "+url);
		JSONObject myJSON = loadJSONObject(url);

		// save json to local
		if(!useLocalData) saveJSONObject(myJSON, "data/json/" + indexYear + nf(page, 3) + ".json");

		JSONObject response = myJSON.getJSONObject("response");

		JSONObject meta = response.getJSONObject("meta");
		// hits = meta.getInt("hits");

		JSONArray docs = response.getJSONArray("docs");

		if (docs.size() < 1){
			println(q.endDate + " page: "+page);
			page = 200;
			break;
		}
		for (int i = 0; i<docs.size(); i++){
			JSONObject doc = docs.getJSONObject(i);
			
			String dateString = doc.getString("pub_date");
			try {
				Date keywordDate = sdf.parse(dateString);

				JSONArray keywords = doc.getJSONArray("keywords");

				IntDict tempDict = new IntDict();

				for (int j = 0; j<keywords.size(); j++){
					JSONObject keywordObject = keywords.getJSONObject(j);
					String keywordType = keywordObject.getString("name");
					String keyword = keywordObject.getString("value").toUpperCase();
					
					if(keywordType.equals("subject") && !keyword.equals("")) {
						//println(keywordType, keyword);

						if (!tempDict.hasKey(keyword)){
							tempDict.increment(keyword);
							if (!keywordMap.containsKey(keyword)){
								keywordMap.put(keyword, new ArrayList<Date>());
							}
							keywordMap.get(keyword).add(keywordDate);
						}
					} 
				}

			} catch (Exception e) {
				println("Error parsing date: " + e);
			}

		}
		page++;
		if(!useLocalData) delay(120);
	}
}

String replaceSpace(String str) {
	String[] list = split(str, ' ');
	return join(list, "+");
}

void updateKeywordList() {
	if (!overview){
		for (Keyword k : keywordList){
			int count = 0;
			for (Date date : k.dateList){
				if (date.getYear()+1900 == index){
					count++;
				}
			}
			k.tbarSize = count==0 ? 0 : count;
			k.tempCount = count;
			k.sortNumber = count;
		}
	} else {
		for (Keyword k : keywordList) {
			k.sortNumber = k.birthOrder;
			if (k.birthOrder == 0){
				println("k.keywordString: "+k.keywordString);
			}
		}
	}

	sortKeywords();
}

void sortKeywords() {
	Collections.sort(keywordList);
	if(!overview) positionLine();
	else positionOverview();
}

void positionLine() {
	for (int i = 0; i<keywordList.size(); i++){
		Keyword k = keywordList.get(i);
		float x = 50 + i * 20;
		float y = height / 2;
		k.tpos.set(x, y);
		k.trot.set(0, 0, PI/2);
	}
}

void positionOverview() {
	for (int i = 0; i<keywordList.size(); i++){
		Keyword k = keywordList.get(i);
		float x = width - 300;
		float y = 50 + i * 20;
		k.tpos.set(x, y);
		k.trot.set(0, 0, 0);
	}
}

void keyPressed() {
	if (key == CODED && !overview){
		if (keyCode == UP && index < endYear){
			index++;
			updateKeywordList();
		}
		else if (keyCode == DOWN && index > beginYear){
			index--;
			updateKeywordList();
		}
	} 
	else if (key == CODED && overview) {
		if (keyCode == UP){
			for (Keyword k : keywordList){
				k.tpos.y += 10;
			}
		}
		else if (keyCode == DOWN) {
			for (Keyword k : keywordList){
				k.tpos.y -= 10;
			}
		}
	}
	else if (key == ' ') {
		overview = !overview;
		updateKeywordList();
	}
}