package ru.bpc.sv2.scheduler.process.external.svng;

import java.io.CharArrayReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.io.StringWriter;
import java.io.Writer;
import java.util.HashMap;
import java.util.Map;

import javax.xml.namespace.QName;
import javax.xml.stream.XMLEventFactory;
import javax.xml.stream.XMLEventReader;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamConstants;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;
import javax.xml.stream.events.XMLEvent;
import javax.xml.stream.util.StreamReaderDelegate;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;

public class SvngPackageParser {
	private StringBuffer path;
	private XMLStreamReader eventReader;
	private boolean isWriteTo;
	private Map<String, String> mq_envelopment;
	char [] buff;
	StringReader message;
	
	private static final Logger logger = Logger.getLogger("PROCESSES");
	
	public SvngPackageParser() throws XMLStreamException{
		mq_envelopment = new HashMap<String, String>();
		mq_envelopment.put("/pack/header/data-type" ,"");
		mq_envelopment.put("/pack/header/session-id", "");
        mq_envelopment.put("/pack/header/file-name", "");
        mq_envelopment.put("/pack/header/number", "");
        mq_envelopment.put("/pack/header/packs-total", "");
        mq_envelopment.put("/pack/header/records-number", "");
        mq_envelopment.put("/pack/header/records-total", "");
        mq_envelopment.put("/pack/header/additional-inf", "");
		path = new StringBuffer();
	}
	
	public void parse(InputStream in) throws XMLStreamException, IOException{
		XMLInputFactory inFactory = XMLInputFactory.newInstance();
	    XMLEventReader eventReader = inFactory.createXMLEventReader(in);
	    
	    XMLEventFactory eventFactory = XMLEventFactory.newInstance();
	    boolean nBody = false;
	    while (eventReader.hasNext()) {
	        XMLEvent event = eventReader.nextEvent();

	        switch(event.getEventType())
		    {
		        case XMLStreamConstants.START_DOCUMENT:
		          
		          break;
		        case XMLEvent.START_ELEMENT:
			        QName qname = event.asStartElement().getName();
			        String localName = qname.getLocalPart();
			        path.append("/");
			        path.append(localName);
			        if (path.toString().equalsIgnoreCase("/pack/body")){
			        	isWriteTo = true;
			        	
			        }
			        break;
		        case XMLEvent.CHARACTERS:
		        	if(mq_envelopment.containsKey(path.toString())){
		        		mq_envelopment.put(path.toString(), event.asCharacters().getData());
		        	}
		        	if(isWriteTo && !event.asCharacters().isWhiteSpace()){
		        		System.out.println(event.asCharacters().getData().trim());
		        		message = new StringReader(event.asCharacters().getData().trim());
		        		isWriteTo = false;
		        	}
		        	break;
		        case XMLEvent.CDATA:
		        	if(isWriteTo && !event.asCharacters().isWhiteSpace()){
		        		message = new StringReader(event.asCharacters().getData().trim());
//		        		logger.debug("-------------------------receive message--------------------------------------");
//		        		logger.debug(event.asCharacters().getData().trim());
//		        		logger.debug("-------------------------------------------------------------------");
		        		isWriteTo = false;
		        	}
		        	break;
		        case XMLEvent.END_ELEMENT:
		        	if (path.toString().equalsIgnoreCase("/pack/body")){
			        	isWriteTo = false;
			        }
		        	path.setLength(path.lastIndexOf("/"));
		          break;
		        case XMLStreamConstants.END_DOCUMENT:
		        	int i =0;
		        	i++;
		          break;
		    }
	    }
	}
	
	public StringReader getMessage(){
		return message;
	}
	
	public String getDateType(){
		return mq_envelopment.get("/pack/header/data-type");
	}
	
	public String getSessionId(){
		return mq_envelopment.get("/pack/header/session-id");
	}
	
	public String getFileName(){
		return FilenameUtils.getName(mq_envelopment.get("/pack/header/file-name"));
	}
	
	public Integer getNumber(){
		if(mq_envelopment.get("/pack/header/number").isEmpty()){
			return 0;
		}
		return Integer.valueOf(mq_envelopment.get("/pack/header/number"));
	}
	
	public Integer getPacksTotal(){
		if(mq_envelopment.get("/pack/header/packs-total").isEmpty()){
			return 0;
		}
		return Integer.valueOf(mq_envelopment.get("/pack/header/packs-total"));
	}
	
    public Integer getRecordsNumber(){
    	if(mq_envelopment.get("/pack/header/records-number").isEmpty()){
			return 0;
		}
    	return Integer.valueOf(mq_envelopment.get("/pack/header/records-number"));
    }
    
    public Integer getRecordsTotal(){
    	if(mq_envelopment.get("/pack/header/records-total").isEmpty()){
			return 0;
		}
    	return Integer.valueOf(mq_envelopment.get("/pack/header/records-total"));
    }
    
    public String getAdditionalInf(){
    	return mq_envelopment.get("/pack/header/additional-inf");
    }

	public void remove(InputStream in, Long sessionIdClean) throws XMLStreamException {
		logger.debug("remove");
		boolean sessionIdPass  = false;
		boolean sessionIsValid = false;
		XMLInputFactory inFactory = XMLInputFactory.newInstance();
	    XMLEventReader eventReader = inFactory.createXMLEventReader(in);
	    
	    while (eventReader.hasNext()) {
	        XMLEvent event = eventReader.nextEvent();

	        switch(event.getEventType())
		    {
		        case XMLStreamConstants.START_DOCUMENT:
		          
		          break;
		        case XMLEvent.START_ELEMENT:
		        	logger.debug("start element");
			        QName qname = event.asStartElement().getName();
			        String localName = qname.getLocalPart();
			        path.append("/");
			        path.append(localName);
			        if (path.toString().equalsIgnoreCase("/pack/body")){
			        	isWriteTo = true;
			        }
			        
			        if (path.toString().equalsIgnoreCase("/pack/header/session-id")){
			        	sessionIdPass = true;
		        		
			        	
			        }
			        
			        break;
		        case XMLEvent.CHARACTERS:
		        	if (sessionIdPass){
		        		logger.debug("pass check on session_Id");
		        		sessionIdPass = false;
		        		String sessionIdCurrentMessage = event.asCharacters().getData();
		        		logger.debug(sessionIdCurrentMessage);
		        		if (sessionIdCurrentMessage.equalsIgnoreCase(sessionIdClean.toString())){
		        			sessionIsValid = true;
		        		}
		        	}
		        	if(mq_envelopment.containsKey(path.toString())){
		        		mq_envelopment.put(path.toString(), event.asCharacters().getData());
		        	}
		        	
		        	if(isWriteTo && sessionIsValid && !event.asCharacters().isWhiteSpace()){
		        		System.out.println(event.asCharacters().getData().trim());
		        		message = new StringReader(event.asCharacters().getData().trim());
		        		isWriteTo = false;
		        		sessionIsValid  = false;
		        	}
		        	break;
		        case XMLEvent.CDATA:
		        	if(isWriteTo && !event.asCharacters().isWhiteSpace()){
		        		message = new StringReader(event.asCharacters().getData().trim());
		        		logger.debug("-------------------------receive message--------------------------------------");
		        		logger.debug(event.asCharacters().getData().trim());
		        		logger.debug("-------------------------------------------------------------------");
		        		isWriteTo = false;
		        		sessionIdPass  = false;
		        	}
		        	break;
		        case XMLEvent.END_ELEMENT:
		        	if (path.toString().equalsIgnoreCase("/pack/body")){
			        	isWriteTo = false;
			        	sessionIdPass  = false;
			        }
		        	path.setLength(path.lastIndexOf("/"));
		          break;
		        case XMLStreamConstants.END_DOCUMENT:
		        	int i =0;
		        	i++;
		          break;
		    }
	    }
		
	}

}
