package ru.bpc.sv2.scheduler;

import java.text.DateFormatSymbols;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import util.auxil.SessionWrapper;

@RequestScoped
@ManagedBean (name = "MbSetSchedule")
public class MbSetSchedule
{
	private String name  		= null;
	private String address 	 	= null;
	private List<SelectItem> hoursList;
	private List<SelectItem> minutesList;
	private List<SelectItem> secondsList;
	private List<SelectItem> mounthsList;
	private List<SelectItem> daysList;

	private final static DateFormatSymbols  symbols = new DateFormatSymbols(Locale.ENGLISH);

	private String[] defaultDays = symbols.getShortWeekdays();
	private String[] defaultMoun = symbols.getShortMonths();

	Long userSessionId = null;

	public MbSetSchedule(){
		userSessionId = SessionWrapper.getRequiredUserSessionId();
	}

/*
	private void performChecks(ScheduledReport qr)
	throws IOException {
		if (qr.getUnloadType() == null)
			throw new IOException("Type is required");

		if (address == null)
			throw new IOException("Address is required");

		if(!qr.getCronFormatter().isEveryMonth() && qr.getCronFormatter().getMonths().size()==0)
			throw new IOException("Schedule for mounth is required");

		if(!qr.getCronFormatter().isEveryHour() && qr.getCronFormatter().getHours().size()==0)
			throw new IOException("Schedule for hours is required");

		if(!qr.getCronFormatter().isEveryDay() && !qr.getCronFormatter().isDailyScheduled() &&
				!qr.getCronFormatter().isWeeklySheduled())
			throw new IOException("Schedule for days is required");

		if(qr.getCronFormatter().isDailyScheduled() && qr.getCronFormatter().getDays().size()==0)
			throw new IOException("Schedule for days is required");

		if(qr.getCronFormatter().isWeeklySheduled()&& qr.getCronFormatter().getWeeks().size()==0)
			throw new IOException("Schedule for days is required");

		if(!qr.getCronFormatter().isEveryMinute() && (qr.getCronFormatter().getCronMinutes().getStartSecond() == null
				|| qr.getCronFormatter().getCronMinutes().getStartSecond().equals("")))
			throw new IOException("Schedule for minutes is required");
	}
*/
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}

	public String getAddress() {
		return address;
	}
	public void setAddress(String address) {
		this.address = address;
	}


	public List<SelectItem> getHoursList() {
		if (hoursList == null) {
			hoursList = new ArrayList<SelectItem>();
			for(int i =0; i < 24; i++) {
				hoursList.add(new SelectItem(Integer.toString(i),Integer.toString(i)));
			}
		}
		return hoursList;
	}
	public List<SelectItem> getMinutesList() {
		if (minutesList == null) {
			minutesList = new ArrayList<SelectItem>();
			for (int i =0; i < 60; i++) {
				minutesList.add(new SelectItem(Integer.toString(i),Integer.toString(i)));
			}
		}
		return minutesList;
	}
	public List<SelectItem> getSecondsList() {
		if (secondsList == null) {
			secondsList = new ArrayList<SelectItem>();
			for (int i =0; i < 60; i++) {
				secondsList.add(new SelectItem(Integer.toString(i),Integer.toString(i)));
			}
		}
		return secondsList;
	}
	public List<SelectItem> getMounthsList() {
		if (mounthsList == null) {
			mounthsList = new ArrayList<SelectItem>();
			for(int i =1; i < 13; i++) {
				mounthsList.add(new SelectItem(Integer.toString(i),defaultMoun[i-1]));
			}
		}
		return mounthsList;
	}
	
	public List<SelectItem> getDaysList() {
		if (daysList == null) {
			daysList = new ArrayList<SelectItem>();
			for(int i =1; i < 13; i++) {
				daysList.add(new SelectItem(Integer.toString(i),Integer.toString(i)));
			}
		}
		return daysList;
	}
}
