package ru.bpc.sv2.ui.administrative.roles;

import org.apache.log4j.Logger;
import org.springframework.util.StringUtils;
import ru.bpc.sv2.acm.PrivLimitation;
import ru.bpc.sv2.acm.PrivLimitationField;
import ru.bpc.sv2.common.Label;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccessManagementDao;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractSearchAllBean;
import ru.bpc.sv2.ui.utils.AbstractSearchBean;
import ru.bpc.sv2.ui.utils.FacesUtils;

import javax.annotation.PostConstruct;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbPrivLimitationField")
public class MbPrivLimitationField extends AbstractSearchAllBean<PrivLimitationField, PrivLimitationField> {
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");


	private AccessManagementDao acmDao = new AccessManagementDao();
	private CommonDao commonDao = new CommonDao();

	private PrivLimitation limitation;
	private List<SelectItem> fields = null;
	private PrivLimitationField newItem;

	@Override
	protected PrivLimitationField createFilter() {
		return new PrivLimitationField();
	}

	@Override
	protected Logger getLogger() {
		return logger;
	}

	@Override
	protected PrivLimitationField addItem(PrivLimitationField item) {
		return null;
	}

	@Override
	protected PrivLimitationField editItem(PrivLimitationField item) {
		return null;
	}

	@Override
	protected void deleteItem(PrivLimitationField item) {

	}

	@Override
	protected void initFilters(PrivLimitationField filter, List<Filter> filters) {
		filters.add(Filter.create("lang", userLang));
		filters.add(Filter.create("privLimitId", limitation.getId()));
	}

	@Override
	protected List<PrivLimitationField> getObjectList(Long userSessionId, SelectionParams params) {
		if (limitation == null) {
			return new ArrayList<>();
		}
		return acmDao.getPrivLimitationFields(userSessionId, params);
	}

	@Override
	public void clearFilter() {
		super.clearFilter();
		this.limitation = null;
	}

	public void setPrivLimitation(PrivLimitation limitation) {
		this.clearState();
		this.limitation = limitation;
	}

	public PrivLimitation getPrivLimitation() {
		return this.limitation;
	}

	public List<SelectItem> getFields() {
		if (fields == null) {
			fields = getDictUtils().getLov(LovConstants.LIMITATION_FIELDS_LIST);
		}
		return fields;
	}

	public PrivLimitationField getNewItem() {
		if (newItem == null) {
			newItem = new PrivLimitationField();
		}
		return newItem;
	}

	public void setNewItem(PrivLimitationField newItem) {
		this.newItem = newItem;
	}


	public Label[] labelAutocomplete(Object suggest) {
		String value = (String) suggest;
		if (value == null) {
			return null;
		}

		if (StringUtils.isEmpty(value)) {
			return null;
		}
		SelectionParams sp = SelectionParams.build(
				"lang", userLang,
				"quickSearch", Filter.mask("*" + value + "*"));
		sp.setRowIndexStart(0);
		sp.setRowIndexEnd(20);
		return commonDao.getLabels(userSessionId, sp);
	}

	public void selectLabel(Label o) {
		if (o == null) {
			newItem.setLabel(null);
			newItem.setLabelId(null);
		} else {
			newItem.setLabel(o.getText());
			newItem.setLabelId(o.getId());
		}
	}

	public void add() {
		newItem = new PrivLimitationField();
		newItem.setPrivLimitId(limitation.getId());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newItem = (PrivLimitationField) activeItem.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newItem = activeItem;
		}
		curMode = EDIT_MODE;
	}



	public void save() {
		try {
			if (isEditMode()) {
				newItem = acmDao.modifyLimitationField(userSessionId, userLang, newItem);
				dataModel.replaceObject(activeItem, newItem);
			} else {
				newItem = acmDao.addLimitationField(userSessionId, userLang, newItem);
				tableRowSelection.addNewObjectToList(newItem);
			}
			activeItem = newItem;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			acmDao.removeLimitationField(userSessionId, activeItem);
			activeItem = tableRowSelection.removeObjectFromList(activeItem);

			if (activeItem == null) {
				clearState();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void hide() {
		clearFilter();
	}
}
