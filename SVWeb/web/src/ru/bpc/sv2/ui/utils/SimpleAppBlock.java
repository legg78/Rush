package ru.bpc.sv2.ui.utils;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.ui.application.MbApplication;
import ru.bpc.sv2.utils.KeyLabelItem;
import util.auxil.ManagedBeanWrapper;

public abstract class SimpleAppBlock extends ApplicationBlockBean implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private ApplicationElement sourceRootEl;

    /**
     * The deep copy of the source element. It is used to accept/reject changes. If changes are accepted, all changes
     * made to local element are applied to the source element.
     */
	private ApplicationElement localRootEl;
	private String elementName;
	
	private List<ApplicationElement> flexFields;
	private ApplicationElement activeFlexField;
	private ApplicationElement newFlexField;
	private final TableRowSelection<ApplicationElement> flexFieldSelection;
	private final DaoDataModel<ApplicationElement> flexFieldsSource;
	
	public abstract void formatObject(ApplicationElement element);
	
	/*
	 * activeItem - editing in block entity. e.g Address, Person, Contact
	 * logger - log4j logger
	 * objectAttrs - a map contains pairs <K: element name, T: element object>
	 */

	protected abstract Logger getLogger();
	
	public abstract Map<String, ApplicationElement> getObjectAttrs();
	
	public SimpleAppBlock() {
		flexFields = new ArrayList<ApplicationElement>();
		flexFieldsSource = new DaoDataModel<ApplicationElement>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected ApplicationElement[] loadDaoData(SelectionParams params) {
				return flexFields.toArray(new ApplicationElement[flexFields.size()]);
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				return flexFields.size();
			}
		};

		flexFieldSelection = new TableRowSelection<ApplicationElement>(null, flexFieldsSource);
	}

	@Override
	public void init() {
		clear();
		MbApplication appBean = (MbApplication) ManagedBeanWrapper
				.getManagedBean("MbApplication");
		setSourceRootEl(appBean.getNode());
		try {
			ApplicationElement clone = getSourceRootEl().clone();
			setLocalRootEl(clone);
		} catch (CloneNotSupportedException e) {
			getLogger().error("", e);
		}
		parseAppBlock();
		parseFlexFields();
	}

    /**
     * Synchronize complex child elements between the source and the locale element.
     * 
     * The 'Add element' action on the elements tree affects source root element, thus all changes made on the source root
     * (add child element in this case) must be reflected to local root element.
     * 
     * See CORE-8503
     * 
     * Refreshes all complex childs of the local element relative to the source element.
     */
    public void addChildElementSync() {
        ApplicationElement localAppElement = getLocalRootEl();

        if (localAppElement == null) {
            return;
        }

        // remove old complex child elements
        for (final Iterator<ApplicationElement> localChildsIterator = localAppElement.getChildren().iterator(); localChildsIterator.hasNext();) {
            ApplicationElement localChild = localChildsIterator.next();

            if (localChild.isComplex()) {
                localChildsIterator.remove();
            }
        }

        // copy all complex child elements from the source
        for (ApplicationElement child : getSourceRootEl().getChildren()) {
            try {
                
                if (child.isComplex()) {
                    ApplicationElement clone = child.clone();
                    clone.setParent(localAppElement);
    
                    localAppElement.addChildren(clone);
                }
            } catch (CloneNotSupportedException e) {
                getLogger().error("Unable to clone source child elements", e);
                FacesUtils.addMessageError("Unable to clone source child elements");
            }
        }
    }

	protected void clear() {
		setSourceRootEl(null);
		setLocalRootEl(null);
		clearFlexFields();
	}

	public void applyDependence() {
		MbApplication appBean = (MbApplication) ManagedBeanWrapper
				.getManagedBean("MbApplication");
		formatObject();
		appBean.applyDependenceWhenChangeValue(getObjectAttrs().get(
				getElementName()));
		parseAppBlock();
	}
	
	@Override
	public void formatObject() {
		formatObject(getLocalRootEl());
		MbApplication.updateAdditionalDesc(getLocalRootEl());
		formatFlexFields();
		getLocalRootEl().apply(getSourceRootEl());
	}
	
	public String[] getDependentElements() {
		List<String> list = new ArrayList<String>();
		for (ApplicationElement el : getLocalRootEl().getChildren()) {
			if (el.getDependent()) {
				list.add(el.getName());
				list.add(el.getName() + "_LABEL");
			}
		}
		return list.toArray(new String[list.size()]);
	}

	protected ApplicationElement getSourceRootEl() {
		return sourceRootEl;
	}

	protected void setSourceRootEl(ApplicationElement sourceRootEl) {
		this.sourceRootEl = sourceRootEl;
	}

	protected ApplicationElement getLocalRootEl() {
		return localRootEl;
	}

	protected void setLocalRootEl(ApplicationElement localRootEl) {
		this.localRootEl = localRootEl;
	}

	public String getElementName() {
		return elementName;
	}

	public void setElementName(String elementName) {
		this.elementName = elementName;
	}
	
	protected void parseFlexFields() {
		if (localRootEl == null) {
			return;
		}

		flexFields = new ArrayList<ApplicationElement>();
		for (ApplicationElement elem: localRootEl.getChildren()) {
			if (!getObjectAttrs().containsKey(elem.getName()) && !elem.isComplex()
					&& !elem.getContent()) {
				
				ApplicationElement field = new ApplicationElement();
				field.setId(elem.getId());
				field.setDataId(elem.getDataId());
				field.setName(elem.getName());
				field.setShortDesc(elem.getShortDesc());
				if (elem.getValueD() != null) {
					field.setValueD(new Date(elem.getValueD().getTime()));
				}
				field.setValueN(elem.getValueN());
				field.setValueV(elem.getValueV());
				field.setLovId(elem.getLovId());
				field.setDataType(elem.getDataType());
				field.setLovValue(elem.getLovValue());
				field.setLovName(elem.getLovName());
				field.setLov(elem.getLov());
				
				flexFields.add(field);
				getObjectAttrs().put(elem.getName(), localRootEl.getChildByName(elem.getName(), 1));
			}
		}
	}

	protected void formatFlexFields() {
		if (localRootEl == null) {
			return;
		}
		
		for (ApplicationElement elem: localRootEl.getChildren()) {
			for (ApplicationElement flex: flexFields) {
				if (elem.getName().equals(flex.getName())) {
					elem.setValueD(flex.getValueD());
					elem.setValueN(flex.getValueN());
					elem.setValueV(flex.getValueV());
					elem.setLovValue(flex.getLovValue());
					break;
				}
			}
		}
	}

	public List<ApplicationElement> getFlexFields() {
		return flexFields;
	}

	public void setFlexFields(List<ApplicationElement> flexFields) {
		this.flexFields = flexFields;
	}

	public ApplicationElement getActiveFlexField() {
		return activeFlexField;
	}

	public void setActiveFlexField(ApplicationElement activeFlexField) {
		this.activeFlexField = activeFlexField;
	}

	public SimpleSelection getFlexFieldSelection() {
		return flexFieldSelection.getWrappedSelection();
	}

	public void setFlexFieldSelection(SimpleSelection selection) {
		flexFieldSelection.setWrappedSelection(selection);
		activeFlexField = flexFieldSelection.getSingleSelection();
	}
	
	public ApplicationElement getNewFlexField() {
		return newFlexField;
	}

	public void setNewFlexField(ApplicationElement newFlexField) {
		this.newFlexField = newFlexField;
	}

	public DaoDataModel<ApplicationElement> getFlexFieldsSource() {
		if (flexFieldsSource.getActivePage() != null && flexFieldsSource.getActivePage().size() == 0
				&& flexFields.size() > 0) {
			flexFieldsSource.flushCache();
		}
		return flexFieldsSource;
	}

	public void setFlexField() {
		newFlexField = new ApplicationElement();
		activeFlexField.clone(newFlexField);
	}
	
	public void saveFlexField() {
		if (newFlexField.getLovId() != null) {
			if (newFlexField.isChar()) {
				newFlexField.setLovValue(getLovValue(newFlexField.getValueV()));
			} else if (newFlexField.isNumber()) {
				newFlexField.setLovValue(getLovValue(String.valueOf(newFlexField.getValueN().intValue())));
			}
		}
		newFlexField.clone(activeFlexField);
	}
	
	public void cancel() {
		
	}
	
	public void clearFlexFields() {
		flexFields = null;
		flexFieldsSource.flushCache();
		flexFieldSelection.clearSelection();
		activeFlexField = null;
		newFlexField = null;
	}
	
	public List<SelectItem> getFlexLovValues() {
		if (newFlexField != null && newFlexField.getLovId() != null) {
			return getLov(newFlexField);
		}
		return new ArrayList<SelectItem>();
	}
	
	private String getLovValue(String valueId) {
		for (KeyLabelItem item: newFlexField.getLov()) {
			if (item.getValue() != null && valueId.equals(item.getValue().toString())) {
				return item.getLabel();
			}
		}
		return null;
	}
}
