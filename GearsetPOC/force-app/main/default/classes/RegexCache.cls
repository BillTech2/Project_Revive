public class RegexCache {
    private Map<String, Pattern> cacheMap;
    static private RegexCache cacheInstance;

    static public RegexCache getInstance() {
        if (cacheInstance == null) {
            cacheInstance = new RegexCache();
        }

        return cacheInstance;
    }

    private RegexCache() {
        cacheMap = new Map<String, Pattern>();
    }

    public Pattern getPatternForRegex(String regex) {
        Pattern patt = cacheMap.get(regex);
        if (patt == null) {
            patt = Pattern.compile(regex);
            cacheMap.put(regex, patt);
        }
        return patt;
    }

    boolean containsRegex(String regex) {
        return cacheMap.containsKey(regex);
    }

}