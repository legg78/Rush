package ru.bpc.sv2.ui.common.days;

import java.io.Serializable;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.common.Week;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@ViewScoped
@ManagedBean (name = "MbCalendar")
public class MbCalendar extends AbstractBean implements Serializable {
	
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("COMMON");
	
	private CommonDao _commonDao = new CommonDao();
	
	private ArrayList<SelectItem> institutions;
	private int year;
	private Integer instId;
	private Date selectedDate = new Date();
	private Week[][] months;

	private Long userSessionId = null;
	private String pageLink = "common|calendars";

	public MbCalendar() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		this.year = Calendar.getInstance().get(Calendar.YEAR);
		instId = ((UserSession) ManagedBeanWrapper.getManagedBean("usession")).getUserInst();
	}

	/**
	 * @return all available years from COM_HOLIDAY_DISPLAY_VW
	 */
	public SelectItem[] getYears() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		//String[] years = _commonDao.getCalendarYears(userSessionId);

		for (int i = 2000; i<=2050; i++) {
			items.add(new SelectItem(i));
		}
		return items.toArray(new SelectItem[items.size()]);
	}

	/**
	 * Gets all weeks by year and month then returns it as a 2-D
	 * array of weeks per month for easy rendering as calendar.
	 * @return
	 */
	public Week[][] getMonths() {
		Week[][] months = new Week[12][];
		Week[] weeks = null;
		try {
			weeks = _commonDao.getCalendarWeeks(userSessionId, null, year, instId);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		} finally {
			if (weeks == null) {
				weeks = new Week[0];
				return months;
			}
		}
		
		int month = 1;
		List<Week> weeksInMonth = new ArrayList<Week>();
		for (int i = 0; i < weeks.length; i++) {
			int weekMonth = Integer.parseInt(weeks[i].getMonth());
			if (month == weekMonth) {
				weeksInMonth.add(weeks[i]);
			} else {
				months[month - 1] = weeksInMonth.toArray(new Week[weeksInMonth.size()]);
				month = weekMonth;
				weeksInMonth = new ArrayList<Week>();
				weeksInMonth.add(weeks[i]);
			}
			months[month - 1] = weeksInMonth.toArray(new Week[weeksInMonth.size()]);
			
		}
		return months;
	}

	public Week[] getJanuary() {
		if (months == null) {
			months = getMonths();
		}
		return months[0];
	}

	public Week[] getFebruary() {
		return months[1];
	}

	public Week[] getMarch() {
		return months[2];
	}

	public Week[] getApril() {
		return months[3];
	}

	public Week[] getMay() {
		return months[4];
	}

	public Week[] getJune() {
		return months[5];
	}

	public Week[] getJuly() {
		return months[6];
	}

	public Week[] getAugust() {
		return months[7];
	}

	public Week[] getSeptember() {
		return months[8];
	}

	public Week[] getOctober() {
		return months[9];
	}

	public Week[] getNovember() {
		return months[10];
	}

	public Week[] getDecember() {
		return months[11];
	}

	public Date getSelectedDate() {
		return new Date(selectedDate.getTime());
	}

	public void setSelectedDate(Date date) {
		this.selectedDate = date;
	}

	public Object getLocale() {
		return Locale.getDefault();
	}

	public TimeZone getTimeZone() {
		DateFormat df = DateFormat.getInstance();
		df.setCalendar(Calendar.getInstance());
		return df.getTimeZone();
	}

	public void markAsHoliday() {
		try {
			Map<String, String> params = FacesContext.getCurrentInstance().getExternalContext().getRequestParameterMap();
			String month = params.get("month");
			int monthInt = Integer.parseInt(month);
			int year = Integer.parseInt(params.get("year"));			
			int day = Integer.parseInt(params.get("day"));
			
			
			Calendar cal = Calendar.getInstance();
			cal.setTimeZone(getTimeZone());
			cal.set(Calendar.DAY_OF_MONTH, day);
			cal.set(Calendar.MONTH, monthInt - 1);	// in Calendar months begin from '0'
			cal.set(Calendar.YEAR, year);

	//		System.out.println(cal.getTime());
			_commonDao.addRemoveHoliday( userSessionId, cal.getTime(), instId);
			months[monthInt - 1] = _commonDao.getCalendarWeeks( userSessionId, month, year, instId);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}

	public String saveDay() {
		return "";
	}

	public int getYear() {
		return year;
	}

	public void setYear(int year) {
		this.year = year;
		this.months = getMonths();
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			DictUtils dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
			institutions = (ArrayList<SelectItem>) dictUtils.getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}
	
	public void clearFilter(){
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		this.year = Calendar.getInstance().get(Calendar.YEAR);
		instId = ((UserSession) ManagedBeanWrapper.getManagedBean("usession")).getUserInst();
		months = null;
	}
	
	public String actionPage(){
		return pageLink;
	}
}
