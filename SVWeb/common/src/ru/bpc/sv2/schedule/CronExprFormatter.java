package ru.bpc.sv2.schedule;

import java.io.Serializable;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class CronExprFormatter implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private boolean periodicalRepeatEnabled		= false;
	private String startTime 	= null;
	private String timePeriod	= null;
	
	public static final String[] months = { "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG",
			"SEP", "OCT", "NOV", "DEC" };
	
	public CronExprFormatter(){
	}
	
	public static final Pattern onlyOnce = Pattern.compile("\\d+");
	public static final Pattern withPeriod = Pattern.compile("\\d+/\\d+");
	
	public static CronExprFormatter createCronExprFormatter(String minutes)
	throws CronFormatException {
		if (minutes == null) {
			throw new CronFormatException("\"cron minutes\" value is null");
		}
		
		CronExprFormatter formatter = new CronExprFormatter(); 
		
		Matcher m = onlyOnce.matcher(minutes);
		if (m.matches()) {
			formatter.setStartTime(minutes);
			return formatter;
		}
		
		m = withPeriod.matcher(minutes);
		if (m.matches()) {
			String[] mins = minutes.split("/");
			
			formatter.setPeriodicalRepeatEnabled(true);
			formatter.setStartTime(mins[0]);
			formatter.setTimePeriod(mins[1]);
			return formatter;
		}
		
		throw new CronFormatException("\"Cron minutes\" value does not satisfy any patterns, minutes: " + minutes);
	}
	
	public static CronExprFormatter createMonthCronExprFormatter(String months)
			throws CronFormatException {
		if (months == null) {
			throw new CronFormatException("\"cron months\" value is null");
		}

		CronExprFormatter formatter = new CronExprFormatter();

		if (isCorrectMonth(months)) {
			formatter.setStartTime(months);
			return formatter;
		}

		String[] monthPeriod = months.split("/");
		if (monthPeriod == null || monthPeriod.length == 0 || monthPeriod.length > 2
				|| !isCorrectMonth(monthPeriod[0]) || !onlyOnce.matcher(monthPeriod[1]).matches()) {
			throw new CronFormatException(
					"\"Cron months\" value does not satisfy any patterns, months: " + months);
		}

		formatter.setPeriodicalRepeatEnabled(true);
		formatter.setStartTime(monthPeriod[0]);
		formatter.setTimePeriod(monthPeriod[1]);

		return formatter;
	}

	public String getCronFormattedMinutes()
	throws CronFormatException {
		if (startTime == null || "".equals(startTime))
			throw new CronFormatException("startSecond should not be empty");
		
		int period = -1;
		if (periodicalRepeatEnabled && (timePeriod == null || "".equals(timePeriod))) {
			throw new CronFormatException("timePeriod should not be empty");
		} else if (periodicalRepeatEnabled) {
			period = Integer.parseInt(timePeriod);
		}
		
		int start = Integer.parseInt(startTime);
		
		StringBuffer sb = new StringBuffer();
		if (periodicalRepeatEnabled && period > 0) {
			if (start >= 0 || start < 60) {
				sb.append(startTime).append("/").append(timePeriod);
			} else {
				throw new CronFormatException("Cron minutes could be defined incorrectly: startSecond: " + startTime + ", timePeriod: " + timePeriod);
			}
		} else {
			sb.append(startTime);
		}
		
		sb.append(' ');
		
		return sb.toString();
	}

	public String getCronFormattedMonths() throws CronFormatException {
		if (startTime == null || "".equals(startTime))
			throw new CronFormatException("Month should not be empty");

		int period = -1;
		if (periodicalRepeatEnabled && (timePeriod == null || "".equals(timePeriod))) {
			throw new CronFormatException("Period should not be empty when repeating is enabled");
		} else if (periodicalRepeatEnabled) {
			period = Integer.parseInt(timePeriod);
		}

		StringBuffer sb = new StringBuffer();
		if (periodicalRepeatEnabled && period > 0) {
			if (isCorrectMonth(startTime)) {
				sb.append(startTime).append("/").append(timePeriod);
			} else {
				throw new CronFormatException("Cron month is defined incorrectly: month: "
						+ startTime + ", timePeriod: " + timePeriod);
			}
		} else {
			sb.append(startTime);
		}

		sb.append(' ');

		return sb.toString();
	}

	private static boolean isCorrectMonth(String monthString) {
		try {
			int month = Integer.parseInt(monthString);
			if (month < 0 || month > 11) {
				return false;
			}
		} catch (NumberFormatException e) {
			for (String month : months) {
				if (month.equals(monthString)) {
					return true;
				}
			}
			return false;
		}
		return true;
	}
	
	public boolean isPeriodicalRepeatEnabled() {
		return periodicalRepeatEnabled;
	}
	public void setPeriodicalRepeatEnabled(boolean enabled) {
		this.periodicalRepeatEnabled = enabled;
	}

	public String getStartTime() {
		return startTime;
	}
	public void setStartTime(String startTime) {
		this.startTime = startTime;
	}

	public String getTimePeriod() {
		return timePeriod;
	}
	public void setTimePeriod(String timePeriod) {
		this.timePeriod = timePeriod;
	}
}
