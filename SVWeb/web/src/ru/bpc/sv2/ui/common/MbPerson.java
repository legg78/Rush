package ru.bpc.sv2.ui.common;

import java.io.Serializable;

import ru.bpc.sv2.common.Person;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbPerson")
public class MbPerson implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private Person person;
	
    public Person getPerson() {
    	if (person == null) {
    		person = new Person();
    	}
		return person;
	}

	public void setPerson(Person person) {
		this.person = person;
	}
}
