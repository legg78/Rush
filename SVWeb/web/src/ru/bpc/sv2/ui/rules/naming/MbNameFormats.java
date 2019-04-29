package ru.bpc.sv2.ui.rules.naming;

import java.io.Serializable;

import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.rules.naming.NameFormat;
import ru.bpc.sv2.ui.utils.AbstractBean;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbNameFormats")
public class MbNameFormats extends AbstractBean implements Serializable {
	
	private static final long serialVersionUID = 1L;
	
	private NameFormat savedFilter;
	private NameFormat format;
	private NameFormat savedActiveFormat;
	private NameFormat savedNewFormat;
	private SimpleSelection storedItemSelection;
	private String savedBackLink;
	private int savedCurMode;
	
	private String tabName = "detailsTab";
	private boolean keepState = false;
	private boolean modalMode = false;
	private boolean searching;
	public static final int MODE_FORMAT = 0;
	
    public static final int MODE_SELECT_RANGE = 8;
	
	private int curMode;

	public MbNameFormats() {
		
	}
	
	public NameFormat getFormat() {
		if (format == null)
			format = new NameFormat();	
		return format;
	}

	public void setFormat(NameFormat format) {
		this.format = format;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("baseParamsTab")) {
			MbNameComponentsSearch bean = (MbNameComponentsSearch) ManagedBeanWrapper
					.getManagedBean("MbNameComponentsSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.OPERATION_NAMING_FORMAT;
	}
	
	public boolean isKeepState() {
		return keepState;
	}

	public void setKeepState(boolean keepState) {
		this.keepState = keepState;
	}

	public boolean isModalMode() {
		return modalMode;
	}

	public void setModalMode(boolean modalMode) {
		this.modalMode = modalMode;
	}

	public SimpleSelection getStoredItemSelection() {
		return storedItemSelection;
	}

	public void setStoredItemSelection(SimpleSelection storedItemSelection) {
		this.storedItemSelection = storedItemSelection;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public int getCurMode() {
		return curMode;
	}

	public void setCurMode(int curMode) {
		this.curMode = curMode;
	}

	public NameFormat getSavedFilter() {
		return savedFilter;
	}

	public void setSavedFilter(NameFormat savedFilter) {
		this.savedFilter = savedFilter;
	}

	public NameFormat getSavedActiveFormat() {
		return savedActiveFormat;
	}

	public void setSavedActiveFormat(NameFormat savedActiveFormat) {
		this.savedActiveFormat = savedActiveFormat;
	}

	public NameFormat getSavedNewFormat() {
		return savedNewFormat;
	}

	public void setSavedNewFormat(NameFormat savedNewFormat) {
		this.savedNewFormat = savedNewFormat;
	}

	public String getSavedBackLink() {
		return savedBackLink;
	}

	public void setSavedBackLink(String savedBackLink) {
		this.savedBackLink = savedBackLink;
	}

	public int getSavedCurMode() {
		return savedCurMode;
	}

	public void setSavedCurMode(int savedCurMode) {
		this.savedCurMode = savedCurMode;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}

	
}
