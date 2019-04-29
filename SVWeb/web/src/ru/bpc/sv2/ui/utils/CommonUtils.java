package ru.bpc.sv2.ui.utils;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import java.io.File;
import java.io.IOException;
import java.io.Serializable;
import java.text.DateFormat;
import java.util.*;

/**
 * Class for different utility functions preferably without DB interactions.  
 *
 * @author Alexeev
 */
@SessionScoped
@ManagedBean(name = "CommonUtils")
public class CommonUtils implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private TimeZone timeZone;
	private List<SelectItem> gmtOffsets;
	private List<SelectItem> rowsNumsList; 
	
	public List<SelectItem> getGmtOffsets() {
		if (gmtOffsets == null) {
			gmtOffsets = ((DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils")).getLov(LovConstants.HOUR_GMT_OFFSETS);
		}
		return gmtOffsets;
	}

    public TimeZone getTimeZone() {
    	if (timeZone == null) {
			// set time zone for proper date output
			DateFormat df = DateFormat.getInstance();
			df.setCalendar(Calendar.getInstance());
			timeZone = df.getTimeZone();
    	}
    	return timeZone;
    }

	public String getDefaultTime() {
		Calendar calendar = new GregorianCalendar();
		int hour = calendar.get(Calendar.HOUR_OF_DAY);
		int minute = calendar.get(Calendar.MINUTE);
		return String.format("%2s", hour).replace(" ", "0")+":"+String.format("%2s", minute).replace(" ", "0");
	}

    public String getTimeZoneId() {
    	return getTimeZone().getID();
    }
    
    public int getCurrentGmtOffset() {
    	Date today = new Date();
    	int offset = getTimeZone().getOffset(today.getTime());
    	return offset / (60 * 60 * 1000);
    }
    
    public List<SelectItem> getRowNumsList(){
    	if (rowsNumsList == null){
    		rowsNumsList = new ArrayList<SelectItem>();
    		rowsNumsList.add(new SelectItem(10,"10"));
    		rowsNumsList.add(new SelectItem(20,"20"));
    		rowsNumsList.add(new SelectItem(30,"30"));
    		rowsNumsList.add(new SelectItem(300,"300"));
    	}
    	return rowsNumsList;
    }

	public static boolean hasLength(CharSequence str) {
		return (str != null && str.length() > 0);
	}

	public static boolean hasText(CharSequence str) {
		if (!hasLength(str)) {
			return false;
		}
		int strLen = str.length();
		for (int i = 0; i < strLen; i++) {
			if (!Character.isWhitespace(str.charAt(i))) {
				return true;
			}
		}
		return false;
	}
	
	public static void checkFilepath(String path, boolean checkIsDirectory, boolean checkCanRead, boolean checkCanWrite)
			throws IOException {
		
		File f = new File(path);
		
		if (!f.exists()) {
			throw new IOException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "location_not_exist", path));
		}
		if (checkIsDirectory && !f.isDirectory()) {
			throw new IOException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "location_isnt_folder", path));
		}
		if (checkCanRead && !f.canRead()) {
			throw new IOException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "location_isnt_readable", path));
		}
		if (checkCanWrite && !f.canWrite()) {
			throw new IOException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "location_isnt_writable", path));
		}
	}

	public static boolean equals(Object o1, Object o2) {
		if (o1 == o2) {
			return true;
		} else {
			return o1 != null && o2 != null && o1.equals(o2);
		}
	}

	public static String getWsCallbackUrl(Map<String, Object> externalParams) {
		String callbackAddress = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.CALLBACK_URL);
		if (callbackAddress == null || callbackAddress.isEmpty()) {
			String protocol = "http";
			String serverName = null;
			Integer port = null;
			if (externalParams != null && externalParams.containsKey("wsServerName") && externalParams.containsKey("wsPort")) {
				serverName = (String) externalParams.get("wsServerName");
				port = (Integer) externalParams.get("wsPort");
			} else {
				HttpServletRequest request = RequestContextHolder.getRequest();
				if (request != null) {
					serverName = request.getServerName();
					port = request.getServerPort();
					protocol = request.getScheme();
				}
			}
			callbackAddress = String.format(protocol + "://%s:%d", serverName, port);
		}
		return callbackAddress + "/sv/CallbackService";
	}
}
