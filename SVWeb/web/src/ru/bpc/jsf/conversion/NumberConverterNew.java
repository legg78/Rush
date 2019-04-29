package ru.bpc.jsf.conversion;

import java.io.Serializable;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.NumberFormat;
import java.text.ParseException;
import java.util.Locale;

import javax.el.ValueExpression;
import javax.faces.application.FacesMessage;
import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import javax.faces.convert.ConverterException;

import com.sun.faces.util.MessageFactory;
import ru.bpc.sv2.ui.utils.FacesUtils;

/**
 * <p>This is standard NumberConverter from JSF 2.0.7 without StateHolder features
 * and with some minor changes:<br> 
 * - groupingUsed = false by default,<br>
 * - decimal separator for all locales equals to '.',<br>
 * - maximum fraction digits by default equals to 100.
 * </p>
 * 
 * @author Alexeev
 *
 */
public class NumberConverterNew implements Converter, Serializable {
	private static final long serialVersionUID = 1L;
	
    /**
     * <p>The standard converter id for this converter.</p>
     */
    public static final String CONVERTER_ID = "javax.faces.NumberConverterNew";

    /**
     * <p>The message identifier of the {@link javax.faces.application.FacesMessage} to be created if
     * the conversion to <code>Number</code> fails.  The message format
     * string for this message may optionally include the following
     * placeholders:
     * <ul>
     * <li><code>{0}</code> replaced by the unconverted value.</li>
     * <li><code>{1}</code> replaced by an example value.</li>
     * <li><code>{2}</code> replaced by a <code>String</code> whose value
     * is the label of the input component that produced this message.</li>
     * </ul></p>
     */
    public static final String CURRENCY_ID =
         "javax.faces.converter.NumberConverter.CURRENCY";

    /**
     * <p>The message identifier of the {@link javax.faces.application.FacesMessage} to be created if
     * the conversion to <code>Number</code> fails.  The message format
     * string for this message may optionally include the following
     * placeholders:
     * <ul>
     * <li><code>{0}</code> replaced by the unconverted value.</li>                              HA
     * <li><code>{1}</code> replaced by an example value.</li>
     * <li><code>{2}</code> replaced by a <code>String</code> whose value
     * is the label of the input component that produced this message.</li>
     * </ul></p>
     */
    public static final String NUMBER_ID =
         "javax.faces.converter.NumberConverter.NUMBER";

    /**
     * <p>The message identifier of the {@link javax.faces.application.FacesMessage} to be created if
     * the conversion to <code>Number</code> fails.  The message format
     * string for this message may optionally include the following
     * placeholders:
     * <ul>
     * <li><code>{0}</code> replaced by the unconverted value.</li>
     * <li><code>{1}</code> replaced by an example value.</li>
     * <li><code>{2}</code> replaced by a <code>String</code> whose value
     * is the label of the input component that produced this message.</li>
     * </ul></p>
     */
    public static final String PATTERN_ID =
         "javax.faces.converter.NumberConverter.PATTERN";

    /**
     * <p>The message identifier of the {@link javax.faces.application.FacesMessage} to be created if
     * the conversion to <code>Number</code> fails.  The message format
     * string for this message may optionally include the following
     * placeholders:
     * <ul>
     * <li><code>{0}</code> replaced by the unconverted value.</li>
     * <li><code>{1}</code> replaced by an example value.</li>
     * <li><code>{2}</code> replaced by a <code>String</code> whose value
     * is the label of the input component that produced this message.</li>
     * </ul></p>
     */
    public static final String PERCENT_ID =
         "javax.faces.converter.NumberConverter.PERCENT";

    /**
     * <p>The message identifier of the {@link javax.faces.application.FacesMessage} to be created if
     * the conversion of the <code>Number</code> value to
     * <code>String</code> fails.   The message format string for this message
     * may optionally include the following placeholders:
     * <ul>
     * <li><code>{0}</code> relaced by the unconverted value.</li>
     * <li><code>{1}</code> replaced by a <code>String</code> whose value
     * is the label of the input component that produced this message.</li>
     * </ul></p>
     */
    public static final String STRING_ID =
         "javax.faces.converter.STRING";


     private static final String NBSP = "\u00a0";

    // ------------------------------------------------------ Instance Variables


    private String currencyCode = null;
    private String currencySymbol = null;
    private Boolean groupingUsed = false;
    private Boolean integerOnly = false;
    private Integer maxFractionDigits;
    private Integer maxIntegerDigits;
    private Integer minFractionDigits;
    private Integer minIntegerDigits;
    private Locale locale = null;
    private String pattern = null;
    private String type = "number";

    // -------------------------------------------------------------- Properties


    /**
     * <p>Return the ISO 4217 currency code used by <code>getAsString()</code>
     * with a <code>type</code> of <code>currency</code>.  If not set,
     * the value used will be based on the formatting <code>Locale</code>.</p>
     */
    public String getCurrencyCode() {

        return (this.currencyCode);

    }


    /**
     * <p>Set the ISO 4217 currency code used by <code>getAsString()</code>
     * with a <code>type</code> of <code>currency</code>.</p>
     *
     * @param currencyCode The new currency code
     */
    public void setCurrencyCode(String currencyCode) {

        this.currencyCode = currencyCode;

    }


    /**
     * <p>Return the currency symbol used by <code>getAsString()</code>
     * with a <code>type</code> of <code>currency</code>.  If not set,
     * the value used will be based on the formatting <code>Locale</code>.</p>
     */
    public String getCurrencySymbol() {

        return (this.currencySymbol);

    }


    /**
     * <p>Set the currency symbol used by <code>getAsString()</code>
     * with a <code>type</code> of <code>currency</code>.</p>
     *
     * @param currencySymbol The new currency symbol
     */
    public void setCurrencySymbol(String currencySymbol) {

        this.currencySymbol = currencySymbol;

    }


    /**
     * <p>Return <code>true</code> if <code>getAsString</code> should include
     * grouping separators if necessary.  If not modified, the default value
     * is <code>false</code>.</p>
     */
    public boolean isGroupingUsed() {

        return (this.groupingUsed != null ? this.groupingUsed : false);

    }


    /**
     * <p>Set the flag indicating whether <code>getAsString()</code> should
     * include grouping separators if necessary.</p>
     *
     * @param groupingUsed The new grouping used flag
     */
    public void setGroupingUsed(boolean groupingUsed) {

        this.groupingUsed = groupingUsed;

    }


    /**
     * <p>Return <code>true</code> if only the integer portion of the given
     * value should be returned from <code>getAsObject()</code>.  If not
     * modified, the default value is <code>false</code>.</p>
     */
    public boolean isIntegerOnly() {

        return (this.integerOnly != null ? this.integerOnly : false);

    }


    /**
     * <p>Set to <code>true</code> if only the integer portion of the given
     * value should be returned from <code>getAsObject()</code>.</p>
     *
     * @param integerOnly The new integer-only flag
     */
    public void setIntegerOnly(boolean integerOnly) {

        this.integerOnly = integerOnly;

    }


    /**
     * <p>Return the maximum number of digits <code>getAsString()</code> should
     * render in the fraction portion of the result.</p>
     */
    public int getMaxFractionDigits() {

        return (this.maxFractionDigits != null ? this.maxFractionDigits : 0);

    }


    /**
     * <p>Set the maximum number of digits <code>getAsString()</code> should
     * render in the fraction portion of the result.  If not set, the number of
     * digits depends on the value being converted.</p>
     *
     * @param maxFractionDigits The new limit
     */
    public void setMaxFractionDigits(int maxFractionDigits) {

        this.maxFractionDigits = maxFractionDigits;

    }


    /**
     * <p>Return the maximum number of digits <code>getAsString()</code> should
     * render in the integer portion of the result.</p>
     */
    public int getMaxIntegerDigits() {

        return (this.maxIntegerDigits != null ? this.maxIntegerDigits : 0);

    }


    /**
     * <p>Set the maximum number of digits <code>getAsString()</code> should
     * render in the integer portion of the result.  If not set, the number of
     * digits depends on the value being converted.</p>
     *
     * @param maxIntegerDigits The new limit
     */
    public void setMaxIntegerDigits(int maxIntegerDigits) {

        this.maxIntegerDigits = maxIntegerDigits;

    }


    /**
     * <p>Return the minimum number of digits <code>getAsString()</code> should
     * render in the fraction portion of the result.</p>
     */
    public int getMinFractionDigits() {

        return (this.minFractionDigits != null ? this.minFractionDigits : 0);

    }


    /**
     * <p>Set the minimum number of digits <code>getAsString()</code> should
     * render in the fraction portion of the result.  If not set, the number of
     * digits depends on the value being converted.</p>
     *
     * @param minFractionDigits The new limit
     */
    public void setMinFractionDigits(int minFractionDigits) {

        this.minFractionDigits = minFractionDigits;

    }


    /**
     * <p>Return the minimum number of digits <code>getAsString()</code> should
     * render in the integer portion of the result.</p>
     */
    public int getMinIntegerDigits() {

        return (this.minIntegerDigits != null ? this.minIntegerDigits : 0);

    }


    /**
     * <p>Set the minimum number of digits <code>getAsString()</code> should
     * render in the integer portion of the result.  If not set, the number of
     * digits depends on the value being converted.</p>
     *
     * @param minIntegerDigits The new limit
     */
    public void setMinIntegerDigits(int minIntegerDigits) {

        this.minIntegerDigits = minIntegerDigits;

    }


    /**
     * <p>Return the <code>Locale</code> to be used when parsing numbers.
     * If this value is <code>null</code>, the <code>Locale</code> stored
     * in the {@link javax.faces.component.UIViewRoot} for the current request
     * will be utilized.</p>
     */
    public Locale getLocale() {

        if (this.locale == null) {
            this.locale =
                 getLocale(FacesContext.getCurrentInstance());
        }
        return (this.locale);

    }


    /**
     * <p>Set the <code>Locale</code> to be used when parsing numbers.
     * If set to <code>null</code>, the <code>Locale</code> stored in the
     * {@link javax.faces.component.UIViewRoot} for the current request
     * will be utilized.</p>
     *
     * @param locale The new <code>Locale</code> (or <code>null</code>)
     */
    public void setLocale(Locale locale) {

        this.locale = locale;

    }


    /**
     * <p>Return the format pattern to be used when formatting and
     * parsing numbers.</p>
     */
    public String getPattern() {

        return (this.pattern);

    }


    /**
     * <p>Set the format pattern to be used when formatting and parsing
     * numbers.  Valid values are those supported by
     * <code>java.text.DecimalFormat</code>.
     * An invalid value will cause a {@link ConverterException} when
     * <code>getAsObject()</code> or <code>getAsString()</code> is called.</p>
     *
     * @param pattern The new format pattern
     */
    public void setPattern(String pattern) {

        this.pattern = pattern;

    }


    /**
     * <p>Return the number type to be used when formatting and parsing numbers.
     * If not modified, the default type is <code>number</code>.</p>
     */
    public String getType() {

        return (this.type);

    }


    /**
     * <p>Set the number type to be used when formatting and parsing numbers.
     * Valid values are <code>currency</code>, <code>number</code>, or
     * <code>percent</code>.
     * An invalid value will cause a {@link ConverterException} when
     * <code>getAsObject()</code> or <code>getAsString()</code> is called.</p>
     *
     * @param type The new number style
     */
    public void setType(String type) {

        this.type = type;

    }

    // ------------------------------------------------------- Converter Methods

    /**
     * @throws ConverterException   {@inheritDoc}
     * @throws NullPointerException {@inheritDoc}
     */
    public Object getAsObject(FacesContext context, UIComponent component,
                              String value) {

        if (context == null || component == null) {
            throw new NullPointerException();
        }

        Object returnValue = null;
        NumberFormat parser = null;

        try {

            // If the specified value is null or zero-length, return null
            if (value == null) {
                return (null);
            }
            value = value.trim();
            if (value.length() < 1) {
                return (null);
            }

            // Identify the Locale to use for parsing
            Locale locale = getLocale(context);

            // Create and configure the parser to be used
            parser = getNumberFormat(locale);
            if (((pattern != null) && pattern.length() != 0)
                 || "currency".equals(type)) {
                configureCurrency(parser);
            }
            parser.setParseIntegerOnly(isIntegerOnly());
            boolean groupSepChanged = false;
            // BEGIN HACK 4510618
            // This lovely bit of code is for a workaround in some
            // oddities in the JDK's parsing code.
            // See:  http://bugs.sun.com/view_bug.do?bug_id=4510618
            if (parser instanceof DecimalFormat) {
                DecimalFormat dParser = (DecimalFormat) parser;

                // Take a small hit in performance to avoid a loss in
                // precision due to DecimalFormat.parse() returning Double
                ValueExpression ve = component.getValueExpression("value");
                if (ve != null) {
                    Class<?> expectedType = ve.getType(context.getELContext());
                    if (expectedType.isAssignableFrom(BigDecimal.class)) {
                        dParser.setParseBigDecimal(true);
                    }
                }
                DecimalFormatSymbols symbols =
                      dParser.getDecimalFormatSymbols();
                symbols.setDecimalSeparator('.');	// as we substitute ',' with '.' on client side
                if (symbols.getGroupingSeparator() == '\u00a0') {
                    groupSepChanged = true;
                    String tValue;
                    if (value.contains(NBSP)) {
                        tValue = value.replace('\u00a0', ' ');
                    } else {
                        tValue = value;
                    }
                    symbols.setGroupingSeparator(' ');
                    dParser.setDecimalFormatSymbols(symbols);
                    try {
                        return dParser.parse(tValue);
                    } catch (ParseException pe) {
                        if (groupSepChanged) {
                            symbols.setGroupingSeparator('\u00a0');
                            dParser.setDecimalFormatSymbols(symbols);
                        }
                    }
                }
            }

            char separator = ((DecimalFormat) parser).getDecimalFormatSymbols().getDecimalSeparator();
            int cian = value.indexOf(separator);
            String cianV = (cian>0) ? value.substring(0,cian) : value;
            if(isMaxIntegerDigitsSet() && maxIntegerDigits < cianV.length()){
                String label = getCompositeAttribute(component, "label");
                String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "int_part_too_big", label,
                        maxIntegerDigits);
                FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
                context.addMessage(component.getClientId(context), message);
                throw new Exception(msg);
            }

            // END HACK 4510618

            // Perform the requested parsing
            returnValue = parser.parse(value);
        } catch (ParseException e) {
            if (pattern != null) {
                throw new ConverterException(MessageFactory.getMessage(
                     context, PATTERN_ID, value, "#,##0.0#",
                     MessageFactory.getLabel(context, component)), e);
            } else if (type.equals("currency")) {
                throw new ConverterException(MessageFactory.getMessage(
                     context, CURRENCY_ID, value,
                     parser.format(99.99),
                     MessageFactory.getLabel(context, component)), e);
            } else if (type.equals("number")) {
                throw new ConverterException(MessageFactory.getMessage(
                     context, NUMBER_ID, value,
                     parser.format(99),
                     MessageFactory.getLabel(context, component)), e);
            } else if (type.equals("percent")) {
                throw new ConverterException(MessageFactory.getMessage(
                     context, PERCENT_ID, value,
                     parser.format(.75),
                     MessageFactory.getLabel(context, component)), e);
            }
        } catch (Exception e) {
            throw new ConverterException(e);
        }
        return returnValue;
    }

    private String getCompositeAttribute(javax.faces.component.UIComponent component, String name) {
        Object obj = component.getAttributes().get(name);
        if(obj == null){
            return null;
        }
        return obj.toString();
    }

    /**
     * @throws ConverterException   {@inheritDoc}
     * @throws NullPointerException {@inheritDoc}
     */
    public String getAsString(FacesContext context, UIComponent component,
                              Object value) {

        if (context == null || component == null) {
            throw new NullPointerException();
        }

        try {

            // If the specified value is null, return a zero-length String
            if (value == null) {
                return "";
            }

            // If the incoming value is still a string, play nice
            // and return the value unmodified
            if (value instanceof String) {
                return (String) value;
            }

            if ("currency".equals(type)) {
                if (value instanceof BigDecimal) {
                    if (isMinFractionDigitsSet()) {
                        BigDecimal bd = (BigDecimal) value;
                        BigDecimal exp = new BigDecimal(Math.pow(10.0, (double) getMinFractionDigits()));
                        value = bd.divide(exp, 2, RoundingMode.HALF_UP);
                    }
                }
            }

            // Identify the Locale to use for formatting
            Locale locale = getLocale(context);

            // Create and configure the formatter to be used
            NumberFormat formatter =
                 getNumberFormat(locale);
            if (((pattern != null) && pattern.length() != 0)
                 || "currency".equals(type)) {
                configureCurrency(formatter);
            }
            configureFormatter(formatter);
            
            // substitute decimal separator with '.'
            if (formatter instanceof DecimalFormat) {
            	DecimalFormatSymbols symbols = ((DecimalFormat) formatter).getDecimalFormatSymbols();
            	symbols.setDecimalSeparator('.');
            	((DecimalFormat) formatter).setDecimalFormatSymbols(symbols);
            }
            // Perform the requested formatting
            return (formatter.format(value));

        } catch (ConverterException e) {
            throw new ConverterException(MessageFactory.getMessage(
                 context, STRING_ID, value,
                 MessageFactory.getLabel(context, component)), e);
        } catch (Exception e) {
            throw new ConverterException(MessageFactory.getMessage(
                 context, STRING_ID, value,
                 MessageFactory.getLabel(context, component)), e);
        }
    }

    // --------------------------------------------------------- Private Methods


    private static Class currencyClass;

    static {
        try {
            currencyClass = Class.forName("java.util.Currency");
            // container's runtime is J2SE 1.4 or greater
        } catch (Exception ignored) {
        }
    }

    private static final Class[] GET_INSTANCE_PARAM_TYPES =
         new Class[]{String.class};


    /**
     * <p/>
     * Override the formatting locale's default currency symbol with the
     * specified currency code (specified via the "currencyCode" attribute) or
     * currency symbol (specified via the "currencySymbol" attribute).</p>
     * <p/>
     * <p>If both "currencyCode" and "currencySymbol" are present,
     * "currencyCode" takes precedence over "currencySymbol" if the
     * java.util.Currency class is defined in the container's runtime (that
     * is, if the container's runtime is J2SE 1.4 or greater), and
     * "currencySymbol" takes precendence over "currencyCode" otherwise.</p>
     * <p/>
     * <p>If only "currencyCode" is given, it is used as a currency symbol if
     * java.util.Currency is not defined.</p>
     * <pre>
     * Example:
     * <p/>
     * JDK    "currencyCode" "currencySymbol" Currency symbol being displayed
     * -----------------------------------------------------------------------
     * all         ---            ---         Locale's default currency symbol
     * <p/>
     * <1.4        EUR            ---         EUR
     * >=1.4       EUR            ---         Locale's currency symbol for Euro
     * <p/>
     * all         ---           \u20AC       \u20AC
     * <p/>
     * <1.4        EUR           \u20AC       \u20AC
     * >=1.4       EUR           \u20AC       Locale's currency symbol for Euro
     * </pre>
     *
     * @param formatter The <code>NumberFormatter</code> to be configured
     */
    private void configureCurrency(NumberFormat formatter) throws Exception {

        // Implementation copied from JSTL's FormatNumberSupport.setCurrency()

        String code = null;
        String symbol = null;

        if ((currencyCode == null) && (currencySymbol == null)) {
            return;
        }

        if ((currencyCode != null) && (currencySymbol != null)) {
            if (currencyClass != null)
                code = currencyCode;
            else
                symbol = currencySymbol;
        } else if (currencyCode == null) {
            symbol = currencySymbol;
        } else {
            if (currencyClass != null)
                code = currencyCode;
            else
                symbol = currencyCode;
        }

        if (code != null) {
            Object[] methodArgs = new Object[1];

            /*
            * java.util.Currency.getInstance()
            */
            Method m = currencyClass.getMethod("getInstance",
                 GET_INSTANCE_PARAM_TYPES);
            methodArgs[0] = code;
            Object currency = m.invoke(null, methodArgs);

            /*
            * java.text.NumberFormat.setCurrency()
            */
            Class[] paramTypes = new Class[1];
            paramTypes[0] = currencyClass;
            Class numberFormatClass = Class.forName("java.text.NumberFormat");
            m = numberFormatClass.getMethod("setCurrency", paramTypes);
            methodArgs[0] = currency;
            m.invoke(formatter, methodArgs);
        } else {
            /*
            * Let potential ClassCastException propagate up (will almost
            * never happen)
            */
            DecimalFormat df = (DecimalFormat) formatter;
            DecimalFormatSymbols dfs = df.getDecimalFormatSymbols();
            dfs.setCurrencySymbol(symbol);
            df.setDecimalFormatSymbols(dfs);
        }

    }


    /**
     * <p>Configure the specified <code>NumberFormat</code> based on the
     * formatting properties that have been set.</p>
     *
     * @param formatter The <code>NumberFormat</code> instance to configure
     */
    private void configureFormatter(NumberFormat formatter) {

        formatter.setGroupingUsed(groupingUsed);
        if (isMaxIntegerDigitsSet()) {
            formatter.setMaximumIntegerDigits(maxIntegerDigits);
        }
        if (isMinIntegerDigitsSet()) {
            formatter.setMinimumIntegerDigits(minIntegerDigits);
        }
        if (isMaxFractionDigitsSet()) {
            formatter.setMaximumFractionDigits(maxFractionDigits);
        } else {
        	formatter.setMaximumFractionDigits(100);	// default value of "3" is not enough i suppose  
        }
        if (isMinFractionDigitsSet()) {
            formatter.setMinimumFractionDigits(minFractionDigits);
        }

    }


    private boolean isMaxIntegerDigitsSet() {

        return (maxIntegerDigits != null);

    }


    private boolean isMinIntegerDigitsSet() {

        return (minIntegerDigits != null);

    }


    private boolean isMaxFractionDigitsSet() {

        return (maxFractionDigits != null);

    }


    private boolean isMinFractionDigitsSet() {

        return (minFractionDigits != null);

    }


    /**
     * <p>Return the <code>Locale</code> we will use for localizing our
     * formatting and parsing processing.</p>
     *
     * @param context The {@link FacesContext} for the current request
     */
    private Locale getLocale(FacesContext context) {

        // PENDING(craigmcc) - JSTL localization context?
        Locale locale = this.locale;
        if (locale == null) {
            locale = context.getViewRoot().getLocale();
        }
        return (locale);

    }


    /**
     * <p>Return a <code>NumberFormat</code> instance to use for formatting
     * and parsing in this {@link Converter}.</p>
     *
     * @param locale The <code>Locale</code> used to select formatting
     *               and parsing conventions
     * @throws ConverterException if no instance can be created
     */
    private NumberFormat getNumberFormat(Locale locale) {

        if (pattern == null && type == null) {
            throw new IllegalArgumentException("Either pattern or type must" +
                 " be specified.");
        }

        // PENDING(craigmcc) - Implement pooling if needed for performance?

        // If pattern is specified, type is ignored
        if (pattern != null) {
            DecimalFormatSymbols symbols = new DecimalFormatSymbols(locale);
            return (new DecimalFormat(pattern, symbols));
        }

        // Create an instance based on the specified type
        else if (type.equals("currency")) {
            return (NumberFormat.getCurrencyInstance(locale));
        } else if (type.equals("number")) {
            return (NumberFormat.getNumberInstance(locale));
        } else if (type.equals("percent")) {
            return (NumberFormat.getPercentInstance(locale));
        } else {
            // PENDING(craigmcc) - i18n
            throw new ConverterException
                 (new IllegalArgumentException(type));
        }


    }

}
