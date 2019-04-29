package ru.bpc.sv2.process;

import java.io.Serializable;

public class ProgressBarMap implements Serializable {

	private static final long serialVersionUID = 1L;

	private Integer bar;
	private Integer current;
	public Integer getBar() {
		return bar;
	}
	public void setBar(Integer bar) {
		this.bar = bar;
	}
	public Integer getCurrent() {
		return current;
	}
	public void setCurrent(Integer current) {
		this.current = current;
	}
	
}
