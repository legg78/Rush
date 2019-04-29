package ru.bpc.sv2.process.btrt;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.application.ApplicationElement;

public class NodeItem implements Cloneable {

	private String name;
	private int length;
	private String data;
	private NodeItem parent;
	private String lang;
	private List<NodeItem> children;
	private Map<String, String> subDatas;
	
	public NodeItem() {
		
	}
	
	public NodeItem(String name){
		this(name, null);
	}
	
	public NodeItem(String name, String data) {
		this.name = name;
		this.data = data;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getLength() {
		return length;
	}

	public void setLength(int length) {
		this.length = length;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getData() {
		return data;
	}

	public void setData(String data) {
		this.data = data;
	}

	public NodeItem getParent() {
		return parent;
	}

	public void setParent(NodeItem parent) {
		this.parent = parent;
	}

	public List<NodeItem> getChildren() {
		if (children == null) {
			children = new ArrayList<NodeItem>();
		}
		return children;
	}

	public void setChildren(List<NodeItem> children) {
		this.children = children;
	}
	
	public Map<String, String> getSubDatas() {
		if (subDatas == null) subDatas = new HashMap<String, String>();
		return subDatas;
	}

	public void setSubDatas(Map<String, String> subDatas) {
		this.subDatas = subDatas;
	}

	@Override
	public String toString() {
	    if (name != null) {
	    	return name;
	    }
	    return super.toString();
	}

	/**
	 * Clones object without parent (or we'll get StackOverflowError)
	 */
	@Override
	public NodeItem clone() {
		NodeItem result = new NodeItem();
		result.setName(this.name);
		result.setData(this.data);
		result.setLength(this.length);
		result.setLang(lang);
		
		for (NodeItem child : getChildren()) {
			result.getChildren().add(child.clone());
		}
		
		for (String key : getSubDatas().keySet()) {
			result.getSubDatas().put(key, subDatas.get(key));
		}
		
		return result;
	}

	public NodeItem child(String name){
		if (name == null) throw new IllegalArgumentException("Argument 'name' is null");
		for (NodeItem child : getChildren()){
			if (name.equals(child.getName())){
				return child;
			}
		}
		return null;
	}
	
	public NodeItem child(BTRTMapping tag){
		String name = tag.getCode();
		return child(name);
	}
	
	public List<NodeItem> childs(String name){
		if (name == null) throw new IllegalArgumentException("Argument 'name' is null");
		List<NodeItem> result = new ArrayList<NodeItem>();
		for (NodeItem child : getChildren()){
			if (name.equals(child.getName())){
				result.add(child); 
			}
		}
		return result;
	}
	
	public static void print(NodeItem element){
		print(element, 0);
	}
	
	private static void print(NodeItem element, int indent){
		final String indentSymbol = "   ";
		StringBuilder sb = new StringBuilder();
		for (int i=0;i<indent;i++) sb.append(indentSymbol);
		sb.append(element.getName());
		sb.append(" : ");
		Object value = element.getData();
		if (value != null){
			sb.append(value.toString());
		} else {
			sb.append("null");
		}
		System.out.print(sb.toString());
		if (!element.getChildren().isEmpty()){
			System.out.println("{");			
			for (NodeItem child : element.getChildren()){
				print(child, indent + 1);
			}
			for (int i=0;i<indent;i++) System.out.print(indentSymbol);
			System.out.println("}");
		} else {
			System.out.println();
		}
	}
}
