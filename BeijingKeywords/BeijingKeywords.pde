/*
Article Search API Key: FBE2D451C771722E7C18A8A566DB0A92:5:68364049
*/

import java.util.Map;
import java.util.Comparator;
import java.util.Collections;

String base = "http://api.nytimes.com/svc/search/v2/articlesearch.json?";
String apiKey = "FBE2D451C771722E7C18A8A566DB0A92:5:68364049";

String globalQuery = "Beijing";
String filterType = "glocations";
String filterQuery = "BEIJING (CHINA)";

int beginYear = 1986;
int endYear = 2013;

int threshold = 0;
int index = 1986;

PFont yearFont;
PFont labelFont;

boolean useLocalData = true;

HashMap<Integer, ArrayList> map = new HashMap();

ArrayList<Keyword> wordList = new ArrayList();


void setup() {
	size(1280, 720, P3D);
	noStroke();
	colorMode(HSB, 360, 100, 100);
	yearFont = createFont("Futura Condensed.ttf", 200);
	labelFont = createFont("Futura Condensed.ttf", 14);

	for (int i = beginYear; i<=endYear; i++){
		Query q = new Query(globalQuery);
		q.filterType = filterType;
		q.filterQuery = filterQuery;
		q.sortType = "oldest";
		q.beginDate = Integer.toString(i) + "0101";
		q.endDate = Integer.toString(i) + "1231";

		ArrayList<Keyword> l = getKeywords(q, i);
		map.put(i, l);
	}

	changeList(map.get(index));
	smooth(4);
}

void draw() {
	background(0);

	for (Keyword k : wordList){
		k.update();
		k.render();
	}

	fill(255);
	textFont(yearFont, 200);
	textAlign(RIGHT);
	text(index, width - 10, height - 10);
}

void changeList(ArrayList<Keyword> toList) {
	ArrayList<Keyword> temp = new ArrayList();

	for (Keyword k1 : toList){

		boolean contain = false;
		for (Keyword k2 : wordList){
			if(k1.keyword.equals(k2.keyword)) {
				k2.count = k1.count;
				temp.add(k2);
				contain = true;
				break;
			}
		}
		if (!contain){
			temp.add(k1);
		}

	}
	wordList.clear();
	wordList = temp;
	sortWordList();
}

void sortWordList() {
	Collections.sort(wordList, new KeywordComparator());
	for (int i = 0; i<wordList.size(); i++){
		wordList.get(i).tsize = map(wordList.get(i).count, 0, wordList.get(0).count, 0, height/2 - 20);
		if (wordList.get(i).count <= threshold){
			wordList.get(i).tpos.set(2 * width, height / 2);
		} else {
			wordList.get(i).tpos.set((i+1) * 30, height / 2);
		}
	}
}

// boolean listContains(Keyword k, ArrayList<Keyword> l) {
// 	for (Keyword tempK : l){
// 		if(tempK.keyword.equals(k.keyword)) return true;
// 	}
// }

ArrayList<Keyword> getKeywords(Query q, int indexYear) {
	//String url = (page == 0) ? q.getEndPoint() : q.getEndPoint() + "&page=" + page;
	int page = 0;
	HashMap<String, Keyword> wordMap = new HashMap();
	//long callTime = 0;

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
			JSONArray keywords = doc.getJSONArray("keywords");

			IntDict tempDict = new IntDict();

			for (int j = 0; j<keywords.size(); j++){
				JSONObject keywordObject = keywords.getJSONObject(j);
				String keywordType = keywordObject.getString("name");
				String keyword = keywordObject.getString("value").toUpperCase();
				
				if(keywordType.equals("subject")) {
					//println(keywordType, keyword);

					if (!tempDict.hasKey(keyword)){
						tempDict.increment(keyword);
						if (!wordMap.containsKey(keyword)){
							Keyword k = new Keyword();
							k.keyword = keyword;
							//k.tpos.set(random(width), random(height));
							wordMap.put(keyword, k);
						}
						wordMap.get(keyword).count++;
					}
				} 
			}
		}
		page++;
		if(!useLocalData) delay(120);
	}

	ArrayList<Keyword> wordList = new ArrayList();
	for (Map.Entry me : wordMap.entrySet()){
		Keyword k = (Keyword)me.getValue();
		wordList.add(k);
	}
	return wordList;
}

String replaceSpace(String str) {
	String[] list = split(str, ' ');
	return join(list, "+");
}

void keyPressed() {
	// if (key == ' '){
	// 	index++;
	// 	changeList(map.get(index));
	// }

	if (key == CODED){
		if (keyCode == UP && index < endYear){
			index++;
			changeList(map.get(index));
		}
		if (keyCode == DOWN && index > beginYear){
			index--;
			changeList(map.get(index));
		}
	}
}