package ru.bpc.sv2.scheduler.process.files.incoming;

import java.util.ArrayList;
import java.util.List;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

public class AppSaxHandler extends DefaultHandler {
 
	//List to hold Employees object
    private List<String> appsList = null;
    private boolean isApplicationElement = false;
    private StringBuilder builder = new StringBuilder();
    private StringBuilder attrsBuilder = new StringBuilder();
    
    //getter method for apps list
    public List<String> getAppsList() {
        return appsList;
    }
    
    boolean isParsing = false;
    
    @Override
    public void startElement(String uri, String localName, String qName, Attributes attributes)
            throws SAXException {
    	
        if ("application".equalsIgnoreCase(qName)) {
        	isParsing = true;
        	builder = new StringBuilder();
        	builder.append("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
            //initialize list
        	isApplicationElement = true;
            if (appsList == null)
            	appsList = new ArrayList<String>();
        } else {
        	isApplicationElement = false;
        }
        
    	if (isParsing) {
    		attrsBuilder = new StringBuilder();
    		for (int i = 0; i < attributes.getLength(); i++) {
    			String val = attributes.getValue(i);
    			if (val != null && val != "") {
    				attrsBuilder.append(attributes.getQName(i)).append("=\"").append(val).append("\" ");
    			}
    		}
    		if (attrsBuilder.length() > 0) {
    			builder.append("<" + qName + " " + attrsBuilder.toString() + ">");
    		} else {
    			builder.append("<" + qName + ">");
    		}
        }

    }
 
 
    @Override
    public void endElement(String uri, String localName, String qName) throws SAXException {
        if (isParsing) {
            builder.append("</" + qName + ">");
        }
        if ("application".equalsIgnoreCase(qName)) {
        	appsList.add(builder.toString());
            isParsing = false;
        }
    }
 
 
    @Override
    public void characters(char ch[], int start, int length) throws SAXException { 
    	 if (isParsing) {
    		 String str = new String(ch, start, length);
             builder.append(str);
             if ("&".equals(str)) {
            	 builder.append("amp;");
             }
         }
    }

}
