package ru.bpc.sv2.scheduler.process.svng;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;
import java.util.Map;

import javax.xml.stream.XMLStreamReader;

public class SplitXmlContent {
	private String tag;
	private BufferedReader br;
	private StringBuilder header;
	private StringBuilder footer = new StringBuilder();
	private StringBuilder store = new StringBuilder();
	
	XMLStreamReader streamReader;
	
	public SplitXmlContent(Reader reader, String tag, String footer){
		
		br = new BufferedReader(reader);
		this.tag = tag;
		try {
			fillHeader();
			this.footer.append("</").append(footer).append(">");
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public StringBuilder getXml(Map<String, Integer> params) throws IOException{
		StringBuilder temp = new StringBuilder();
		temp.append(header);
		boolean isBegin = false;
		params.put("outNumber", 0);
		
		synchronized( this ) {
			if(store.length()>0){
				Reader reader = new StringReader(store.toString());
				temp.append(getBody(params, new BufferedReader(reader), isBegin));
				isBegin = true;
			}
			
			temp.append(getBody(params, br, isBegin));
		}
		
		temp.append(footer);
		return temp;
	}
	
	public String getBody(Map<String, Integer> params, BufferedReader breader, boolean isBegin) throws IOException{
		Integer inNumber = params.get("inNumber");
		Integer outNumber = params.get("outNumber");
		StringBuilder line = new StringBuilder();
		StringBuffer temp = new StringBuffer();
		boolean loop = true;
		int count = 0;
		int end = -1;
		int index = 0;
		
		while (loop && (line.append(breader.readLine()).indexOf("null") != 0)) {
			temp.append(line);
			
			while ((index = temp.indexOf("</" + tag + ">", end)) > 0 && count < inNumber){
				end = index + tag.length() + 3;
				count++;
			}
			if(count == inNumber){
				loop = false;
			}
			line.setLength(0);
	    }
		outNumber = outNumber + count;
		params.put("outNumber", outNumber);
		if(temp.length() == 0){
			return "";
		}
		int start = (isBegin)? 0 : temp.indexOf("<" + tag);

		if(start<0) {
			start = 0;
		}

		if(end > 0){
			store.setLength(0);
			store.append(temp.substring(end));
			return temp.substring(start, end);
		}
		return temp.substring(start);
	}
	
	public void fillHeader() throws IOException{
		
		StringBuilder line = new StringBuilder();
		header = new StringBuilder();
		boolean isHeader = true;
		int i;
		int j;
		while (isHeader && line.append(br.readLine()).indexOf("null") != 0) { // while loop begins here
			i = 0;
			j = 0;
			
			if((i=line.indexOf("<"+tag+" "))>0 || (i=line.indexOf("<"+tag+">"))>0){
				if(isHeader){
					header.append(line.substring(0, i));
					isHeader = false;
					store.append(line.substring(i));
				}
			}

			if(isHeader){
				header.append(line);
			}
			line.setLength(0);
	    }
	}
}
