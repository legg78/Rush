package ru.bpc.sv2.ui.cmn;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import ru.bpc.sv2.cmn.Device;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import java.util.Map;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbDeviceDetails")
public class MbDeviceDetails extends AbstractBean {
	private static final Logger logger = Logger.getLogger("PRODUCTS");
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";	
	
	private CommunicationDao communicationDao = new CommunicationDao();
	
	private Long id;
	private String language;
	private Long userSessionId;
	private DictUtils dictUtils;
	
	private Device device;
	
	public MbDeviceDetails(){
		setLanguage(SessionWrapper.getField("language"));
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
	}

    @Override
    public void clearFilter() {
        // do nothing
    }

    public void initializeModalPanel(){
		logger.debug("MbDeviceDetails initializing...");
		reset();
		if (FacesUtils.getSessionMapValue(CTX_MENU_PARAMS) != null) {
			Map<String, Object> ctxMenuParams = (Map<String, Object>) FacesUtils
					.getSessionMapValue(CTX_MENU_PARAMS);
			FacesUtils.setSessionMapValue(CTX_MENU_PARAMS, null);
			if (ctxMenuParams.containsKey(OBJECT_ID)){
				id = (Long) ctxMenuParams.get(OBJECT_ID);
			} 
		} else {
			if (FacesUtils.getSessionMapValue(OBJECT_ID) != null) {
				id = (Long) FacesUtils.getSessionMapValue(OBJECT_ID);
			}	
		}
		if (id == null){
			objectIdIsNotSet();
		}
	}	
	
	private boolean objectIdIsNotSet(){
		String message = "Object ID is not set";
		logger.error(message);
		FacesUtils.addErrorExceptionMessage(message);
		return false;
	}	
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Device getDevice(){
		if ((device == null) && (id != null)){
			Filter[] filters = new Filter[] { new Filter("id", id),
					new Filter("lang", language) };
			Device[] devices = communicationDao.getDevices(userSessionId,
					new SelectionParams(filters));
			if (devices.length > 0){
				device = devices[0];
			}
		}
		return device;
	}
	
	public void reset(){
		device = null;
	}

	public String getLanguage() {
		return language;
	}

	public void setLanguage(String language) {
		this.language = language;
	}
}
