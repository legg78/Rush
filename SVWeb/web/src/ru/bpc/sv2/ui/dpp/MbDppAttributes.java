package ru.bpc.sv2.ui.dpp;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.dpp.DppAttributeValue;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.DppDao;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbDppAttributes")
public class MbDppAttributes extends AbstractTreeBean<DppAttributeValue>{
	private static final Logger logger = Logger.getLogger("DPP");
	
	private DppDao dppDao = new DppDao();
	
	private DppAttributeValue filter = null;
	
	public MbDppAttributes(){
	
	}
	
	private void setFilters(){
		filters = new ArrayList<Filter>();
		if (getFilter().getDppId() != null){
			Filter f = new Filter();
			f.setElement("dppId");
			f.setValue(getFilter().getDppId());
			filters.add(f);
		}
		
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(userLang);
		filters.add(f);
	}

	public DppAttributeValue getFilter() {
		return filter;
	}

	public void setFilter(DppAttributeValue filter) {
		this.filter = filter;		
	}
	
	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	private DppAttributeValue getAttribute() {
		return (DppAttributeValue) Faces.var("dppAttr");
	}
	
	protected void loadTree() {
		if (!searching || getFilter().getDppId() == null)
			return;

		try {
			setFilters();

			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			DppAttributeValue[] attrs = dppDao.getDppAttributeValues(userSessionId, params);

			coreItems = new ArrayList<DppAttributeValue>();

			if (attrs != null && attrs.length > 0) {
				addNodes(0, coreItems, attrs);
				if (currentNode == null) {
					currentNode = coreItems.get(0);
					setNodePath(new TreePath(currentNode, null));
				} else {
					if (currentNode.getParentId() != null) {
						setNodePath(formNodePath(attrs));
					} else {
						setNodePath(new TreePath(currentNode, null));
					}
				}
				
			}
			treeLoaded = true;
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}
	
	public List<DppAttributeValue> getNodeChildren() {
		DppAttributeValue attr = getAttribute();
		if (attr == null) {
			if (!treeLoaded || coreItems == null) {
				loadTree();
			}
			return coreItems;
		} else {
			return attr.getChildren();
		}
	}
	
	public boolean getNodeHasChildren() {
		return (getAttribute() != null) && getAttribute().isHasChildren();
	}
	
	public void clearBean() {
		currentNode = null;
		nodePath = null;
		coreItems = null;
		treeLoaded = false;
		curLang = userLang;
	}

	public void search(){
		clearBean();
		searching = true;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}
}
