package ru.bpc.sv2.utils;

import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.constants.application.ApplicationConstants;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.Date;
import java.util.List;

public class AppStructureUtils {
	/**
	 * instance() looks for the element with %elementName% name and innerId=0. If it find one, the method calls clone()
	 * and returns the result.
	 *
	 * @param parent      - parent element of %elementName% element
	 * @param elementName
	 * @return
	 */
	public static ApplicationElement instance(ApplicationElement parent, String elementName) {
		ApplicationElement element = parent.getChildByName(elementName, 0);
		if (element == null) {
			throw new IllegalArgumentException("Element \'" + elementName + "\' has not been found");
		}
		if (element.getMaxCount() == null || element.getMaxCount() == 0) {
			throw new IllegalArgumentException("Max count of \'" + elementName + "\' = 0");
		}
		if (element.getCopyCount().equals(element.getMaxCount())) {
			throw new IllegalArgumentException("Limit of elements \'" + elementName + "\' is reached");
		}
		ApplicationElement clone = null;
		try {
			clone = element.clone();
		} catch (CloneNotSupportedException e) {
		}

		int elementCount = element.getCopyCount() + 1;
		element.setCopyCount(elementCount);

		clone.setInnerId(elementCount);
		clone.setContentBlock(element);
		clone.setContent(false);
		clone.setPath(clone.getPath() + elementCount);
		parent.getChildren().add(clone);
		Collections.sort(parent.getChildren());
		return clone;
	}

	/**
	 * Returns an existing element with <code>elementName</code> and <code>innerId</code>.
	 * The searching is performed for the element that are children of <code>parent</code>
	 * For the recursive search use search() mehtod
	 *
	 * @param parent      - parent element of <code>elementName</code> element
	 * @param elementName - Name of the searching element
	 * @param innerId     - Inner ID of the searching element
	 * @throws IllegalArgumentException if the parent don't contain an element with name <code>elementName</code> and <code>innderId</code>
	 */
	public static ApplicationElement retrive(ApplicationElement parent, String elementName, Integer innerId) {
		ApplicationElement element = parent.getChildByName(elementName, innerId);
		if (element == null) {
			throw new IllegalArgumentException("Element \'" + elementName + "\' has not been found");
		}
		return element;
	}

	/**
	 * Returns an existing element with the name equals to the last name of
	 * the passed <code>elementNames</code> array. Firstly the method search an element
	 * with <code>elementNames[0]</code> name in <code>parent</code> element.
	 * Then, founded element becomes parent and operation repeats until the element with
	 * <code>elementNames[n-1]</code> (where n - length of the array) is founded.
	 *
	 * @param parent       - parent element of <code>elementNames[0]</code> element
	 * @param elementNames - an array of element names. The last name of the array is the searching element.
	 * @return
	 * @throws IllegalArgumentException - if the parent don't contain an element with name %elementName%
	 * @deprecated Use ApplicationElement::retrive.
	 */
	@Deprecated
	public static ApplicationElement retrive(ApplicationElement parent, String... elementNames) {
		ApplicationElement e = parent;
		for (String elementName : elementNames) {
			e = retrive(e, elementName, 1);
		}
		return e;
	}

	/**
	 * @deprecated Use ApplicationElement::tryRetrive
	 */
	@Deprecated
	public static ApplicationElement tryRetrive(ApplicationElement parent, String... elementNames) {
		ApplicationElement e = parent;
		for (String elementName : elementNames) {
			e = e.getChildByName(elementName, 1);
			if (e == null) break;
		}
		return e;
	}

	/**
	 * @deprecated Use ApplicationElement::tryRetrive
	 */
	@Deprecated
	public static ApplicationElement tryRetrive(ApplicationElement parent, String elementName, Integer innerId) {
		ApplicationElement element = parent.getChildByName(elementName, innerId);
		return element;
	}

	/**
	 * Returns an existing element with  %elementName% and innerId=1.
	 * The searching is performed recursively for all the parent's children.
	 *
	 * @param parent      - parent element of %elementName% element
	 * @param elementName
	 * @return
	 * @deprecated use ApplicationElement::tryRetrive
	 */
	@Deprecated
	public static ApplicationElement search(ApplicationElement parent, String elementName) {
		ApplicationElement element = parent.getChildByName(elementName, 1);
		if (element == null) {
			for (ApplicationElement child : parent.getChildren()) {
				if (ApplicationConstants.ELEMENT_TYPE_COMPLEX.equals(child.getType())) {
					element = search(child, elementName);
					if (element != null) break;
				} else {
					continue;
				}
			}
		}
		return element;
	}

	/**
	 * Recursive validation of the passed element and all the children of the element
	 *
	 * @param element
	 * @return
	 */
	public static boolean validate(ApplicationElement element) {
		boolean result = true;
		if (ApplicationConstants.ELEMENT_TYPE_SIMPLE.equals(element.getType())) {
			result = element.validateB();
		} else {
			if (!element.getChildren().isEmpty()) {
				for (ApplicationElement child : element.getChildren()) {
					result &= validate(child);
					if (result == false) break;
				}
			}
		}
		return result;
	}

	/**
	 * Delete passed <code>element</code> from its <code>parent</code>.
	 *
	 * @param target - The element needed to be deleted
	 * @param parent - The parent of the element
	 * @throws IllegalArgumentException If minimal limit of copies is reached
	 */
	public static void delete(ApplicationElement target, ApplicationElement parent) {
		ApplicationElement contentBlock = target.getContentBlock();
		if (contentBlock.getCopyCount().equals(contentBlock.getMinCount())) {
			throw new IllegalArgumentException("Cannot delete an element. The minimal limit of copies is reached.");
		}
		contentBlock.setCopyCount(contentBlock.getCopyCount() - 1);
		clearChildren(target);
		parent.getChildren().remove(target);
	}

	/**
	 * Delete passed <code>element</code> from its <code>parent</code>. Its similar to <code>delete(ApplicationElement, ApplicationElement)</code>,
	 * but don't check the limits of the element
	 *
	 * @param target - The element needed to be deleted
	 * @param parent - The parent of the element
	 */
	public static void silentDelete(ApplicationElement target, ApplicationElement parent) {
		ApplicationElement contentBlock = target.getContentBlock();
		contentBlock.setCopyCount(contentBlock.getCopyCount() - 1);
		clearChildren(target);
		parent.getChildren().remove(target);
	}

	/**
	 * Check whether the copies of the elements of <code>target</code>'s type are reached of min limit
	 */
	public static boolean minLimit(ApplicationElement target) {
		ApplicationElement contentBlock = target.getContentBlock();
		boolean result = contentBlock.getCopyCount().equals(contentBlock.getMinCount());
		return result;
	}

	/**
	 * Check whether the copies of <code>target</code> are reached of max limit
	 *
	 * @param contentBlock - Content element
	 */
	public static boolean maxLimit(ApplicationElement contentBlock) {
		boolean result = contentBlock.getCopyCount().equals(contentBlock.getMaxCount());
		return result;
	}

	/**
	 * Walk through all the children of <code>parent</code> with name equals to <code>elementName</code>
	 * and set new innerId to them in order to their positions in <code>parent</code> element. This function
	 * can be useful when we delete an element form the parent. In this case all the elements with innerId values
	 * higher than deleted one have wrong innerId values and we need to reorder them.
	 *
	 * @param parent      - Parent element
	 * @param elementName - The name of the elements we want to reorder
	 */
	public static void reorderInnerId(ApplicationElement parent, String elementName) {
		List<ApplicationElement> children = parent.getChildrenByName(elementName);
		for (int i = 0; i < children.size(); i++) {
			children.get(i).setInnerId(i + 1);
		}
	}

	public static void clearChildren(ApplicationElement element) {
		for (ApplicationElement child : element.getChildren()) {
			clearChildren(child);
		}
		element.getChildren().clear();
	}

	/**
	 * This method is similar to ApplicationElement::apply, but don't copy children of <code>source</code>
	 */
	public static void shallowApply(ApplicationElement source, ApplicationElement target) {
		if (source.getAppType() != null) target.setAppType(source.getAppType());
		if (source.getDataType() != null) target.setDataType(source.getDataType());
		if (source.getDefaultValue() != null) target.setDefaultValue(source.getDefaultValue());
		if (source.getDisplayFormat() != null) target.setDisplayFormat(source.getDisplayFormat());
		if (source.getId() != null) target.setId(source.getId());
		if (source.getIncomingFormat() != null) target.setIncomingFormat(source.getIncomingFormat());
		if (source.getLovId() != null) target.setLovId(source.getLovId());
		if (source.getLov() != null) target.setLov(source.getLov());
		if (source.getMaxLength() != null) target.setMaxLength(source.getMaxLength());
		if (source.getMaxValue() != null) target.setMaxValue(source.getMaxValue());
		if (source.getMinLength() != null) target.setMinLength(source.getMinLength());
		if (source.getMinValue() != null) target.setMinValue(source.getMinValue());
		if (source.getName() != null) target.setName(source.getName());
		if (source.getParentId() != null) target.setParentId(source.getParentId());
		if (source.getType() != null) target.setType(source.getType());
		if (source.getValue() != null) target.setValue(source.getValue());
		if (source.getValueN() != null) target.setValueN(source.getValueN());
		if (source.getValueV() != null) target.setValueV(source.getValueV());
		if (source.getValueD() != null) target.setValueD(source.getValueD());
		if (source.getLovValue() != null) target.setLovValue(source.getLovValue());
		target.setMultiLang(source.isMultiLang());
		if (source.getValueLang() != null) target.setValueLang(source.getValueLang());
		if (source.getInnerId() != null) target.setInnerId(source.getInnerId());
		if (source.getOrderNum() != null) target.setOrderNum(source.getOrderNum());
		if (source.getMaxCount() != null) target.setMaxCount(source.getMaxCount());
		target.setMaxCopy(source.getMaxCopy());
		if (source.getMinCount() != null) target.setMinCount(source.getMinCount());
		if (source.getCopyCount() != null) target.setCopyCount(source.getCopyCount());
		if (source.getStId() != null) target.setStId(source.getStId());
		if (source.getParentDataId() != null) target.setParentDataId(source.getParentDataId());
		if (source.getDataId() != null) target.setDataId(source.getDataId());
		if (source.getVisible() != null) target.setVisible(source.getVisible());
		if (source.getUpdatable() != null) target.setUpdatable(source.getUpdatable());
		if (source.getInsertable() != null) target.setInsertable(source.getInsertable());
		if (source.getDependence() != null) target.setDependence(source.getDependence());
		if (source.getDependent() != null) target.setDependent(source.getDependent());
		if (source.getParent() != null) target.setParent(source.getParent());
		if (source.getShortDesc() != null) target.setShortDesc(source.getShortDesc());
		target.setRequired(source.isRequired());
		if (source.getPath() != null) target.setPath(source.getPath());
		if (source.getEntityType() != null) target.setEntityType(source.getEntityType());
		target.setFake(source.isFake());
		if (source.getEditForm() != null) target.setEditForm(source.getEditForm());
		target.setEffectsOnDesc(source.isEffectsOnDesc());
	}

	public static void print(ApplicationElement element) {
		print(element, 0);
	}

	private static void print(ApplicationElement element, int indent) {
		final String indentSymbol = "   ";
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < indent; i++) sb.append(indentSymbol);
		sb.append(element.getName());
		sb.append(" : ");
		Object value = element.getValue();
		if (value != null) {
			sb.append(value.toString());
		} else {
			sb.append("null");
		}
		System.out.print(sb.toString());
		if (!element.getChildren().isEmpty()) {
			System.out.println("{");
			for (ApplicationElement child : element.getChildren()) {
				print(child, indent + 1);
			}
			for (int i = 0; i < indent; i++) System.out.print(indentSymbol);
			System.out.println("}");
		} else {
			System.out.println();
		}
	}

	public static void setValue(ApplicationElement element, String name, Object value) {
		if (element != null && name != null) {
			ApplicationElement child = element.getChildByName(name, 1);
			setValue(child, value);
		}
	}

    public static void setValue(ApplicationElement element, Object value) {
        if (element != null) {
            if (value != null) {
                if (value instanceof Date) {
                    element.setValueD((Date) value);
                } else if (value instanceof BigDecimal) {
                    element.setValueN((BigDecimal) value);
                } else if (value instanceof Integer) {
                    element.setValueN((Integer) value);
                } else if (value instanceof Long) {
                    element.setValueN((Long) value);
                } else if (value instanceof String) {
                    element.setValueV((String) value);
                } else if (value instanceof Boolean) {
                    element.setValueN((Boolean) value ? 1 : 0);
                } else {
                    element.setValue(value);
                }
            } else {
                element.setValue(null);
            }
        }
    }
}
