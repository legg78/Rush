package ru.bpc.sv2.schedule;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class CronFormatter implements Serializable {
	private static final long serialVersionUID = 1L;

	public static final Pattern cronPattern = Pattern.compile("(\\S+)\\s+(\\S+)\\s+(\\S+)\\s+(\\S+)\\s+(\\S+)\\s+(\\S+)\\s*");
	public static final int WEEK_DAY = 0;
	public static final int MONTH_DAY = 1;

	private boolean everyMonth				= false;
	private boolean everyDay				= false;
	private boolean everyHour				= false;
	private boolean everyMinute				= false;
	private boolean everySecond				= false;

	private boolean weeklyScheduled			= false;
	private boolean dailyScheduled			= false;
	private boolean skipHolidays			= false;

	private List<String> months				= null;
	private List<String> weeks				= null;
	private List<String> days				= null;
	private List<String> daysList			= null;
	private List<String> hours				= null;

	private CronExprFormatter cronMinutes	= null;
	private CronExprFormatter cronHours		= null;
	private CronExprFormatter cronSeconds	= null;
	private CronExprFormatter cronDays		= null;
	private CronExprFormatter cronMonths	= null;

	private int dayType;
	private String scheduleType;

	public CronFormatter() {}

	public static CronFormatter createCronFormatter(String formedCron) throws CronFormatException {
		if (formedCron == null) {
			throw new CronFormatException("Cron format error. Null string passed");
		}

		CronFormatter cronFormatter = new CronFormatter();
		Matcher matcher = cronPattern.matcher(formedCron);
		if (!matcher.matches()) {
			throw new CronFormatException("Cron format error. Passed string: " + formedCron);
		}

		String minutes = matcher.group(2);
		if ("*".equals(minutes)) {
			cronFormatter.setEveryMinute(true);
		} else { 
			cronFormatter.setCronMinutes(CronExprFormatter.createCronExprFormatter(minutes));
		}

		String hours = matcher.group(3);
		if ("*".equals(hours)) {
			cronFormatter.setEveryHour(true);
		} else {
			cronFormatter.setCronHours(CronExprFormatter.createCronExprFormatter(hours));
		}

		String days = matcher.group(4);
		if ("*".equals(days)) {
			cronFormatter.setEveryDay(true);
			cronFormatter.setWeeklyScheduled(false);
			cronFormatter.setDailyScheduled(false);			
		} else if ("?".equals(days)) {
			cronFormatter.setDayType(WEEK_DAY);			
		} else {
			cronFormatter.setDays(Arrays.asList(days.split(",")));
			cronFormatter.setDayType(MONTH_DAY);
		}

		String months = matcher.group(5);
		if ("*".equals(months)) {
			cronFormatter.setEveryMonth(true);
		} else {
			CronExprFormatter formatter = CronExprFormatter.createMonthCronExprFormatter(months);
			cronFormatter.setCronMonths(formatter);
		}

		String weeks = matcher.group(6);
		if (!"?".equals(weeks)) {
			cronFormatter.setWeeklyScheduled(true);
			cronFormatter.setDaysList(Arrays.asList(weeks.split(",")));
		}

		return cronFormatter;
	}

	public String formCronString() throws CronFormatException {
		StringBuffer cron = new StringBuffer();
		cron.append('0').append(' ');
		if (everyMinute) {
			cron.append('*').append(' ');
		} else {
			cron.append(this.getCronMinutes().getCronFormattedMinutes());
		}
		if (everyHour) {
			cron.append('*').append(' ');
		} else {
			cron.append(this.getCronHours().getCronFormattedMinutes());
		}
		if (everyDay) {
			cron.append('*').append(' ');
		} else if (dailyScheduled) {
			translateList2String(this.getDays(), cron);
		} else if (weeklyScheduled) {
			cron.append('?').append(' ');
		}
		if (everyMonth) {
			cron.append('*').append(' ');
		} else {
			cron.append(this.getCronMonths().getCronFormattedMonths());
		}
		if (isWeeklyScheduled()) {
			this.translateList2String(this.getDaysList(), cron);
		}
		if (dailyScheduled || everyDay) {
			cron.append('?').append(' ');
		}
		return cron.toString();
	}

	private void translateList2String(List<String> list, StringBuffer buffer) {
		for (int i = 0; i < list.size(); i++) {
			buffer.append(list.get(i));
			buffer.append(',');
		}
		if (buffer.lastIndexOf(",") == buffer.length() - 1) {
			buffer.deleteCharAt(buffer.lastIndexOf(","));
		}
		buffer.append(' ');
	}

	public boolean isEveryDay() {
		return everyDay;
	}
	public void setEveryDay(boolean everyday) {
		if (everyday) {
			this.dailyScheduled = false;
			this.weeklyScheduled = false;
		} else {
			if (this.dayType == WEEK_DAY) {
				this.setWeeklyScheduled(true);
			} else if (this.dayType == MONTH_DAY) {
				this.setDailyScheduled(true);
			}
		}
		this.everyDay = everyday;
	}

	public List<String> getDays() {
		if (days == null) {
			days = new ArrayList<String>();
		}
		return days;
	}
	public void setDays(List<String> day) {
		this.days = day;
	}

	public List<String> getDaysList() {
		if (daysList == null) {
			daysList = new ArrayList<String>();
		}
		return daysList;
	}
	public void setDaysList(List<String> daysList) {
		this.daysList = daysList;
	}

	public boolean isEveryHour() {
		return everyHour;
	}
	public void setEveryHour(boolean everyHour) {
		this.everyHour = everyHour;
	}

	public boolean isEveryMinute() {
		return everyMinute;
	}
	public void setEveryMinute(boolean everyMinute) {
		this.everyMinute = everyMinute;
	}

	public boolean isEveryMonth() {
		return everyMonth;
	}
	public void setEveryMonth(boolean everyMonth) {
		this.everyMonth = everyMonth;
	}

	public List<String> getHours() {
		if (hours == null) {
			hours = new ArrayList<String>();
		}
		return hours;
	}
	public void setHours(List<String> hour) {
		this.hours = hour;
	}

	public CronExprFormatter getCronMinutes() {
		if (cronMinutes == null) {
			cronMinutes	= new CronExprFormatter();
		}
		return cronMinutes;
	}
	public void setCronMinutes(CronExprFormatter cronMinutes) {
		this.cronMinutes = cronMinutes;
	}

	public CronExprFormatter getCronHours() {
		if (cronHours == null) {
			cronHours	= new CronExprFormatter();
		}
		return cronHours;
	}
	public void setCronHours(CronExprFormatter cronHours) {
		this.cronHours = cronHours;
	}

	public CronExprFormatter getCronSeconds() {
		if (cronSeconds == null) {
			cronSeconds	= new CronExprFormatter();
		}
		return cronSeconds;
	}
	public void setCronSeconds(CronExprFormatter cronSeconds) {
		this.cronSeconds = cronSeconds;
	}

	public CronExprFormatter getCronDays() {
		if (cronDays == null) {
			cronDays	= new CronExprFormatter();
		}
		return cronDays;
	}
	public void setCronDays(CronExprFormatter cronDays) {
		this.cronDays = cronDays;
	}

	public CronExprFormatter getCronMonths() {
		if (cronMonths == null) {
				cronMonths = new CronExprFormatter();
		}
		return cronMonths;
	}
	public void setCronMonths(CronExprFormatter cronMonths) {
		this.cronMonths = cronMonths;
	}

	public List<String> getMonths() {
		if (months == null) {
			months = new ArrayList<String>();
		}
		return months;
	}
	public void setMonths(List<String> month) {
		this.months = month;
	}

	public boolean isDailyScheduled() {
		return dailyScheduled;
	}
	public void setDailyScheduled(boolean dailyScheduled) {
		this.dailyScheduled = dailyScheduled;
		
		if (weeklyScheduled == dailyScheduled) {
			setWeeklyScheduled(!dailyScheduled);
		}
	}

	public boolean isWeeklyScheduled() {
		return weeklyScheduled;
	}
	public void setWeeklyScheduled(boolean weeklyScheduled) {
		this.weeklyScheduled = weeklyScheduled;
		
		if (weeklyScheduled == dailyScheduled) {
			setDailyScheduled(!weeklyScheduled);
		}
	}

	public List<String> getWeeks() {
		if (weeks == null) {
			weeks = new ArrayList<String>();
		}
		return weeks;
	}
	public void setWeeks(List<String> week) {
		this.weeks = week;
	}

	public boolean isEverySecond() {
		return everySecond;
	}
	public void setEverySecond(boolean everySecond) {
		this.everySecond = everySecond;
	}

	public String getScheduleType() {
		return scheduleType;
	}
	public void setScheduleType(String scheduleType) {
		this.scheduleType = scheduleType;
	}

	public int getDayType() {
		return dayType;
	}
	public void setDayType(int dayType) {
		this.dayType = dayType;
		if (dayType == WEEK_DAY) {
			setWeeklyScheduled(true);
			setDailyScheduled(false);
		} else if (dayType == MONTH_DAY){
			setWeeklyScheduled(false);
			setDailyScheduled(true);
		}
	}
	
	public int getWeeklyDay() {
		return WEEK_DAY;
	}
	public int getMonthDay() {
		return MONTH_DAY;
	}

	public boolean isSkipHolidays() {
		return skipHolidays;
	}
	public void setSkipHolidays(boolean skipHolidays) {
		this.skipHolidays = skipHolidays;
	}
}
