package ru.bpc.sv2.ui.utils;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import javax.annotation.PostConstruct;
import javax.faces.event.ValueChangeEvent;
import java.util.HashSet;
import java.util.Set;

/**
 * Abstract mbean for pages with search form and tabs
 *
 * @param <F> Search filter type
 * @param <R> Table row type
 */
public abstract class AbstractSearchTabbedBean<F, R extends ModelIdentifiable> extends AbstractSearchBean<F, R> {
	static final long serialVersionUID = 1L;
	protected String tabName;
	protected Set<String> loadedTabs;

	protected abstract void onLoadTab(String tabName);

	@Override
	@PostConstruct
	public void init() {
		super.init();
		tabName = null;
		loadedTabs = new HashSet<>();
	}

	@Override
	@SuppressWarnings("UnusedParameters")
	protected void onItemSelected(R activeItem) {
		super.onItemSelected(activeItem);
		loadedTabs.clear();
		if (activeItem != null) {
			loadTab(getTabName());
		}
	}

	@Override
	public void clearState() {
		super.clearState();
		loadedTabs.clear();
	}

	@Override
	public String getTabName() {
		if (tabName == null) {
			setTabName(AbstractSearchBean.DETAILS_TAB);
		}
		return tabName;
	}

	@Override
	public void setTabName(String tabName) {
		this.tabName = tabName;
		if (loadedTabs.contains(tabName)) {
			return;
		}
		loadTab(tabName);
	}

	private void loadTab(String tabName) {
		if (tabName == null || getActiveItem() == null) {
			return;
		}
		loadedTabs.add(tabName);
		onLoadTab(tabName);
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		dataModel.flushCache();
	}
}
