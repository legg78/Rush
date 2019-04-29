package ru.bpc.jsf.conversion;

import java.io.Serializable;
import java.math.BigDecimal;
import java.text.DecimalFormat;

import javax.faces.application.FacesMessage;
import javax.faces.component.UIComponent;
import javax.faces.component.html.HtmlInputText;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;

import ru.bpc.sv2.ui.utils.FacesUtils;

/**
 * <p>
 * To use instead of standard <code>&lt;f:convertNumber></code> which doesn't
 * work correctly with big numbers for some reason.
 * </p>
 * <p>
 * When used for output then standard <code>&lt;f:convertNumber</code>'s
 * behavior is used, i.e. if integer part exceeds <code>maxIntegerDigits</code>
 * first digits will be removed to fit the desired length, if fractional part
 * exceeds <code>maxFractionDigits</code> then last digits will be removed. Same
 * for minimum limits: if integer part is not long enough then it's supplemented
 * by zeroes from ahead, if fractional part is not long enough it's supplemented
 * by zeroes from tail.
 * </p>
 * 
 * @author Alexeev 
 * TODO: add parameter to select action when minimum condition is not met: 
 * whether to append zeroes automatically (as it's done in f:convertNumber) or 
 * to show error (as it's done now); add other parameters from f:convertNumber, 
 * make it more i18n-able
 */
public class BigDecimalConverter implements Converter, Serializable {
	private static final long serialVersionUID = 1L;

	public static final String EXCEED_ERROR = "error"; // show error if value exceeds limit
	public static final String EXCEED_TRIM_FIRST = "trimFirst"; // trim first numbers if value exceeds limit
	public static final String EXCEED_TRIM_LAST = "trimLast"; // trim last numbers if value exceeds limit

	// these are properties from message budle "msg" 
	private static final String INT_PART_TOO_BIG = "int_part_too_big";
	private static final String FRACTION_PART_TOO_BIG = "fraction_part_too_big";
	private static final String INT_PART_TOO_SMALL = "int_part_too_small";
	private static final String FRACTION_PART_TOO_SMALL = "fraction_part_too_small";
	private static final String INT_PART_OUTSIDE_RANGE = "int_part_outside_range";
	private static final String FRACTION_PART_OUTSIDE_RANGE = "fraction_part_outside_range";

	private Integer maxFractionDigits;
	private Integer maxIntegerDigits;
	private Integer minFractionDigits;
	private Integer minIntegerDigits;
	private String intExceedAction;
	private String fractionExceedAction;

	public Object getAsObject(FacesContext context, UIComponent component, String value) {
		if (value == null || value.trim().length() == 0) {
			return null;
		}

		value = value.trim();
		if (!value.matches("^[-+]?[0-9]*\\.?[0-9]+$")) {
			((HtmlInputText) component).setValid(false);

			String label = ((HtmlInputText) component).getLabel() != null ? ((HtmlInputText) component)
					.getLabel() : ((HtmlInputText) component).getId();
			String msg = FacesUtils
					.getMessage("ru.bpc.sv2.ui.bundles.Msg", "must_be_number", label);
			FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
			context.addMessage(component.getClientId(context), message);
			return null;
		}

		if (maxIntegerDigits != null || maxFractionDigits != null || minIntegerDigits != null
				|| minFractionDigits != null) {
			if (intExceedAction == null) {
				intExceedAction = EXCEED_ERROR;
			}
			if (fractionExceedAction == null) {
				// this is the default behaviour for maxFractionDigits of <f:convertNumber>
				fractionExceedAction = EXCEED_TRIM_LAST;
			}

			try {
				value = composeValue(value, component, intExceedAction, fractionExceedAction, true);
			} catch (Exception e) {
				((HtmlInputText) component).setValid(false);

				String label = ((HtmlInputText) component).getLabel() != null ? ((HtmlInputText) component)
						.getLabel() : ((HtmlInputText) component).getId();
				String msg = "";

				if (INT_PART_TOO_BIG.equals(e.getMessage())) {
					msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", e.getMessage(), label,
							maxIntegerDigits);
				} else if (FRACTION_PART_TOO_BIG.equals(e.getMessage())) {
					msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", e.getMessage(), label,
							maxFractionDigits);
				} else if (INT_PART_TOO_SMALL.equals(e.getMessage())) {
					msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", e.getMessage(), label,
							minIntegerDigits);
				} else if (FRACTION_PART_TOO_SMALL.equals(e.getMessage())) {
					msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", e.getMessage(), label,
							minFractionDigits);
				} else if (INT_PART_OUTSIDE_RANGE.equals(e.getMessage())) {
					msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", e.getMessage(), label,
							minIntegerDigits, maxIntegerDigits);
				} else if (FRACTION_PART_OUTSIDE_RANGE.equals(e.getMessage())) {
					msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", e.getMessage(), label,
							minFractionDigits, maxFractionDigits);
				} else {
					FacesUtils.addMessageError(e);
					return null;
				}
				FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
				context.addMessage(component.getClientId(context), message);
				return null;
			}
		}
		return new BigDecimal(value);
	}

	public String getAsString(FacesContext context, UIComponent component, Object value) {
		if (value == null) {
			return "";
		}

		String valueStr = "";
		if (value instanceof BigDecimal) {
			valueStr = ((BigDecimal) value).toPlainString();
		} else {
			// get normal number without scientific notation
			DecimalFormat df = new DecimalFormat();
			df.setGroupingUsed(false); // to get "clean" number
			valueStr = df.format(value);

			// replace comma (if locale uses comma to separate decimal part)
			// to dot as currently we work with dots only
			valueStr = valueStr.replace(',', '.');
		}

		if (maxIntegerDigits != null || maxFractionDigits != null || minIntegerDigits != null
				|| minFractionDigits != null) {
			String intAction = intExceedAction;
			String fractionAction = fractionExceedAction;
			if (intExceedAction == null || EXCEED_ERROR.equalsIgnoreCase(intExceedAction)) {
				// showing error in output mode doesn't make sense so it's better to 
				// use the default behaviour for maxIntegerDigits of <f:convertNumber>
				intAction = EXCEED_TRIM_FIRST;
			}
			if (fractionExceedAction == null || EXCEED_ERROR.equalsIgnoreCase(fractionExceedAction)) {
				// showing error in output mode doesn't make sense so it's better to 
				// use the default behaviour for maxFractionDigits of <f:convertNumber>
				fractionAction = EXCEED_TRIM_LAST;
			}

			try {
				valueStr = composeValue(valueStr, component, intAction, fractionAction, false);
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				return "";
			}
		}

		return valueStr;
	}

	private String composeValue(String value, UIComponent component, String intExceedAction,
			String fractionExceedAction, boolean isInput) throws Exception {

		String intPart = "";
		String fractionPart = "";
		String signPart = "";

		if (maxIntegerDigits != null || minIntegerDigits != null) {
			if (value.startsWith("+") || value.startsWith("-")) {
				signPart = value.substring(0, 1);
				value = value.substring(1);
			}
			if (value.indexOf('.') >= 0) {
				intPart = value.substring(0, value.indexOf('.'));
				fractionPart = value.substring(value.indexOf('.') + 1);
			} else {
				intPart = value;
			}
			if (maxIntegerDigits != null && intPart.length() > maxIntegerDigits) {
				if (EXCEED_ERROR.equalsIgnoreCase(intExceedAction)) {
					if (minIntegerDigits != null) {
						throw new Exception(INT_PART_OUTSIDE_RANGE);
					} else {
						throw new Exception(INT_PART_TOO_BIG);
					}
				} else if (EXCEED_TRIM_FIRST.equalsIgnoreCase(intExceedAction)) {
					intPart = intPart.substring(intPart.length() - maxIntegerDigits);
				} else if (EXCEED_TRIM_LAST.equalsIgnoreCase(intExceedAction)) {
					intPart = intPart.substring(0, maxIntegerDigits);
				}
			} else if (minIntegerDigits != null && intPart.length() < minIntegerDigits) {
				if (isInput) {
					if (maxIntegerDigits != null) {
						throw new Exception(INT_PART_OUTSIDE_RANGE);
					} else {
						throw new Exception(INT_PART_TOO_SMALL);
					}
				} else {
					intPart = fillToMinimum(intPart, minIntegerDigits, false);
				}
			}
		}
		if (maxFractionDigits != null || minFractionDigits != null) {
			if (maxIntegerDigits == null && minIntegerDigits == null && value.indexOf('.') >= 0) {
				// we need both parts anyway
				intPart = value.substring(0, value.indexOf('.'));
				fractionPart = value.substring(value.indexOf('.') + 1);
			}
			if (maxFractionDigits != null && fractionPart.length() > maxFractionDigits) {
				if (EXCEED_ERROR.equalsIgnoreCase(fractionExceedAction)) {
					if (minFractionDigits != null) {
						throw new Exception(FRACTION_PART_OUTSIDE_RANGE);
					} else {
						throw new Exception(FRACTION_PART_TOO_BIG);
					}
				} else if (EXCEED_TRIM_FIRST.equalsIgnoreCase(fractionExceedAction)) {
					fractionPart = fractionPart
							.substring(fractionPart.length() - maxFractionDigits);
				} else if (EXCEED_TRIM_LAST.equalsIgnoreCase(fractionExceedAction)) {
					fractionPart = fractionPart.substring(0, maxFractionDigits);
				}
			} else if (minFractionDigits != null && fractionPart.length() < minFractionDigits) {
				if (isInput) {
					if (maxFractionDigits != null) {
						throw new Exception(FRACTION_PART_OUTSIDE_RANGE);
					} else {
						throw new Exception(FRACTION_PART_TOO_SMALL);
					}
				} else {
					fractionPart = fillToMinimum(fractionPart, minFractionDigits, true);
				}
			}
		}

		if (maxIntegerDigits != null
				|| minIntegerDigits != null
				|| ((maxFractionDigits != null || minFractionDigits != null) && value.indexOf('.') >= 0)) {
			intPart = intPart.length() == 0 ? "0" : intPart;
			fractionPart = fractionPart.length() == 0 ? "" : ("." + fractionPart);
			value = signPart + intPart + fractionPart;
		}

		return value;
	}

	private String fillToMinimum(String value, Integer limit, boolean addToTail) {
		for (int i = value.length(); i < limit; i++) {
			if (addToTail) {
				value += "0";
			} else {
				value = "0" + value;
			}
		}
		return value;
	}

	public Integer getMaxFractionDigits() {
		return maxFractionDigits;
	}

	public void setMaxFractionDigits(Integer maxFractionDigits) {
		this.maxFractionDigits = maxFractionDigits;
	}

	public Integer getMaxIntegerDigits() {
		return maxIntegerDigits;
	}

	public void setMaxIntegerDigits(Integer maxIntegerDigits) {
		this.maxIntegerDigits = maxIntegerDigits;
	}

	public Integer getMinFractionDigits() {
		return minFractionDigits;
	}

	public void setMinFractionDigits(Integer minFractionDigits) {
		this.minFractionDigits = minFractionDigits;
	}

	public Integer getMinIntegerDigits() {
		return minIntegerDigits;
	}

	public void setMinIntegerDigits(Integer minIntegerDigits) {
		this.minIntegerDigits = minIntegerDigits;
	}

	public String getIntExceedAction() {
		return intExceedAction;
	}

	public void setIntExceedAction(String intExceedAction) {
		this.intExceedAction = intExceedAction;
	}

	public String getFractionExceedAction() {
		return fractionExceedAction;
	}

	public void setFractionExceedAction(String fractionExceedAction) {
		this.fractionExceedAction = fractionExceedAction;
	}
}
