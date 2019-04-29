package ru.bpc.sv2.system;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.scheduler.process.ContainerLauncher;
import ru.bpc.sv2.scheduler.process.InternalProcessExecutor;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.process.files.MbConfigurationFiles;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.model.LoadableDetachableModel;
import ru.bpc.sv2.utils.AppServerUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

import javax.annotation.PostConstruct;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import javax.servlet.ServletContext;
import java.io.Serializable;
import java.util.*;

@SessionScoped
@ManagedBean(name = "MbSystemInfo")
public class MbSystemInfo implements Serializable {
	private static final long serialVersionUID = 1L;

	private CommonDao _commonDao = new CommonDao();

	private SettingsDao _settingsDao = new SettingsDao();

	private ProcessDao _processDao = new ProcessDao();

	private String lastVersion;
	private String instance;
	private String release;
	private LoadableDetachableModel<Boolean> configStandModel;
	private List<SelectItem> languages = null;
	private transient DictUtils dictUtils;
	private static final Logger logger = Logger.getLogger("COMMON");
	private static final Integer UPLOAD_CONFIG_CONTAINER_ID = 10000058;
	private static final String I_USER_SESSION_ID = "I_USER_SESSION_ID";
	public static String SERVER_NAME;

	private final static String BUILD_VERSION = "ru.bpc.sv.web.BUILD_VERSION";

	public MbSystemInfo() {

	}

	@PostConstruct
	public void init() {
		configStandModel = new LoadableDetachableModel<Boolean>() {
			@Override
			protected Boolean load() {
				boolean configStand = false;
				String userSessionId = getUserSessionIdStr();
				try {
					if (userSessionId != null) {
						//User is logined
						double d = _settingsDao.getParameterValueN(null, SettingsConstants.CONFIGURATION_INSTANCE, LevelNames.SYSTEM, null);
						configStand = d == 1;
					}
				} catch (Exception e) {
					logger.error(e.getMessage(), e);
				}
				return configStand;
			}
		};
	}

	public String getLastVersion() {
		String userSessionId = getUserSessionIdStr();
		try {
			if (userSessionId == null) {
				//User is not logined
				lastVersion = _commonDao.getLastVersion(null);
			} else {
				//User is logined
				if (lastVersion == null) {
					//Get lastVersion from DB only if it's null
					lastVersion = _commonDao.getLastVersion(null);
				}
			}
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
		return lastVersion;
	}

	public String getWebVersion() {
		ServletContext servletContext = (ServletContext) FacesContext
				.getCurrentInstance().getExternalContext().getContext();
		return (String) servletContext.getAttribute(BUILD_VERSION);
	}

	public void setLastVersion(String lastVersion) {
		this.lastVersion = lastVersion;
	}

	public String getInstance() {
		String userSessionId = getUserSessionIdStr();
		try {
			if (userSessionId == null) {
				//User is not logined
				instance = _settingsDao.getParameterValueV(null,
						SettingsConstants.INSTANCE_NAME, LevelNames.SYSTEM, null);
				if (FacesContext.getCurrentInstance().getViewRoot().getLocale() == null) {
					String lang = _settingsDao.getParameterValueV(null,
							SettingsConstants.LANGUAGE, LevelNames.SYSTEM, null);
					setLocale(lang);
				}
			} else {
				//User is logined
				if (instance == null) {
					//Get instance from DB only if it's null
					instance = _settingsDao.getParameterValueV(null,
							SettingsConstants.INSTANCE_NAME, LevelNames.SYSTEM, null);
				}
			}
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
		return instance;
	}

	public void setInstance(String instance) {
		this.instance = instance;
	}

	public boolean isConfigStand() {
		return configStandModel != null && configStandModel.getObject();
	}

	private Long getUserSessionId() {
		String userSessionId = getUserSessionIdStr();
		return userSessionId != null ? new Long(userSessionId) : null;
	}

	private static String getUserSessionIdStr() {
		return SessionWrapper.getUserSessionIdStr();
	}

	public void setLocale(String lang) {
		SelectionParams params = new SelectionParams(new Filter("convId", SystemConstants.ARRAY_LOCALE_CONVERSION), new Filter("inValue", lang));
		String isoLang = null;
		try {
			isoLang = _commonDao.getArrayOutElement(params);
		} catch (Exception e) {
			logger.error("Cannot get ISO locale value by LANG article!", e);
		}
		if (isoLang == null) {
			// if there's no conversion from current language to ISO language we'll try 
			// to use first two letters of current language 
			isoLang = lang.substring(4, 6).toLowerCase();
		}
		Locale newLocale = new Locale(isoLang, isoLang.toUpperCase());
		FacesContext context = FacesContext.getCurrentInstance();
		context.getViewRoot().setLocale(newLocale);
	}

	public void saveConfig() {
		try {
			Long containerSessionId = launchContainer();

			MbConfigurationFiles configFilesBean = ManagedBeanWrapper.getManagedBean("MbConfigurationFiles");

			configFilesBean.setSessionId(containerSessionId);
			configFilesBean.setComment("");
			//get from system param PATH_TO_LOCAL_COPY
			String path = _settingsDao.getParameterValueV(null,
					SettingsConstants.PATH_TO_LOCAL_COPY, LevelNames.SYSTEM, null);
			//not necessary
			String username = _settingsDao.getParameterValueV(null, SettingsConstants.SVN_LOGIN, LevelNames.SYSTEM, null);
			String password = _settingsDao.getParameterValueV(null, SettingsConstants.SVN_PASSWORD, LevelNames.SYSTEM, null);
			/* Disabled functionality related to SVN as project is switched to Git
			SvnCommit commitEditor = new SvnCommit(path, username, password);
			configFilesBean.setCommitEditor(commitEditor);
			*/
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
	}

	private Long launchContainer() {
		ProcessBO container = getContainerById(UPLOAD_CONFIG_CONTAINER_ID);
		Map<String, Object> paramsMap = new HashMap<String, Object>();
		paramsMap.put(I_USER_SESSION_ID, getUserSessionId());

		ContainerLauncher containerLauncher = new ContainerLauncher();
		containerLauncher.setContainer(container);
		containerLauncher.setProcessDao(_processDao);
		containerLauncher.setParameters(paramsMap);
		containerLauncher.setUserSessionId(getUserSessionId());

		try {
			containerLauncher.launch();
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
		Long result = null;
		if (!containerLauncher.getExecutors().isEmpty()) {
			InternalProcessExecutor executor = (InternalProcessExecutor) containerLauncher.getExecutors().get(0);
			if (executor.getProcessSession() != null)
				result = executor.getProcessSession().getSessionId();
		}
		return result;
	}

	private ProcessBO getContainerById(Integer id) {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(id.toString());
		filtersList.add(paramFilter);

		String lang = SessionWrapper.getField("language");
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(lang);
		filtersList.add(paramFilter);

		SelectionParams params = new SelectionParams();
		params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
		try {
			ProcessBO[] processes = _processDao.getContainersAll(getUserSessionId(), params);
			if (processes != null && processes.length > 0) {
				return processes[0];
			}
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
		return null;
	}

	public List<SelectItem> getLanguages() {
		if (languages == null) {
			Map<String, Object> params = new HashMap<String, Object>();
			params.put("LANGUAGE", SystemConstants.ENGLISH_LANGUAGE);
			languages = getDictUtils().getLovNoContext(LovConstants.LANGUAGES_BY_LANG, params);
		}
		return languages;
	}

	public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}

	public boolean isWeblogic() {
		return weblogic();
	}

	public boolean isWebsphere() {
		return websphere();
	}

	public static boolean weblogic() {
		return AppServerUtils.isWebogic();
	}

	public static boolean websphere() {
		return AppServerUtils.isWebsphere();
	}


    public String getRelease() {
        try {
            if (StringUtils.isEmpty(release)) {
                release = _settingsDao.getRelease(getUserSessionId());
            }
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
        }
        return (StringUtils.isNotEmpty(release) ? release : "N/A");
    }
}
