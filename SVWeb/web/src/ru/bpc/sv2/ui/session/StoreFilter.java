package ru.bpc.sv2.ui.session;

import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Map;
import java.util.Map.Entry;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean(name = "StoreFilter")
public class StoreFilter {
	private Map<String, LinkedList<HashMap<String,HashMap<String,Object>>>> store;
	
	private Map<String, LinkedList<HashMap<String,HashMap<String,Object>>>> getStore(){
		if(store == null){
			store = new HashMap<String, LinkedList<HashMap<String,HashMap<String,Object>>>>();
		}
		return store;
	}
	private LinkedList<HashMap<String,HashMap<String,Object>>> getQueue(String key){
		LinkedList<HashMap<String,HashMap<String,Object>>> queue = getStore().get(key);
		if(queue == null || queue.size()==0){
			queue = new LinkedList<HashMap<String,HashMap<String,Object>>>();
			getStore().put(key, queue);
		}
		return queue;
	}
	
	public String getKeyQueue(String bean){

		Iterator<Entry<String, LinkedList<HashMap<String, HashMap<String, Object>>>>> iterator = getStore().entrySet().iterator();
		boolean found=false;
		LinkedList<HashMap<String, HashMap<String, Object>>> queue = null;
		String key=null;;
		while (iterator.hasNext() && !found) {
			Map.Entry mapEntry = (Map.Entry) iterator.next();
			queue = (LinkedList<HashMap<String, HashMap<String, Object>>>) mapEntry.getValue();
			key = (String) mapEntry.getKey();;
			if (key!=null && queue.size()>0 && queue.peek().containsKey(bean)){
				found=true;
			}
		}
		return key;
	}
	
	public HashMap<String, Object> getFilter(String menuItem, String bean){
		LinkedList<HashMap<String,HashMap<String,Object>>> queue = getQueue(menuItem);
		
		if (queue.peekLast()!=null && (queue.peekFirst()).containsKey(bean)){
			return (HashMap<String, Object>) (queue.pop()).get(bean);
		}
		return null;
	}
	
	public void addFilter(String menuItem, String bean, HashMap<String,Object> filter){
		HashMap<String, HashMap<String, Object>> map = new HashMap<String,HashMap<String, Object>>();
		map.put(bean, filter);
		getQueue(menuItem).push(map);
	}
	
	public void clearqueue(String menuItem){
		getQueue(menuItem).clear();
	}
	
	
}
