package ru.bpc.sv2.ui.rules;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.RuleAlgorithm;
import ru.bpc.sv2.ui.utils.AbstractSearchTabbedBean;
import ru.bpc.sv2.ui.utils.FacesUtils;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbAlgorithmsSearch")
public class MbAlgorithmsSearch extends AbstractSearchTabbedBean<RuleAlgorithm, RuleAlgorithm> {
    private static final Logger logger = Logger.getLogger("RULES");

    private RulesDao ruleDao = new RulesDao();
    private RuleAlgorithm algorithm;

    private List<SelectItem> algorithms;
    private List<SelectItem> entryPoints;
	private List<SelectItem> procedures;
    private List<String> rerenderList;

    @Override
    protected void onLoadTab(String tabName) {
        if (DETAILS_TAB.equals(tabName)) {
            /** Nothing to do */
        }
    }
    @Override
    protected RuleAlgorithm createFilter() {
        return new RuleAlgorithm();
    }
    @Override
    protected Logger getLogger() {
        return logger;
    }

    @Override
    protected RuleAlgorithm addItem(RuleAlgorithm item) {
        return null;
    }

    @Override
    protected RuleAlgorithm editItem(RuleAlgorithm item) {
        return null;
    }

    @Override
    protected void deleteItem(RuleAlgorithm item) {

    }

    @Override
    protected void initFilters(RuleAlgorithm filter, List<Filter> filters) {
        filters.addAll(FilterBuilder.createFiltersDatesAsString(filter));
        filters.add(Filter.create(LANGUAGE, userLang));
    }
    @Override
    protected List<RuleAlgorithm> getObjectList(Long userSessionId, SelectionParams params) {
        return ruleDao.getAlgorithms(userSessionId, params);
    }
    @Override
    protected int getObjectCount(Long userSessionId, SelectionParams params) {
        return ruleDao.getAlgorithmsCount(userSessionId, params);
    }

    public List<SelectItem> getAlgorithms() {
        if (algorithms == null) {
            algorithms = getDictUtils().getLov(LovConstants.RULES_ALGORITHMS);
            if (algorithms == null) {
                algorithms = new ArrayList<SelectItem>();
            }
        }
        return algorithms;
    }

    public List<SelectItem> getEntryPoints() {
        if (entryPoints == null) {
            entryPoints = getDictUtils().getArticles(DictNames.ALGORITHM_ENTRY_POINT, false, true);
            if (entryPoints == null) {
                entryPoints = new ArrayList<SelectItem>();
            }
        }
        return entryPoints;
    }

	public List<SelectItem> getProcedures() {
		if (procedures == null) {
			procedures = getDictUtils().getLov(LovConstants.ALGORITHM_RULE_PROCEDURES);
			if (procedures == null) {
				procedures = new ArrayList<SelectItem>();
			}
		}
		return procedures;
	}

    public List<String> getRerenderList(){
        rerenderList = new ArrayList<String>();
        rerenderList.add("err_ajax");
        rerenderList.add(tabName);
        return rerenderList;
    }

    public RuleAlgorithm getAlgorithm() {
        return algorithm;
    }
    public void setAlgorithm(RuleAlgorithm algorithm) {
        this.algorithm = algorithm;
    }

    public void initAction(int mode) throws CloneNotSupportedException {
        curMode = mode;
        switch (curMode) {
            case NEW_MODE:
                algorithm = new RuleAlgorithm();
                algorithm.setLang(userLang);
                break;
            case EDIT_MODE:
                algorithm = activeItem.clone();
                break;
            case REMOVE_MODE:
                algorithm = activeItem;
                break;
        }
    }

    public void save() {
        try {
            if (isNewMode()) {
                setActiveItem(ruleDao.addAlgorithm(userSessionId, getAlgorithm()));
                tableRowSelection.addNewObjectToList(getActiveItem());
            } else {
                setAlgorithm(ruleDao.modifyAlgorithm(userSessionId, getAlgorithm()));
                getDataModel().replaceObject(getActiveItem(), getAlgorithm());
            }
            curMode = VIEW_MODE;
            setActiveItem(getAlgorithm());
            clearState();
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void delete() {
        try {
            curMode = VIEW_MODE;
            ruleDao.deleteAlgorithm(userSessionId, getAlgorithm());
            setActiveItem(tableRowSelection.removeObjectFromList(getActiveItem()));
            if (getActiveItem() == null) {
                clearState();
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void close() {
        setAlgorithm(null);
        curMode = VIEW_MODE;
    }
}
