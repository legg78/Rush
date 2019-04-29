package ru.bpc.sv2.atm;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class AtmScenario implements ModelIdentifiable, Serializable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private String name;
	private String description;
	private String lang;
	private Date dateBegin;
	private Date dateLoad;
	private String userLoad;
	
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
	
	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getId() {
		return id;
	}

	public Object getModelId() {
		return id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public Date getDateBegin() {
		return dateBegin;
	}

	public void setDateBegin(Date dateBegin) {
		this.dateBegin = dateBegin;
	}

	public Date getDateLoad() {
		return dateLoad;
	}

	public void setDateLoad(Date dateLoad) {
		this.dateLoad = dateLoad;
	}

	public String getUserLoad() {
		return userLoad;
	}

	public void setUserLoad(String userLoad) {
		this.userLoad = userLoad;
	}

}

