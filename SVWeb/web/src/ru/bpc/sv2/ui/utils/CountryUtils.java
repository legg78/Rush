package ru.bpc.sv2.ui.utils;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.ui.utils.model.IDetachable;
import ru.bpc.sv2.ui.utils.model.PhaseListenerSupport;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.model.SelectItem;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@SessionScoped
@ManagedBean(name = "CountryUtils")
public class CountryUtils implements Serializable {
	private static final long serialVersionUID = 1L;

	private transient DictUtils dictUtils;

	private ThreadLocal<List<SelectItem>> allCountriesModelCache = new ThreadLocal<List<SelectItem>>();
	private ThreadLocal<Map<String, String>> revCodeMap = new ThreadLocal<Map<String, String>>();

	public CountryUtils() {
		PhaseListenerSupport.registerDetachable(new IDetachable() {
			@Override
			public void detach() {
				allCountriesModelCache.set(null);
			}
		});
	}

	public Map<String, String> getCountryMap() {
		String userLang = SessionWrapper.getField("language");
		return CountryCache.getInstance().getCountryMap(userLang);
	}

	public Map<String, String> getCodeMap() {
		return CountryCache.getInstance().getCodeMap();
	}

	public Map<String, String> getRevCodeMap() {
		if (revCodeMap.get() == null) {
			Map<String, String> map = new HashMap<String, String>();
			Map<String, String> srcMap = CountryCache.getInstance().getCodeMap();
			for (Map.Entry<String, String> en : srcMap.entrySet()) {
				map.put(en.getValue(), en.getKey());
			}
			revCodeMap.set(map);
		}
		return revCodeMap.get();
	}

	public Map<String, String> getCountryNamesMap() {
		String userLang = SessionWrapper.getField("language");
		return CountryCache.getInstance().getCountryNamesMap(userLang);
	}

	public Collection<String> getLetterCodes() {
		List<String> list = new ArrayList<String>(CountryCache.getInstance().getCodeMap().keySet());
		Collections.sort(list);
		return list;
	}

	public Collection<String> getNumCodes() {
		List<String> list = new ArrayList<String>(CountryCache.getInstance().getCodeMap().values());
		Collections.sort(list);
		return list;
	}

	public List<SelectItem> getAllCountries() {
		List<SelectItem> result = allCountriesModelCache.get();
		if (result == null) {
			result = getDictUtils().getLov(LovConstants.COUNTRIES);
			Collections.sort(result, new Comparator<SelectItem>() {
				@Override
				public int compare(SelectItem o1, SelectItem o2) {
					if (o1.getLabel() == null || o1.getLabel().equals("")) {
						return -1;
					}
					if (o2.getLabel() == null || o2.getLabel().equals("")) {
						return 1;
					}
					return (o1.getLabel().toLowerCase().
							compareTo(o2.getLabel().toLowerCase()));
				}
			});
			result.add(0, new SelectItem(""));
			allCountriesModelCache.set(result);
		}
		return result;
	}

	public List<SelectItem> getAllCountriesWithCode() {
		String userLang = SessionWrapper.getField("language");
		Map<String, String> countryMap = CountryCache.getInstance().getCountryMap(userLang);
		List<SelectItem> result = new ArrayList<SelectItem>();

		for (String code : countryMap.keySet()) {
			result.add(new SelectItem(code, countryMap.get(code)));
		}
		Collections.sort(result, new Comparator<SelectItem>() {
			@Override
			public int compare(SelectItem o1, SelectItem o2) {
				if (o1.getLabel() == null || o1.getLabel().equals("")) {
					return -1;
				}
				if (o2.getLabel() == null || o2.getLabel().equals("")) {
					return 1;
				}
				return o1.getLabel().toLowerCase().compareTo(o2.getLabel().toLowerCase());
			}
		});
		result.add(0, new SelectItem(""));
		return result;
	}

	public String[] getAllFlags() {
		String userLang = SessionWrapper.getField("language");
		List<String> flags = CountryCache.getInstance().getAllFlags(userLang);
		String array[] = new String[flags.size()];
		flags.toArray(array);
		return array;
	}

	public Map<String, String> getFlagsMap() {
		String userLang = SessionWrapper.getField("language");
		return CountryCache.getInstance().getFlagsMap(userLang);
	}

	public Map<String, String> getFlag() {
		return CountryCache.getInstance().getCountryMap();
	}

	public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}

}
