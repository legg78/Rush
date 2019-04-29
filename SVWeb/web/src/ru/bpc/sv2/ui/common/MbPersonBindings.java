package ru.bpc.sv2.ui.common;

import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.component.UIComponent;
import javax.faces.component.html.HtmlInputText;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import javax.faces.convert.ConverterException;

import ru.bpc.sv2.ui.utils.FacesUtils;

/**
 * <p>This class is a work-around of JSF's problem with binding. Quote
 * from richfaces FAQ:</p>
 * <p>"Object which holds components bindings should not live longer 
 * than request. It's not defined directly in JSF 1.2 specification but 
 * speciication specifies that view should be rebuilt on each requests. 
 * Different problem will occurs if you trying session scoped bindings 
 * - duplicate id's as most popular problem, concurrent calls to 
 * components in session and so on...</p>
 * <p><b>keepAlive and Object which holds bindings</b></p>
 * <p>Such usage will have even worst results..."</p>
 * <p>As i can't submit several forms (due to HTML restrictions) 
 * mandatory fields can't be checked automatically, so i have to check 
 * them manually. Therefore to show user which field has a problem i 
 * had to bind mandatory fields to objects that are stored here. But 
 * all our managed beans has a4j:keepAlive tag that causes duplicate 
 * ids problem mentioned above. So i moved these bindings to separate 
 * bean (i.e. this class) that has pure request scope.</p>  
 * @author Alexeev
 *
 */
@RequestScoped
@ManagedBean (name = "MbPersonBindings")
public class MbPersonBindings {
	private HtmlInputText nameInput;
	private HtmlInputText surnameInput;

	public HtmlInputText getNameInput() {
		return nameInput;
	}

	public void setNameInput(HtmlInputText nameInput) {
		this.nameInput = nameInput;
	}

	public HtmlInputText getSurnameInput() {
		return surnameInput;
	}

	public void setSurnameInput(HtmlInputText surnameInput) {
		this.surnameInput = surnameInput;
	}

	public Converter getConvert() {
		return new Converter() {

			@Override
			public Object getAsObject(FacesContext context, UIComponent component,
					String newValue) throws ConverterException {
//				System.out.println("---===Entered Converter.getAsObject()===---");
				if (newValue == null || newValue.trim().length() < 1) {
//					System.out.println("---===Converter.getAsObject() newValue is NULL===---");

					String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
							"javax.faces.component.UIInput.REQUIRED", ((HtmlInputText) component).getLabel());
			        FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
			        FacesContext.getCurrentInstance().addMessage(
			        		component.getClientId(FacesContext.getCurrentInstance()), message);
				}
				return newValue;
			}

			@Override
			public String getAsString(FacesContext context, UIComponent component,
					Object newValue) throws ConverterException {
//				System.out.println("---===Entered Converter.getAsString()===---");
				if (newValue == null) {
//					System.out.println("---===Converter.getAsString() newValue is NULL===---");
					newValue = "";
				}
				return newValue.toString();
			}
			
		};
	}
}
