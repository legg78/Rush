package ru.bpc.sv2.scheduler.process.mc.entity;

public class FieldConfig {
	private boolean fixed;
	private int length;
	public FieldConfig(boolean fixed, int length){
		this.fixed = fixed;
		this.length = length;
	}
	public boolean isFixed() {
		return fixed;
	}
	public void setFixed(boolean fixed) {
		this.fixed = fixed;
	}
	public int getLength() {
		return length;
	}
	public void setLength(int length) {
		this.length = length;
	}
	

}
