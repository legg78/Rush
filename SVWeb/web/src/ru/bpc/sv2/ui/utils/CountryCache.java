package ru.bpc.sv2.ui.utils;

import org.apache.log4j.Logger;
import org.infinispan.Cache;
import ru.bpc.sv2.common.Country;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.ui.utils.cache.CacheManager;
import ru.bpc.sv2.utils.SystemException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CountryCache {
	private static final Logger logger = Logger.getLogger("COMMON");
	
	private static volatile CountryCache instance;
	private boolean loaded = false;
	
	private Cache<String, Object> countryCache;
	
	private Map<String, Map<String, String>> countryMapByLang;
	private Map<String, String> codeMap;
	private Map<String, Map<String, String>> countriesNamesMapByLang;
	private Map<String, Map<String, String>> countriesNamesFlagMapByLang;
	private Map<String, List<String>> countryFlagsMapByLang;
	private List<String> allFlags;
	@SuppressWarnings("serial")
	private static final Map<String,String> countryMap = new HashMap<String,String>() {{
		put("004", "flag af");
		put("008", "flag al");
		put("012", "flag dz");
		put("016", "flag as");
		put("020", "flag ad");
		put("024", "flag ao");
		put("660", "flag ai");
		put("010", "flag aq");
		put("028", "flag ag");
		put("032", "flag ar");
		put("051", "flag am");
		put("533", "flag aw");
		put("036", "flag au");
		put("040", "flag at");
		put("031", "flag az");
		put("044", "flag bs");
		put("048", "flag bh");
		put("050", "flag bd");
		put("052", "flag bb");
		put("112", "flag by");
		put("056", "flag be");
		put("084", "flag bz");
		put("204", "flag bj");
		put("060", "flag bm");
		put("064", "flag bt");
		put("068", "flag bo");
		put("070", "flag ba");
		put("072", "flag bw");
		put("074", "flag bv");
		put("076", "flag br");
		put("086", "flag io");
		put("096", "flag bn");
		put("100", "flag bg");
		put("854", "flag bf");
		put("108", "flag bi");
		put("116", "flag kh");
		put("120", "flag cm");
		put("124", "flag ca");
		put("128", "flag ??");
		put("132", "flag cv");
		put("136", "flag ky");
		put("140", "flag cf");
		put("148", "flag td");
		put("152", "flag cl");
		put("156", "flag cn");
		put("162", "flag cx");
		put("166", "flag cc");
		put("170", "flag co");
		put("174", "flag km");
		put("178", "flag cg");
		put("180", "flag cg");
		put("184", "flag ck");
		put("188", "flag cr");
		put("384", "flag ci");
		put("191", "flag hr");
		put("192", "flag cu");
		put("196", "flag cy");
		put("203", "flag cz");
		put("200", "flag ??");
		put("208", "flag dk");
		put("262", "flag dj");
		put("212", "flag dm");
		put("214", "flag do");
		put("218", "flag ec");
		put("818", "flag eg");
		put("222", "flag sv");
		put("226", "flag gq");
		put("232", "flag er");
		put("233", "flag ee");
		put("230", "flag et");
		put("238", "flag fk");
		put("234", "flag fo");
		put("242", "flag fj");
		put("246", "flag fi");
		put("250", "flag fr");
		put("254", "flag gf");
		put("258", "flag pf");
		put("260", "flag tf");
		put("266", "flag ga");
		put("270", "flag gm");
		put("268", "flag ge");
		put("278", "flag ??");
		put("280", "flag de");
		put("288", "flag gh");
		put("292", "flag gi");
		put("300", "flag gr");
		put("304", "flag gl");
		put("308", "flag gd");
		put("312", "flag gp");
		put("316", "flag gu");
		put("320", "flag gt");
		put("324", "flag gn");
		put("624", "flag gw");
		put("328", "flag gy");
		put("332", "flag ht");
		put("334", "flag hm");
		put("336", "flag va");
		put("340", "flag hn");
		put("344", "flag hk");
		put("348", "flag hu");
		put("352", "flag is");
		put("356", "flag in");
		put("360", "flag id");
		put("364", "flag ir");
		put("368", "flag iq");
		put("372", "flag ie");
		put("376", "flag il");
		put("380", "flag it");
		put("388", "flag jm");
		put("392", "flag jp");
		put("396", "flag ??");
		put("400", "flag jo");
		put("398", "flag kz");
		put("404", "flag ke");
		put("296", "flag ki");
		put("408", "flag kp");
		put("410", "flag kr");
		put("900", "flag ??");
		put("414", "flag kw");
		put("417", "flag kg");
		put("418", "flag la");
		put("428", "flag lv");
		put("422", "flag lb");
		put("426", "flag ls");
		put("430", "flag lr");
		put("434", "flag ly");
		put("438", "flag li");
		put("440", "flag lt");
		put("442", "flag lu");
		put("446", "flag mo");
		put("807", "flag mk");
		put("450", "flag mg");
		put("454", "flag mw");
		put("458", "flag my");
		put("462", "flag mv");
		put("466", "flag ml");
		put("470", "flag mt");
		put("584", "flag mh");
		put("474", "flag mq");
		put("478", "flag mr");
		put("480", "flag mu");
		put("484", "flag mx");
		put("583", "flag ??");
		put("488", "flag ??");
		put("498", "flag md");
		put("492", "flag mc");
		put("496", "flag mn");
		put("499", "flag ??");
		put("500", "flag ms");
		put("504", "flag ma");
		put("508", "flag mz");
		put("104", "flag mm");
		put("516", "flag na");
		put("520", "flag nr");
		put("524", "flag np");
		put("528", "flag nl");
		put("530", "flag an");
		put("536", "flag ??");
		put("540", "flag nc");
		put("554", "flag nz");
		put("558", "flag ni");
		put("562", "flag ne");
		put("566", "flag ng");
		put("570", "flag nu");
		put("574", "flag nf");
		put("580", "flag mp");
		put("578", "flag no");
		put("512", "flag om");
		put("582", "flag ??");
		put("586", "flag pk");
		put("585", "flag pw");
		put("275", "flag ps");
		put("591", "flag pa");
		put("598", "flag pg");
		put("600", "flag py");
		put("604", "flag pe");
		put("608", "flag ph");
		put("612", "flag pn");
		put("616", "flag pl");
		put("620", "flag pt");
		put("630", "flag pr");
		put("634", "flag qa");
		put("688", "flag cs");
		put("638", "flag re");
		put("642", "flag ro");
		put("643", "flag ru");
		put("646", "flag rw");
		put("654", "flag sh");
		put("659", "flag kn");
		put("662", "flag lc");
		put("666", "flag pm");
		put("882", "flag ws");
		put("674", "flag sm");
		put("678", "flag st");
		put("682", "flag sa");
		put("686", "flag sn");
		put("690", "flag sc");
		put("694", "flag sl");
		put("702", "flag sg");
		put("703", "flag sk");
		put("705", "flag si");
		put("090", "flag sb");
		put("706", "flag so");
		put("710", "flag za");
		put("724", "flag es");
		put("144", "flag lk");
		put("670", "flag ??");
		put("736", "flag sd");
		put("740", "flag sr");
		put("744", "flag sj");
		put("748", "flag sz");
		put("752", "flag se");
		put("756", "flag ch");
		put("760", "flag sy");
		put("158", "flag tw");
		put("762", "flag tj");
		put("834", "flag tz");
		put("764", "flag th");
		put("626", "flag tl");
		put("768", "flag tg");
		put("772", "flag tk");
		put("776", "flag to");
		put("780", "flag tt");
		put("788", "flag tn");
		put("792", "flag tr");
		put("795", "flag tm");
		put("796", "flag tc");
		put("798", "flag tv");
		put("800", "flag ug");
		put("804", "flag ua");
		put("810", "flag ??");
		put("784", "flag ae");
		put("826", "flag uk");
		put("840", "flag us");
		put("849", "flag ??");
		put("858", "flag uy");
		put("581", "flag um");
		put("860", "flag uz");
		put("548", "flag vu");
		put("862", "flag ve");
		put("704", "flag vn");
		put("092", "flag vg");
		put("850", "flag vi");
		put("872", "flag ??");
		put("876", "flag wf");
		put("732", "flag eh");
		put("886", "flag ye");
		put("720", "flag ??");
		put("891", "flag yu");
		put("894", "flag zm");
		put("716", "flag zw");
	}};
	
	public static CountryCache getInstance(){
		if (instance == null || instance.loaded == false) {
			synchronized (CountryCache.class) {
				if (instance == null || instance.loaded == false) {
					instance = new CountryCache(); 
					instance.load();
				}
			}
		}
		return instance;
	}
	
	public void stopCache() {
		try {
			if (countryCache != null) countryCache.stop();
		} catch (Exception e) {
			logger.error("", e);
		}		
	}
	
	public static void destroyInstance(){
		instance = null;
	}
	
	private void load(){
		CommonDao comDao = new CommonDao();

		if (countryCache == null) {
			try {
				countryCache = CacheManager.getCacheManager().getCache("countryCache");
			} catch (SystemException e) {
				logger.error("", e);
				return;
			}
		} else {
			countryCache.clear();
		}
		
		String[] languages = comDao.getArticlesByDictNoContext("LANG");
		
		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(Integer.MAX_VALUE);
		Filter filter = new Filter("lang", null);
		params.setFilters(new Filter[] { filter });
		
		countryMapByLang = new HashMap<String, Map<String, String>>();
		codeMap = new HashMap<String, String>();
		countriesNamesMapByLang = new HashMap<String, Map<String, String>>();
		countryFlagsMapByLang = new HashMap<String, List<String>>();
		countriesNamesFlagMapByLang = new HashMap<String, Map<String,String>>();
		
		boolean firstLoaded = false;
		for (String language : languages){
			filter.setValue(language);
			Country[] countries = null;
			try{
				countries = comDao.getCountries( null, params);
			} catch (DataAccessException e){
				logger.error("CountryCache is not loaded", e);
				return;
			}
			
			Map<String, String> countryMap = new HashMap<String, String>();
			Map<String, String> countriesNamesMap = new HashMap<String, String>();
			
			for (Country country : countries){
				countryMap.put(country.getCode(), country.getName() + " - " + country.getCountryName());
				countriesNamesMap.put(country.getCode(), country.getCountryName());
				if (!firstLoaded){
					codeMap.put(country.getName(), country.getCode());
				}
			}	
			countryMapByLang.put(language, countryMap);
			countriesNamesMapByLang.put(language, countriesNamesMap);
			firstLoaded = true;
		}
		countryCache.put("codeMap", codeMap);
		countryCache.put("countryMapByLang", countryMapByLang);
		countryCache.put("countriesNamesMapByLang", countriesNamesMapByLang);
		countryCache.put("countryFlagsMapByLang", countryFlagsMapByLang);
		countryCache.put("countriesNamesFlagMapByLang", countriesNamesFlagMapByLang);
		
		loaded = true;
	}
	
	@SuppressWarnings("unchecked")
	public Map<String, String> getCountryMap(String lang){		
		checkLoaded();
		Map<String, String> result = ((Map<String, Map<String, String>>) countryCache
				.get("countryMapByLang")).get(lang);
		return result;
	}
	
	@SuppressWarnings("unchecked")
	public List<String> getAllFlags(String lang){		
		if (lang != null){
		allFlags = ((Map<String,List<String>>) countryCache
				.get("countryFlagsMapByLang")).get(lang);
		if (allFlags == null){
			CommonDao comDao = new CommonDao();
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(Integer.MAX_VALUE);
			Filter filter = new Filter("lang", null);
			params.setFilters(new Filter[] { filter });			
			filter.setValue(lang);
				Country[] countries = null;
				try{
					countries = comDao.getCountries( null, params);
				} catch (DataAccessException e){
					logger.error("CountryCache is not loaded", e);
					return null;
				}
				allFlags = new ArrayList<String>();
				allFlags.add("");
				for(Country country: countries){					
					allFlags.add(countryMap.get(country.getCode()));					
				}
				countryFlagsMapByLang.put(lang,allFlags);
		}
		}
		
		return allFlags;
		
	}
	
	@SuppressWarnings("unchecked")
	public Map<String,String> getFlagsMap(String lang){
		Map <String,String> result = null;
		if (lang != null){
			result = ((Map<String,Map<String,String>>) countryCache
					.get("countriesNamesFlagMapByLang")).get(lang);
			if (result == null){
				CommonDao comDao = new CommonDao();
				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(Integer.MAX_VALUE);
				Filter filter = new Filter("lang", null);
				params.setFilters(new Filter[] { filter });			
				filter.setValue(lang);
					Country[] countries = null;
					try{
						countries = comDao.getCountries( null, params);
					} catch (DataAccessException e){
						logger.error("CountryCache is not loaded", e);
						return null;
					}
				result = new HashMap<String, String>();	
				for (Country country: countries){
					result.put(country.getCountryName(), countryMap.get(country.getCode()));
				}
				countriesNamesFlagMapByLang.put(lang, result);
			}
				
		}
		return result;
	}
	
	@SuppressWarnings("unchecked")
	public Map<String, String> getCodeMap() {
		checkLoaded();
		return (Map<String, String>) countryCache.get("codeMap");
	}
	
	@SuppressWarnings("unchecked")
	public Map<String, String> getCountryNamesMap(String lang) {
		checkLoaded();
		Map<String, String> result = ((Map<String, Map<String, String>>) countryCache
				.get("countriesNamesMapByLang")).get(lang);
		return result;
	}
	
	public Map<String,String> getCountryMap(){
		return countryMap;
	}
	
	private void checkLoaded(){
		if (!loaded){
			throw new IllegalStateException("CountryCache must call load() before using its methods");
		}
	}
}
