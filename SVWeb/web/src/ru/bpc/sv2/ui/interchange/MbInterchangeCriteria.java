package ru.bpc.sv2.ui.interchange;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import org.springframework.expression.ExpressionParser;
import org.springframework.expression.spel.standard.SpelExpressionParser;
import ru.bpc.sv2.interchange.Fee;
import ru.bpc.sv2.interchange.FeeCriteria;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.interchange.InterchangeDao;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.CurrencyUtils;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;

import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.component.UIComponent;
import javax.faces.component.UIInput;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import javax.faces.validator.ValidatorException;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.MissingResourceException;
import java.util.ResourceBundle;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;

@ViewScoped
@ManagedBean(name = "MbInterchangeCriteria")
public class MbInterchangeCriteria extends AbstractTreeBean<FeeCriteria> {
	private static final long serialVersionUID = 9180157082872879356L;
	private static Logger logger = Logger.getLogger("OPER_RPOCESSING");

	private InterchangeDao interchangeDao = new InterchangeDao();

	private FeeCriteria filter;
	private Map<String, Object> paramMap;
	private List<SelectItem> parameters;
	private String[] operators = {"==", "!=", ">", "<", ">=", "<=", "IN"};
	private String operator;
	private Map<String, String> dictionaries;
	private Map<String, String> dataTypes;
	private String parameter;
	private Map<String, String> regionsMap;
	private List<SelectItem> mcRegions;
	private Map<String, String> feeTypesMap;
	private List<SelectItem> feeTypes;
	private String module;
	private Set<String> countryParams;
	private Set<String> currencyParams;
	private List<SelectItem> fees;
	private Map<Long, String> feesMap;
	private Map<Long, String> parentMap;

	private boolean hasFeeTypes = false;

	private Date startDateTo;
	private Date endDateTo;

	private FeeCriteria[] trees;
	private List<SelectItem> parents;

	private Long srcCriteria;
	private Long dstCriteria;

	public Long getSrcCriteria() {
		return srcCriteria;
	}

	public void setSrcCriteria(Long srcCriteria) {
		this.srcCriteria = srcCriteria;
	}

	public Long getDstCriteria() {
		return dstCriteria;
	}

	public void setDstCriteria(Long dstCriteria) {
		this.dstCriteria = dstCriteria;
	}

	public void cloneCriteria() {
		try {
			logger.info("Clone " + srcCriteria + " to " + dstCriteria);
			FeeCriteria src = findTree(srcCriteria, trees);
			if (src != null) {
				if (dstCriteria != null) {
					src.setParentId(dstCriteria);
				} else {
					src.setParentId(null);
				}
				interchangeDao.cloneFeeCriteria(module, src);
			}
			clearBean();
			loadTree();
		} catch (Exception ex) {
			logger.error("Error on clone fee criteria", ex);
			FacesUtils.addErrorExceptionMessage(ex);
		}
	}

	private FeeCriteria findTree(Long id, FeeCriteria[] trees) {
		for (FeeCriteria fc : trees) {
			FeeCriteria f = findTree(id, fc);
			if (f != null) {
				return f;
			}
		}
		return null;
	}

	private FeeCriteria findTree(long id, FeeCriteria tree) {
		if (tree.getId().equals(id)) {
			return tree;
		}
		if (tree.getChildren() != null && !tree.getChildren().isEmpty()) {
			List<FeeCriteria> children = tree.getChildren();
			for (FeeCriteria c : children) {
				FeeCriteria fc = findTree(id, c);
				if (fc != null) {
					return fc;
				}
			}
		}
		return null;
	}

	public FeeCriteria getCurrentNode() {
		return currentNode;
	}

	public List<SelectItem> getParameters() {
		if (parameters != null) {
			parameter = parameters.get(0).getValue().toString();
			return parameters;
		}
		return null;
	}

	public Date getStartDateTo() {
		return startDateTo;
	}

	public void setStartDateTo(Date startDateTo) {
		this.startDateTo = startDateTo;
	}

	public Date getEndDateTo() {
		return endDateTo;
	}

	public void setEndDateTo(Date endDateTo) {
		this.endDateTo = endDateTo;
	}

	public String goToFees() {
		if (module == null) {
			return null;
		}
		String url = "interchange|" + module.toLowerCase() + "_fees";
		Menu mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		mbMenu.externalSelect(url);
		return url;
	}

	public Map<Long, String> getFeesMap() {
		if (fees == null) {
			getFees();
		}
		return feesMap;
	}

	public void setFeesMap(Map<Long, String> feesMap) {
		this.feesMap = feesMap;
	}

	public List<SelectItem> getFees() {
		if (module != null) {
			try {
				CurrencyUtils utils = (CurrencyUtils) ManagedBeanWrapper.getManagedBean("CurrencyUtils");
				DecimalFormat percentDf = new DecimalFormat("#########0.00");
				DecimalFormat amountDf = new DecimalFormat("#########0.00####");
				List<Fee> list = interchangeDao.getFees(module);
				fees = new ArrayList<SelectItem>();
				feesMap = new HashMap<Long, String>();
				StringBuilder sb = new StringBuilder();
				for (Fee f : list) {
					switch (f.getType()) {
						case 0://fixed amount
							sb.append(amountDf.format(f.getAmount()));
							if (f.getCurrency() != null) {
								sb.append(' ');
								sb.append(utils.getCurrencyShortNamesMap().get(f.getCurrency()));
							}
							break;
						case 1://percent
							sb.append(percentDf.format(f.getPercent()));
							sb.append('%');
							break;
						case 2://min fixed and percent
							sb.append("MIN (");
							sb.append(percentDf.format(f.getPercent()));
							sb.append("%, ");
							sb.append(amountDf.format(f.getAmount()));
							if (f.getCurrency() != null) {
								sb.append(' ');
								sb.append(utils.getCurrencyShortNamesMap().get(f.getCurrency()));
							}
							sb.append(')');
							break;
						case 3://max fixed and percent
							sb.append("MAX (");
							sb.append(percentDf.format(f.getPercent()));
							sb.append("%, ");
							sb.append(amountDf.format(f.getAmount()));
							if (f.getCurrency() != null) {
								sb.append(' ');
								sb.append(utils.getCurrencyShortNamesMap().get(f.getCurrency()));
							}
							sb.append(')');
							break;
						case 4://fixed + percent
							sb.append(percentDf.format(f.getPercent()));
							sb.append("% + ");
							sb.append(amountDf.format(f.getAmount()));
							if (f.getCurrency() != null) {
								sb.append(' ');
								sb.append(utils.getCurrencyShortNamesMap().get(f.getCurrency()));
							}
							break;
					}
					fees.add(new SelectItem(f.getId(), f.getId() + " - " + sb.toString()));
					feesMap.put(f.getId(), f.getId() + " - " + sb.toString());
					sb.setLength(0);
				}
			} catch (Exception ex) {
				logger.error(ex);
			}
		}
		return fees;
	}

	public String getOperator() {
		return operator;
	}

	public void setOperator(String operator) {
		this.operator = operator;
	}

	private void loadParameters(String paramsBundle) {
		ResourceBundle rb = ResourceBundle.getBundle(paramsBundle);
		parameters = new ArrayList<SelectItem>();
		dictionaries = new HashMap<String, String>();
		dataTypes = new HashMap<String, String>();
		countryParams = new HashSet<String>();
		currencyParams = new HashSet<String>();
		SortedSet<String> keySet = new TreeSet<String>(rb.keySet());
		for (String key : keySet) {
			SelectItem si = new SelectItem();
			String[] value = rb.getString(key).split(":");
			si.setValue(key);
			si.setLabel(key + " - " + value[0]);
			dataTypes.put(key, value[1]);
			if (value.length > 2) {
				String dict = value[2];
				if (dict.equalsIgnoreCase("COUNTRY")) {
					countryParams.add(key);
				} else if (dict.equalsIgnoreCase("CURRENCY")) {
					currencyParams.add(key);
				} else {
					dictionaries.put(key, dict);
				}
			}
			parameters.add(si);
		}
	}

	public boolean isCountryParam() {
		if (countryParams == null || parameter == null) {
			return false;
		}
		return countryParams.contains(parameter);
	}

	public boolean isCurrencyParam() {
		if (currencyParams == null || parameter == null) {
			return false;
		}
		return currencyParams.contains(parameter);
	}

	public void resetParameter() {
		parameter = null;
	}

	private void loadRegions(String regionsBundle) {
		if (regionsBundle == null || regionsBundle.trim().isEmpty()) {
			return;
		}
		ResourceBundle rb = ResourceBundle.getBundle(regionsBundle);
		mcRegions = new ArrayList<SelectItem>();
		regionsMap = new HashMap<String, String>();
		SortedSet<String> keySet = new TreeSet<String>(rb.keySet());
		for (String key : keySet) {
			String value = key + " - " + rb.getString(key);
			mcRegions.add(new SelectItem(key, value));
			regionsMap.put(key, value);
		}
	}

	private void loadFeeTypes() {
		if (feeTypes == null) {
			try {
				ResourceBundle rb =
						ResourceBundle.getBundle("ru.bpc.sv2.ui.bundles." + module.toLowerCase() + "_fee_types");
				feeTypes = new ArrayList<SelectItem>();
				feeTypesMap = new HashMap<String, String>();
				SortedSet<String> keySet = new TreeSet<String>(rb.keySet());
				for (String key : keySet) {
					String value = key + " - " + rb.getString(key);
					feeTypes.add(new SelectItem(key, value));
					feeTypesMap.put(key, value);
				}
				hasFeeTypes = true;
			} catch (MissingResourceException ex) {
				hasFeeTypes = false;
				logger.info("There are no fee types defined for " + module + " module");
			}
		}
	}

	public boolean isHasFeeTypes() {
		return hasFeeTypes;
	}

	public Map<String, String> getFeeTypesMap() {
		return feeTypesMap;
	}

	public List<SelectItem> getFeeTypes() {
		return feeTypes;
	}

	public String getParameter() {
		return parameter;
	}

	public void setParameter(String parameter) {
		this.parameter = parameter;
	}

	public Map<String, String> getDictionaries() {
		return dictionaries;
	}

	public List<SelectItem> getParamDict() {
		DictUtils utils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		return utils.getArticles(dictionaries.get(parameter));
	}

	public Map<String, String> getDataTypes() {
		return dataTypes;
	}

	public String[] getOperators() {
		return operators;
	}

	public void validateModifier(FacesContext context, UIComponent toValidate, Object value) {
		String modifier = (String) value;
		try {
			ExpressionParser parser = new SpelExpressionParser();
			parser.parseExpression(modifier);
		} catch (Exception e) {
			((UIInput) toValidate).setValid(false);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Interchange", "invalid_modifier");
			FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
			context.addMessage(toValidate.getClientId(context), message);
			logger.error("", e);
			throw new ValidatorException(message);
		}
	}

	public Map<String, String> getRegionsMap() {
		return regionsMap;
	}

	public List<SelectItem> getMcRegions() {
		return mcRegions;
	}

	public boolean isRegionsEmpty() {
		if (mcRegions == null) {
			return false;
		}
		return mcRegions.isEmpty();
	}

	public void saveCriteria() {
		try {
			boolean update = true;
			if (currentNode.getId() == null || currentNode.getId().equals(0L)) {
				update = false;
			}
			interchangeDao.saveFeeCriteria(module, currentNode, update);
			clearBean();
			loadTree();
		} catch (Exception ex) {
			logger.error("Error on saving fee criteria", ex);
			FacesUtils.addErrorExceptionMessage(ex);
		}
	}

	public void deleteCriteria() {
		if (currentNode == null || currentNode.getId() == null) {
			return;
		}
		try {
			if (currentNode.getChildren() == null || !currentNode.getChildren().isEmpty()) {
				throw new UserException("You can't remove criteria which contains childs.\n" +
						"You have to remove all childs before.");
			}
			interchangeDao.deleteFeeCriteria(module, currentNode.getId());
			currentNode = null;
			clearBean();
			loadTree();
		} catch (Exception ex) {
			logger.error("Error on deleting criteria", ex);
			FacesUtils.addErrorExceptionMessage(ex);
		}
	}

	@PostConstruct
	public void init() {
		setDefaultValues();
	}

	public void setModule(String module) {
		this.module = module;
		loadFeeTypes();
	}

	public void setParamsBundle(String paramsBundle) {
		loadParameters(paramsBundle);
	}

	public void setRegionsBundle(String regionsBundle) {
		loadRegions(regionsBundle);
	}

	public String getModule() {
		return module;
	}

	private void setFilters() {
		FeeCriteria feeFilter = getFilter();
		filters = new ArrayList<Filter>();
		if (feeFilter.getFeeId() != null) {
			filters.add(new Filter("fee_id", feeFilter.getFeeId()));
		}
		if (feeFilter.getFeeType() != null && !feeFilter.getFeeType().trim().isEmpty()) {
			filters.add(new Filter("fee_type", feeFilter.getFeeType()));
		}
		if (feeFilter.getModifier() != null && !feeFilter.getModifier().trim().isEmpty()) {
			filters.add(new Filter("modifier", feeFilter.getModifier()));
		}
		if (feeFilter.getStartDate() != null) {
			filters.add(new Filter("start_date_from", truncFloor(feeFilter.getStartDate())));
		}
		if (startDateTo != null) {
			filters.add(new Filter("start_date_to", truncCeil(startDateTo)));
		}
		if (feeFilter.getEndDate() != null) {
			filters.add(new Filter("end_date_from", truncFloor(feeFilter.getEndDate())));
		}
		if (endDateTo != null) {
			filters.add(new Filter("end_date_to", truncCeil(endDateTo)));
		}

		if (feeFilter.getOperType() != null && !feeFilter.getOperType().trim().isEmpty()) {
			filters.add(new Filter("oper_type", feeFilter.getOperType()));
		}

		if (feeFilter.getIssCountry() != null && !feeFilter.getIssCountry().trim().isEmpty()) {
			filters.add(new Filter("iss_country", feeFilter.getIssCountry()));
		}

		if (feeFilter.getIssRegion() != null && !feeFilter.getIssRegion().trim().isEmpty()) {
			filters.add(new Filter("iss_region", feeFilter.getIssRegion()));
		}

		if (feeFilter.getAcqCountry() != null && !feeFilter.getAcqCountry().trim().isEmpty()) {
			filters.add(new Filter("acq_country", feeFilter.getAcqCountry()));
		}

		if (feeFilter.getAcqRegion() != null && !feeFilter.getAcqRegion().trim().isEmpty()) {
			filters.add(new Filter("acq_region", feeFilter.getAcqRegion()));
		}
	}

	private Date truncFloor(Date d) {
		Calendar cal = Calendar.getInstance();
		cal.setTime(d);
		cal.set(Calendar.HOUR_OF_DAY, 0);
		cal.set(Calendar.MINUTE, 0);
		cal.set(Calendar.SECOND, 0);
		cal.set(Calendar.MILLISECOND, 0);
		return cal.getTime();
	}

	private Date truncCeil(Date d) {
		Calendar cal = Calendar.getInstance();
		cal.setTime(d);
		cal.set(Calendar.HOUR_OF_DAY, 23);
		cal.set(Calendar.MINUTE, 59);
		cal.set(Calendar.SECOND, 59);
		cal.set(Calendar.MILLISECOND, 999);
		return cal.getTime();
	}

	public void search() {
		curMode = VIEW_MODE;
		searching = true;
		clearBean();
		loadTree();
		paramMap = new HashMap<String, Object>();
	}

	private void clearBean() {
		currentNode = null;
	}

	public void clearFilter() {
		filter = null;
		setSearching(false);
		clearBean();
		setDefaultValues();
		startDateTo = null;
		endDateTo = null;
		trees = null;
		coreItems = null;
	}

	public boolean getSearching() {
		return searching;
	}

	public void setFilter(FeeCriteria filter) {
		this.filter = filter;
	}

	public FeeCriteria getFilter() {
		if (filter == null) {
			filter = new FeeCriteria();
		}
		return filter;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public String getComponentId() {
		return "";
	}

	public Logger getLogger() {
		return logger;
	}

	private void setDefaultValues() {
		filter = new FeeCriteria();
	}

	public Map<String, Object> getParamMap() {
		if (paramMap == null) {
			paramMap = new HashMap<String, Object>();
		}
		return paramMap;
	}

	public void setParamMap(Map<String, Object> paramMap) {
		this.paramMap = paramMap;
	}

	public List<FeeCriteria> getNodeChildren() {
		FeeCriteria level = getCondition();
		if (level == null) {
			if (!treeLoaded || coreItems == null) {
				loadTree();
			}
			return coreItems;
		} else {
			return level.getChildren();
		}
	}

	private FeeCriteria getCondition() {
		return (FeeCriteria) Faces.var("item");
	}

	private void loadParentSelect() {
		if (trees != null && trees.length > 0) {
			parents = new ArrayList<SelectItem>();
			for (FeeCriteria root : trees) {
				parents.add(new SelectItem(root.getId(), root.getName()));
				loadParentSelectChild(root.getChildren());
			}
		}
	}

	private void loadParentSelectChild(List<FeeCriteria> trees) {
		if (trees == null || trees.isEmpty()) {
			return;
		}
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < trees.get(0).getLevel(); i++) {
			sb.append('-');
		}
		sb.append(' ');
		for (FeeCriteria leaf : trees) {
			parents.add(new SelectItem(leaf.getId(), sb.toString() + leaf.getName()));
			loadParentSelectChild(leaf.getChildren());
		}
	}

	private FeeCriteria[] createTrees(FeeCriteria[] criterias) {
		List<FeeCriteria> trees = new ArrayList<FeeCriteria>();
		List<FeeCriteria> allCriteria = new ArrayList<FeeCriteria>(Arrays.asList(criterias));
		while (!allCriteria.isEmpty()) {
			FeeCriteria root = findRoot(allCriteria);
			root.setLevel(0);
			findNodes(1, root, allCriteria);
			trees.add(root);
		}
		Collections.sort(trees);
		return trees.toArray(new FeeCriteria[trees.size()]);
	}

	private FeeCriteria findRoot(List<FeeCriteria> criterias) {
		for (int i = 0; i < criterias.size(); i++) {
			FeeCriteria cl = criterias.get(i);
			if (cl.getParentId() == null) {
				criterias.remove(i);
				return cl;
			}
		}
		return null;
	}

	private void findNodes(int level, FeeCriteria root, List<FeeCriteria> criterias) {
		for (int i = 0; i < criterias.size(); i++) {
			FeeCriteria cl = criterias.get(i);
			if (cl.getParentId() != null && cl.getParentId().equals(root.getId())) {
				criterias.remove(i);
				i--;
				root.getChildren().add(cl);
				cl.setLevel(level);
				findNodes(level + 1, cl, criterias);
				Collections.sort(cl.getChildren());
			}
		}
	}

	public void prepareAdd() {
		curMode = NEW_MODE;
		if (currentNode != null) {
			long parentId = currentNode.getId();
			currentNode = new FeeCriteria();
			currentNode.setParentId(parentId);
		} else {
			currentNode = new FeeCriteria();
		}
	}

	public void prepareClone() {
		if (currentNode != null) {
			srcCriteria = currentNode.getId();
		}
		dstCriteria = null;
	}

	public Map<Long, String> getParentMap() {
		return parentMap;
	}

	public void setParentMap(Map<Long, String> parentMap) {
		this.parentMap = parentMap;
	}

	private void loadParentMap() {
		parentMap = new HashMap<Long, String>();
		for (FeeCriteria fc : trees) {
			parentMap.put(fc.getId(), fc.getName());
		}
	}

	@Override
	protected void loadTree() {
		coreItems = new ArrayList<FeeCriteria>();
		if (!searching) {
			return;
		}
		try {
			setFilters();
			SelectionParams params = new SelectionParams();
			List<FeeCriteria> oldTrees = null;
			if (filters != null && !filters.isEmpty()) {
				params.setFilters(new Filter[0]);
				trees = interchangeDao.getFeeCriterias(module, params);
				trees = createTrees(trees);
				oldTrees = new ArrayList<FeeCriteria>(Arrays.asList(trees));
			}
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			trees = interchangeDao.getFeeCriterias(module, params);
			if (trees != null && trees.length > 0) {
				if (filters != null && !filters.isEmpty()) {
					findTreesForItems(oldTrees);
				}
				loadParentMap();
				trees = createTrees(trees);
				loadParentSelect();
				addNodes(0, coreItems, trees);
				if (nodePath == null) {
					if (currentNode == null) {
						setNode(coreItems.get(0));
						setNodePath(new TreePath(currentNode, null));
					} else {
						if (currentNode.getParentId() != null) {
							setNodePath(formNodePath(trees));
						} else {
							setNodePath(new TreePath(currentNode, null));
						}
					}
				}
			}
			treeLoaded = true;
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	private void findTreesForItems(List<FeeCriteria> oldTrees) {
		List<FeeCriteria> newTrees = new ArrayList<FeeCriteria>();
		for (FeeCriteria fc : trees) {
			if (fc.getChildren() == null || fc.getChildren().isEmpty()) {
				newTrees.add(findTreeForItem(fc, oldTrees));
			} else {
				newTrees.add(fc);
			}
		}
		trees = newTrees.toArray(new FeeCriteria[newTrees.size()]);
	}

	private FeeCriteria findTreeForItem(FeeCriteria item, List<FeeCriteria> oldTrees) {
		for (FeeCriteria fc : oldTrees) {
			if (fc.getId() == item.getId()) {
				return fc;
			}
			FeeCriteria f = findTreeForItem(item, fc.getChildren());
			if (f != null) {
				return fc;
			}
		}
		return null;
	}

	public List<SelectItem> getParents() {
		return parents;
	}

	public void setNode(FeeCriteria node) {
		if (node == null) {
			return;
		}
		this.currentNode = node;
	}

	public FeeCriteria getNode() {
		if (currentNode == null) {
			currentNode = new FeeCriteria();
		}
		return currentNode;
	}

	@Override
	public TreePath getNodePath() {
		return nodePath;
	}

	@Override
	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	public boolean getNodeHasChildren() {
		return (getCondition() != null) && getCondition().isHasChildren();
	}
}
