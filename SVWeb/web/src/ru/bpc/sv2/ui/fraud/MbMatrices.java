package ru.bpc.sv2.ui.fraud;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.fraud.Matrix;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.FraudDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.ModParam;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbMatrices")
public class MbMatrices extends AbstractBean {
	private static final long serialVersionUID = -2731719768028017269L;

	private static final Logger logger = Logger.getLogger("FRAUD_PREVENTION");

	private static String COMPONENT_ID = "1804:matricesTable";

	private FraudDao _fraudDao = new FraudDao();
	private RulesDao _rulesDao = new RulesDao();

	private Matrix filter;
	private Matrix _activeMatrix;
	private Matrix newMatrix;
	private Matrix detailMatrix;
	private List<SelectItem> paramsList;
	private List<SelectItem> depthCount;
	private final int CHECKS_SCALE = 1011;

	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<Matrix> _matricesSource;
	private final TableRowSelection<Matrix> _itemSelection;
	private String depthX;
	private String depthY;
	private String tabName;

	public MbMatrices() {
		pageLink = "fraud|matrices";
		tabName = "detailsTab";
		_matricesSource = new DaoDataModel<Matrix>() {
			private static final long serialVersionUID = 648785744781087741L;

			@Override
			protected Matrix[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Matrix[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _fraudDao.getMatrices(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Matrix[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _fraudDao.getMatricesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Matrix>(null, _matricesSource);
	}

	public DaoDataModel<Matrix> getMatrices() {
		return _matricesSource;
	}

	public Matrix getActiveMatrix() {
		return _activeMatrix;
	}

	public void setActiveMatrix(Matrix activeMatrix) {
		_activeMatrix = activeMatrix;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeMatrix == null && _matricesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeMatrix != null && _matricesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeMatrix.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeMatrix = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_matricesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeMatrix = (Matrix) _matricesSource.getRowData();
		detailMatrix = (Matrix) _activeMatrix.clone();
		selection.addKey(_activeMatrix.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null
					&& !_itemSelection.getSingleSelection().getId().equals(_activeMatrix.getId())) {
				changeSelect = true;
			}
			_activeMatrix = _itemSelection.getSingleSelection();
			if (_activeMatrix != null) {
				setBeans();
				if (changeSelect) {
					detailMatrix = (Matrix) _activeMatrix.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void search() {
		clearState();
		prepareMatrixValues();
		searching = true;
	}

	private void prepareMatrixValues() {
		setFilters();

		SelectionParams params = new SelectionParams();
		params.setRowIndexStart((pageNumber - 1) * rowsNum);
		params.setRowIndexEnd(pageNumber * rowsNum - 1);
		params.setFilters(filters.toArray(new Filter[filters.size()]));

		try {
			Matrix[] matrices = _fraudDao.getMatrices(userSessionId, params);
			if (matrices != null && matrices.length > 0) {
				_activeMatrix = matrices[0];
				detailMatrix = (Matrix) _activeMatrix.clone();
				setBeans();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	public void setBeans() {
		MbMatrixValues matrixValues = (MbMatrixValues) ManagedBeanWrapper.getManagedBean("MbMatrixValues");
		matrixValues.fullCleanBean();
		matrixValues.getFilter().setMatrixId(_activeMatrix.getId());
		matrixValues.setxScale(_activeMatrix.getxScale());
		matrixValues.setyScale(_activeMatrix.getyScale());
		matrixValues.search();
	}

	public void clearBeansStates() {
		MbMatrixValues matrixValues = (MbMatrixValues) ManagedBeanWrapper.getManagedBean("MbMatrixValues");
		matrixValues.fullCleanBean();
	}

	public void clearFilter() {
		filter = null;

		clearState();
		searching = false;
	}

	public Matrix getFilter() {
		if (filter == null) {
			filter = new Matrix();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(Matrix filter) {
		this.filter = filter;
	}

	private void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filter.getMatrixType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("matrixType");
			paramFilter.setValue(filter.getMatrixType());
			filters.add(paramFilter);
		}
		if (filter.getxScale() != null && filter.getxScale().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("xScale");
			paramFilter.setValue(filter.getxScale().trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getyScale() != null && filter.getyScale().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("yScale");
			paramFilter.setValue(filter.getyScale().trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getLabel() != null && filter.getLabel().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("label");
			paramFilter.setValue(filter.getLabel().trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void add() {
		newMatrix = new Matrix();
		newMatrix.setLang(userLang);
		curLang = newMatrix.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newMatrix = (Matrix) detailMatrix.clone();
			depthX = newMatrix.getxScale().
					substring(
							newMatrix.getxScale().indexOf("(") + 1, 
							newMatrix.getxScale().indexOf(")"));
			newMatrix.setxScale(
					newMatrix.getxScale().
						substring(
							0, 
							newMatrix.getxScale().indexOf("(")));
			depthY = newMatrix.getyScale().
					substring(
							newMatrix.getyScale().indexOf("(") + 1, 
							newMatrix.getyScale().indexOf(")"));
			newMatrix.setyScale(
					newMatrix.getyScale().
						substring(
							0, 
							newMatrix.getyScale().indexOf("(")));
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			StringBuilder str = new StringBuilder();
			str.append(newMatrix.getxScale()).append("(").append(depthX).append(")");
			newMatrix.setxScale(str.toString());
			str = new StringBuilder();
			str.append(newMatrix.getyScale()).append("(").append(depthY).append(")");
			newMatrix.setyScale(str.toString());
			if (isNewMode()) {
				newMatrix = _fraudDao.addMatrix(userSessionId, newMatrix);
				detailMatrix = (Matrix) newMatrix.clone();
				_itemSelection.addNewObjectToList(newMatrix);
			} else if (isEditMode()) {
				newMatrix = _fraudDao.modifyMatrix(userSessionId, newMatrix);
				detailMatrix = (Matrix) newMatrix.clone();
				if (!userLang.equals(newMatrix.getLang())) {
					newMatrix = getNodeByLang(_activeMatrix.getId(), userLang);
				}
				_matricesSource.replaceObject(_activeMatrix, newMatrix);
			}
			_activeMatrix = newMatrix;
			setBeans();
			curMode = VIEW_MODE;
			depthX = new String();
			depthY = new String();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_fraudDao.removeMatrix(userSessionId, _activeMatrix);
			_activeMatrix = _itemSelection.removeObjectFromList(_activeMatrix);

			if (_activeMatrix == null) {
				clearState();
			} else {
				setBeans();
				detailMatrix = (Matrix) _activeMatrix.clone();
			}

			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public Matrix getNewMatrix() {
		if (newMatrix == null) {
			newMatrix = new Matrix();
		}
		return newMatrix;
	}

	public void setNewMatrix(Matrix newMatrix) {
		this.newMatrix = newMatrix;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeMatrix = null;
		detailMatrix = null;
		_matricesSource.flushCache();

		clearBeansStates();
	}

	public void changeLanguage(ValueChangeEvent checkGroup) {
		curLang = (String) checkGroup.getNewValue();
		detailMatrix = getNodeByLang(detailMatrix.getId(), curLang);
	}

	public Matrix getNodeByLang(Integer id, String lang) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(id.toString());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(lang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Matrix[] matrices = _fraudDao.getMatrices(userSessionId, params);
			if (matrices != null && matrices.length > 0) {
				return matrices[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getMatrixTypes() {
		return getDictUtils().getArticles(DictNames.MATRIX_TYPE, true);
	}

	public void confirmEditLanguage() {
		curLang = newMatrix.getLang();
		Matrix tmp = getNodeByLang(newMatrix.getId(), newMatrix.getLang());
		if (tmp != null) {
			newMatrix.setLabel(tmp.getLabel());
			newMatrix.setDescription(tmp.getDescription());
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public Matrix getDetailMatrix() {
		return detailMatrix;
	}

	public void setDetailMatrix(Matrix detailMatrix) {
		this.detailMatrix = detailMatrix;
	}

	public void generatePackage() {
		try {
			_fraudDao.generatePackage(userSessionId);
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}
	public String getShortScale(){
		if (_activeMatrix == null) return null;
		int k = 4;
		String x = _activeMatrix.getxScale();
		String y = _activeMatrix.getyScale();
		if ((x+"/"+y).length()<=10)
			return x+"/"+y;
			
		if (x.length()>y.length()){
			if (y.length()>k){
				y = y.substring(0, k);
				x = x.substring(0, k);
			} else{
				x = x.substring(0, k+(k - y.length()));
			}
		} else {
			if (x.length()>k){
				y = y.substring(0, k);
				x = x.substring(0, k);
			} else{
				y = y.substring(0, k+(k - x.length()));
			}
		}
		return x+"./"+y+".";
	}

	public List<SelectItem> getParamsList() {
		if (paramsList == null &&
				(curMode == EDIT_MODE || curMode == NEW_MODE)){
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("scaleId");
			filters[0].setValue(CHECKS_SCALE);
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(userLang);
	
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(Integer.MAX_VALUE);
			params.setFilters(filters);
	
			try {
				ModParam[] modParams = _rulesDao.getModParamsByScaleId(userSessionId,
						params);
				paramsList = new ArrayList<SelectItem>(modParams.length);
				for (ModParam modParam : modParams) {
					paramsList.add(new SelectItem(modParam.getSystemName(), modParam.getName()));
				}
			} catch (Exception e) {
				logger.error("", e);
				FacesUtils.addMessageError(e);
			}
		}
		return paramsList;
	}

	public void setParamsList(List<SelectItem> paramsList) {
		this.paramsList = paramsList;
	}

	public String getDepthX() {
		return depthX;
	}

	public void setDepthX(String depthX) {
		this.depthX = depthX;
	}

	public String getDepthY() {
		return depthY;
	}

	public void setDepthY(String depthY) {
		this.depthY = depthY;
	}

	public List<SelectItem> getDepthCount() {
		if (depthCount == null){
			depthCount = new ArrayList<SelectItem>();
			for (int i = 1; i <= 20; i++){
				depthCount.add(new SelectItem(String.valueOf(i),
						String.valueOf(i)));
			}
		}
		return depthCount;
	}

	public void setDepthCount(List<SelectItem> depthCount) {
		this.depthCount = depthCount;
	}
	
	public String getTabName() {
		return tabName;
	}
	
	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

}
