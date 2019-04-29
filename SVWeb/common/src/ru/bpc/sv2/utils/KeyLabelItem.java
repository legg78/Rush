package ru.bpc.sv2.utils;

import java.io.Serializable;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "lov_record", propOrder = {
    "value",
    "label"
})
public class KeyLabelItem implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 7463274562138548736L;
	@XmlElement(required = true)
	private Object value;
	@XmlElement(required = true)
	private String label;
	private String style;
	
	
	public KeyLabelItem (Object value) {
		this.value = value;
	}
	
	public KeyLabelItem (Object value, String label) {
		this.value = value;
		this.label = label;
	}
	
	public KeyLabelItem () {
		
	}
	public Object getValue() {
		return value;
	}
	public void setValue(Object value) {
		this.value = value;
	}
	public String getLabel() {
		return label;
	}
	public void setLabel(String label) {
		this.label = label;
	}
	
	@Override
	public int hashCode() {
		return value.hashCode();
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		
		if (((KeyLabelItem)obj).getValue() != null) {
			if (this.value == null) {
				return false;
			} else if (this.value instanceof Double) {
				return Double.valueOf(((KeyLabelItem) obj).getValue().toString()).equals(
						Double.valueOf(this.value.toString()));
			} else if (this.value instanceof String) {
				return ((KeyLabelItem) obj).getValue().toString().equals(this.value.toString());
			}
		} else {
			return false;		
		}				
		
		return ((KeyLabelItem)obj).getValue().toString().equals(this.value);
	}
	
	public String getStyle(){
		return style;
	}
	
	public void setStyle(String style){
		this.style = style;
	}
}
