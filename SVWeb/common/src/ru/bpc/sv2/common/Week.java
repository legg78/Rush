package ru.bpc.sv2.common;

import java.io.Serializable;

public class Week implements Serializable {

	private static final long serialVersionUID = 1L;
	private String month;
	private String year;
	private String weekNum;
	private Integer monday;
	private Integer tuesday;
	private Integer wednesday;
	private Integer thursday;
	private Integer friday;
	private Integer saturday;
	private Integer sunday;
	private Integer mondayHoliday;
	private Integer tuesdayHoliday;
	private Integer wednesdayHoliday;
	private Integer thursdayHoliday;
	private Integer fridayHoliday;
	private Integer saturdayHoliday;
	private Integer sundayHoliday;

	public String getMonth() {
		return month;
	}

	public void setMonth(String month) {
		this.month = month;
	}

	public String getYear() {
		return year;
	}

	public void setYear(String year) {
		this.year = year;
	}

	public String getWeekNum() {
		return weekNum;
	}

	public void setWeekNum(String weekNum) {
		this.weekNum = weekNum;
	}

	public Integer getMonday() {
		return monday;
	}

	public void setMonday(Integer monday) {
		this.monday = monday;
	}

	public Integer getTuesday() {
		return tuesday;
	}

	public void setTuesday(Integer tuesday) {
		this.tuesday = tuesday;
	}

	public Integer getWednesday() {
		return wednesday;
	}

	public void setWednesday(Integer wednesday) {
		this.wednesday = wednesday;
	}

	public Integer getThursday() {
		return thursday;
	}

	public void setThursday(Integer thursday) {
		this.thursday = thursday;
	}

	public Integer getFriday() {
		return friday;
	}

	public void setFriday(Integer friday) {
		this.friday = friday;
	}

	public Integer getSaturday() {
		return saturday;
	}

	public void setSaturday(Integer saturday) {
		this.saturday = saturday;
	}

	public Integer getSunday() {
		return sunday;
	}

	public void setSunday(Integer sunday) {
		this.sunday = sunday;
	}

	public Integer getMondayHoliday() {
		return mondayHoliday;
	}

	public void setMondayHoliday(Integer mondayHoliday) {
		this.mondayHoliday = mondayHoliday;
	}

	public Integer getTuesdayHoliday() {
		return tuesdayHoliday;
	}

	public void setTuesdayHoliday(Integer tuesdayHoliday) {
		this.tuesdayHoliday = tuesdayHoliday;
	}

	public Integer getWednesdayHoliday() {
		return wednesdayHoliday;
	}

	public void setWednesdayHoliday(Integer wednesdayHoliday) {
		this.wednesdayHoliday = wednesdayHoliday;
	}

	public Integer getThursdayHoliday() {
		return thursdayHoliday;
	}

	public void setThursdayHoliday(Integer thursdayHoliday) {
		this.thursdayHoliday = thursdayHoliday;
	}

	public Integer getFridayHoliday() {
		return fridayHoliday;
	}

	public void setFridayHoliday(Integer fridayHoliday) {
		this.fridayHoliday = fridayHoliday;
	}

	public Integer getSaturdayHoliday() {
		return saturdayHoliday;
	}

	public void setSaturdayHoliday(Integer saturdayHoliday) {
		this.saturdayHoliday = saturdayHoliday;
	}

	public Integer getSundayHoliday() {
		return sundayHoliday;
	}

	public void setSundayHoliday(Integer sundayHoliday) {
		this.sundayHoliday = sundayHoliday;
	}

//	public boolean isHolidayOnMonday() {
//		return (mondayHoliday != null && mondayHoliday.intValue() == 1);
//	}
//
//	public boolean isHolidayOnTuesday() {
//		return (tuesdayHoliday != null && tuesdayHoliday.intValue() == 1);
//	}
//
//	public boolean isHolidayOnWednesday() {
//		return (wednesdayHoliday != null && wednesdayHoliday.intValue() == 1);
//	}
//
//	public boolean isHolidayOnThursday() {
//		return (thursdayHoliday != null && thursdayHoliday.intValue() == 1);
//	}
//
//	public boolean isHolidayOnFriday() {
//		return (fridayHoliday != null && fridayHoliday.intValue() == 1);
//	}
//
//	public boolean isHolidayOnSaturday() {
//		return (saturdayHoliday != null && saturdayHoliday.intValue() == 1);
//	}
//
//	public boolean isHolidayOnSunday() {
//		return  (sundayHoliday != null && sundayHoliday.intValue() == 1);
//	}

	public Object getModelId() {
		return getMonth() + "_" + getYear() + "_" + getWeekNum();
	}
}
