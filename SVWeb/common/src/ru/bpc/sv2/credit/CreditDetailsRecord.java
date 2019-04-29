package ru.bpc.sv2.credit;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Calendar;
import java.util.Comparator;
import java.util.Date;
import java.util.GregorianCalendar;

public class CreditDetailsRecord implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;

	private String name;
	private String parentName;
	private String systemName;
	private String value;
	private Long accountId;
	private Date payOffDate;
	private Date startDate;
	private Date endDate;

	public String getName() {
	    return name;
	}
	public void setName(String name) {
		this.name = name;
	}

	public String getParentName() {
		return parentName;
	}
	public void setParentName(String parentName) {
	    this.parentName = parentName;
	}

	public String getSystemName() {
		return systemName;
	}
	public void setSystemName(String systemName) {
		this.systemName = systemName;
	}

	public String getValue() {
		return value;
	}
	public void setValue(String value) {
		this.value = value;
	}
	
	public Long getAccountId() {
		return accountId;
	}
	public void setAccountId(Long accountId) {
		this.accountId = accountId;
	}

	public Date getPayOffDate() {
		if (payOffDate == null) {
			payOffDate = new Date();
		}
		return payOffDate;
	}
	public void setPayOffDate(Date payOffDate) {
		this.payOffDate = payOffDate;
	}

	public Date getStartDate() {
		return startDate;
	}
	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Date getEndDate() {
		return endDate;
	}
	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}

	@Override
	public Object getModelId() {
		return getSystemName();
	}

	public static Comparator<CreditDetailsRecord> TREE_COMPARE = new Comparator<CreditDetailsRecord>() {
		@Override
		public int compare(CreditDetailsRecord o1, CreditDetailsRecord o2) {
			int x = 0;

			if (o1.parentName == null && o2.parentName == null) {
				x = o1.systemName.compareTo(o2.systemName);
				if (x == 0) x = -1;
			}
			else if (o1.parentName == null && o2.parentName != null) {
				x = o1.systemName.compareTo(o2.parentName);
				if (x==0) x = o1.systemName.compareTo(o2.systemName);
				if (x==0) x = -1;
			}
			else if (o1.parentName != null && o2.parentName == null) {
				x = o1.parentName.compareTo(o2.systemName);
				if (x == 0) x = o1.systemName.compareTo(o2.systemName);
				if (x == 0) x = 1;
			}
			else if (o1.parentName != null && o2.parentName != null)
				x = o1.parentName.compareTo(o2.parentName);

			return x;
		};
	};
}

