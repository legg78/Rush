package ru.bpc.jsf.taglib;

import com.sun.facelets.tag.AbstractTagLibrary;
import com.sun.facelets.tag.jsf.core.*;

import javax.faces.component.UIParameter;
import javax.faces.component.UISelectItem;
import javax.faces.component.UISelectItems;
import javax.faces.convert.DateTimeConverter;
import javax.faces.convert.NumberConverter;
import javax.faces.validator.DoubleRangeValidator;
import javax.faces.validator.LengthValidator;
import javax.faces.validator.LongRangeValidator;

/**
 * Created by Perminov on 03.08.2016.
 */
public class CoreLibraryEx extends AbstractTagLibrary {
	public final static String Namespace = "http://java.sun.com/jsf/core";

	public final static CoreLibraryEx Instance = new CoreLibraryEx();

	public CoreLibraryEx() {
		super(Namespace);

		this.addTagHandler("actionListener", ActionListenerHandler.class);

		this.addTagHandler("attribute", AttributeHandler.class);

		this.addConverter("convertDateTime", DateTimeConverter.CONVERTER_ID, ConvertDateTimeHandler.class);

		this.addConverter("convertNumber", NumberConverter.CONVERTER_ID, ConvertNumberHandler.class);

		this.addConverter("converter", null, ConvertDelegateHandler.class);

		this.addTagHandler("facet", FacetHandler.class);

		this.addTagHandler("loadBundle", LoadBundleHandler.class);

		this.addComponent("param", UIParameter.COMPONENT_TYPE, null);

		this.addTagHandler("phaseListener", PhaseListenerHandler.class);

		this.addComponent("selectItem", UISelectItem.COMPONENT_TYPE, null);

		this.addComponent("selectItems", UISelectItems.COMPONENT_TYPE, null);

		this.addTagHandler("setPropertyActionListener", SetPropertyActionListenerHandler.class);

		this.addComponent("subview", "javax.faces.NamingContainer", null);

		this.addValidator("validateLength", LengthValidator.VALIDATOR_ID);

		this.addValidator("validateLongRange", LongRangeValidator.VALIDATOR_ID);

		this.addValidator("validateDoubleRange", DoubleRangeValidator.VALIDATOR_ID);

		this.addValidator("validator", null, ValidateDelegateHandler.class);

		this.addTagHandler("valueChangeListener", ValueChangeListenerHandler.class);

		this.addTagHandler("view", ViewHandler.class);

		this.addComponent("verbatim", "javax.faces.HtmlOutputText", "javax.faces.Text", VerbatimHandler.class);

		this.addTagHandler("event", EventHandler.class);

		this.addTagHandler("metadata", MetadataHandler.class);
	}
}
