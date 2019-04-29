package ru.bpc.sv2.ui.common.application;

import java.util.ArrayList;
import java.util.List;

public class MenuTreeItem{
	private String label;
	private String name;
	private int innerId = 0;
	private String modelId;
	private boolean valid = true;
	private String cssClass;
	
	private List<MenuTreeItem> items;
	
	public MenuTreeItem(){
		
	}
	
	public MenuTreeItem(String name, Integer innerId){
		this(null, name, innerId);
	}	
	
	public MenuTreeItem(String label, String name){
		this(label, name, 0);
	}
	
	public MenuTreeItem(String label, String name, int innerId){
		this.label = label;
		this.name = name;
		this.innerId = innerId;
	}
	
	public MenuTreeItem(String label, String name, String cssClass){
		this(label, name, 0);
		this.cssClass = cssClass;
	}		
	
	public String getLabel() {
		return label;
	}
	public void setLabel(String label) {
		this.label = label;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public List<MenuTreeItem> getItems() {
		if (items == null){
			items = new ArrayList<MenuTreeItem>();
		}
		return items;
	}
	public void setItems(List<MenuTreeItem> items) {
		this.items = items;
	}

	public int getInnerId() {
		return innerId;
	}

	public void setInnerId(int innerId) {
		this.innerId = innerId;
		updateModelId();
	}
	
	private void updateModelId(){
		modelId = name + innerId;
	}
	
	public int getModelId(){
		if (modelId == null){
			updateModelId();
		}
		return modelId.hashCode();
	}

	public boolean isValid() {
		return valid;
	}

	public void setValid(boolean valid) {
		this.valid = valid;
	}

	public String getCssClass() {
		return cssClass;
	}

	public void setCssClass(String cssClass) {
		this.cssClass = cssClass;
	}
}