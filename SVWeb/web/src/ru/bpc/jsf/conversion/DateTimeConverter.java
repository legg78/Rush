package ru.bpc.jsf.conversion;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import javax.faces.convert.ConverterException;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

public class DateTimeConverter extends javax.faces.convert.DateTimeConverter {

	private static final TimeZone DEFAULT_TIME_ZONE = TimeZone.getTimeZone("GMT");

	private String dateStyle = "default";
	private Locale locale = null;
	private String pattern = null;
	private String timeStyle = "default";
	private TimeZone timeZone = DEFAULT_TIME_ZONE;
	private String type = "date";

	public String getDateStyle() {
		return (this.dateStyle);
	}


	/**
	 * <p>Set the style to be used to format or parse dates.  Valid values
	 * are <code>default</code>, <code>short</code>, <code>medium</code>,
	 * <code>long</code>, and <code>full</code>.
	 * An invalid value will cause a {@link ConverterException} when
	 * <code>getAsObject()</code> or <code>getAsString()</code> is called.</p>
	 *
	 * @param dateStyle The new style code
	 */
	public void setDateStyle(String dateStyle) {
		clearInitialState();
		this.dateStyle = dateStyle;
	}

	/**
	 * <p>Return the <code>Locale</code> to be used when parsing or formatting
	 * dates and times. If not explicitly set, the <code>Locale</code> stored
	 * in the {@link javax.faces.component.UIViewRoot} for the current
	 * request is returned.</p>
	 */
	public Locale getLocale() {
		if (this.locale == null) {
			this.locale =
					getLocale(FacesContext.getCurrentInstance());
		}
		return (this.locale);
	}

	/**
	 * <p>Set the <code>Locale</code> to be used when parsing or formatting
	 * dates and times.  If set to <code>null</code>, the <code>Locale</code>
	 * stored in the {@link javax.faces.component.UIViewRoot} for the current
	 * request will be utilized.</p>
	 *
	 * @param locale The new <code>Locale</code> (or <code>null</code>)
	 */
	public void setLocale(Locale locale) {
		clearInitialState();
		this.locale = locale;
	}

	/**
	 * <p>Return the format pattern to be used when formatting and
	 * parsing dates and times.</p>
	 */
	public String getPattern() {
		return (this.pattern);
	}

	/**
	 * <p>Set the format pattern to be used when formatting and parsing
	 * dates and times.  Valid values are those supported by
	 * <code>java.text.SimpleDateFormat</code>.
	 * An invalid value will cause a {@link ConverterException} when
	 * <code>getAsObject()</code> or <code>getAsString()</code> is called.</p>
	 *
	 * @param pattern The new format pattern
	 */
	public void setPattern(String pattern) {
		clearInitialState();
		this.pattern = pattern;
	}

	/**
	 * <p>Return the style to be used to format or parse times.  If not set,
	 * the default value, <code>default</code>, is returned.</p>
	 */
	public String getTimeStyle() {
		return (this.timeStyle);
	}


	/**
	 * <p>Set the style to be used to format or parse times.  Valid values
	 * are <code>default</code>, <code>short</code>, <code>medium</code>,
	 * <code>long</code>, and <code>full</code>.
	 * An invalid value will cause a {@link ConverterException} when
	 * <code>getAsObject()</code> or <code>getAsString()</code> is called.</p>
	 *
	 * @param timeStyle The new style code
	 */
	public void setTimeStyle(String timeStyle) {
		clearInitialState();
		this.timeStyle = timeStyle;
	}

	/**
	 * <p>Return the <code>TimeZone</code> used to interpret a time value.
	 * If not explicitly set, the default time zone of <code>GMT</code>
	 * returned.</p>
	 */
	public TimeZone getTimeZone() {
		return (this.timeZone);
	}

	/**
	 * <p>Set the <code>TimeZone</code> used to interpret a time value.</p>
	 *
	 * @param timeZone The new time zone
	 */
	public void setTimeZone(TimeZone timeZone) {
		clearInitialState();
		this.timeZone = timeZone;
	}

	/**
	 * <p>Return the type of value to be formatted or parsed.
	 * If not explicitly set, the default type, <code>date</code>
	 * is returned.</p>
	 */
	public String getType() {
		return (this.type);
	}


	/**
	 * <p>Set the type of value to be formatted or parsed.
	 * Valid values are <code>both</code>, <code>date</code>, or
	 * <code>time</code>.
	 * An invalid value will cause a {@link ConverterException} when
	 * <code>getAsObject()</code> or <code>getAsString()</code> is called.</p>
	 *
	 * @param type The new date style
	 */
	public void setType(String type) {
		clearInitialState();
		this.type = type;
	}

	public Object getAsObject(FacesContext context, UIComponent component, String value) {
		if (context == null || component == null) {
			throw new NullPointerException();
		}

		Object returnValue = null;
		DateFormat parser = null;

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
			parser = getDateFormat(locale);
			if (null != timeZone) {
				parser.setTimeZone(timeZone);
			}

			// Perform the requested parsing
			returnValue = parser.parse(value);
		} catch (ParseException e) {
			if ("date".equals(type)) {
				throw new ConverterException(MessageFactory.getMessage(
						context, DATE_ID, value,
						parser.format(new Date(System.currentTimeMillis())),
						MessageFactory.getLabel(context, component)), e);
			} else if ("time".equals(type)) {
				throw new ConverterException(MessageFactory.getMessage(
						context, TIME_ID, value,
						parser.format(new Date(System.currentTimeMillis())),
						MessageFactory.getLabel(context, component)), e);
			} else if ("both".equals(type)) {
				throw new ConverterException(MessageFactory.getMessage(
						context, DATETIME_ID, value,
						parser.format(new Date(System.currentTimeMillis())),
						MessageFactory.getLabel(context, component)), e);
			}
		} catch (Exception e) {
			throw new ConverterException(e);
		}
		return returnValue;
	}

	public String getAsString(FacesContext context, UIComponent component, Object value) {

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

			// Identify the Locale to use for formatting
			Locale locale = getLocale(context);

			// Create and configure the formatter to be used
			DateFormat formatter = getDateFormat(locale);
			if (null != timeZone) {
				formatter.setTimeZone(timeZone);
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

	/**
	 * <p>Return a <code>DateFormat</code> instance to use for formatting
	 * and parsing in this {@link Converter}.</p>
	 *
	 * @param locale The <code>Locale</code> used to select formatting
	 *               and parsing conventions
	 * @throws ConverterException if no instance can be created
	 */
	private DateFormat getDateFormat(Locale locale) {

		// PENDING(craigmcc) - Implement pooling if needed for performance?

		if (pattern == null && type == null) {
			throw new IllegalArgumentException("Either pattern or type must" +
					" be specified.");
		}

		DateFormat df;
		if (pattern != null) {
			df = new SimpleDateFormat(pattern, locale);
		} else if (type.equals("both")) {
			df = DateFormat.getDateTimeInstance
					(getStyle(dateStyle), getStyle(timeStyle), locale);
		} else if (type.equals("date")) {
			df = DateFormat.getDateInstance(getStyle(dateStyle), locale);
		} else if (type.equals("time")) {
			df = DateFormat.getTimeInstance(getStyle(timeStyle), locale);
		} else {
			// PENDING(craigmcc) - i18n
			throw new IllegalArgumentException("Invalid type: " + type);
		}
		df.setLenient(true);
		return (df);

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
	 * <p>Return the style constant for the specified style name.</p>
	 *
	 * @param name Name of the style for which to return a constant
	 * @throws ConverterException if the style name is not valid
	 */
	private static int getStyle(String name) {

		if ("default".equals(name)) {
			return (DateFormat.DEFAULT);
		} else if ("short".equals(name)) {
			return (DateFormat.SHORT);
		} else if ("medium".equals(name)) {
			return (DateFormat.MEDIUM);
		} else if ("long".equals(name)) {
			return (DateFormat.LONG);
		} else if ("full".equals(name)) {
			return (DateFormat.FULL);
		} else {
			// PENDING(craigmcc) - i18n
			throw new ConverterException("Invalid style '" + name + '\'');
		}

	}

	// ----------------------------------------------------- StateHolder Methods


	public Object saveState(FacesContext context) {

		if (context == null) {
			throw new NullPointerException();
		}
		if (!initialStateMarked()) {
			Object values[] = new Object[6];
			values[0] = dateStyle;
			values[1] = locale;
			values[2] = pattern;
			values[3] = timeStyle;
			values[4] = timeZone;
			values[5] = type;
			return (values);
		}
		return null;

	}


	public void restoreState(FacesContext context, Object state) {

		if (context == null) {
			throw new NullPointerException();
		}
		if (state != null) {
			Object values[] = (Object[]) state;
			dateStyle = (String) values[0];
			locale = (Locale) values[1];
			pattern = (String) values[2];
			timeStyle = (String) values[3];
			timeZone = (TimeZone) values[4];
			type = (String) values[5];
		}

	}


	private boolean transientFlag = false;


	public boolean isTransient() {
		return (transientFlag);
	}


	public void setTransient(boolean transientFlag) {
		this.transientFlag = transientFlag;
	}

	private boolean initialState;

	public void markInitialState() {
		initialState = true;
	}

	public boolean initialStateMarked() {
		return initialState;
	}

	public void clearInitialState() {
		initialState = false;
	}
}
