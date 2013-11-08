public class KeywordComparator implements Comparator<Keyword> {
    @Override
    public int compare(Keyword k1, Keyword k2) {
        return k2.count - k1.count;
    }
}