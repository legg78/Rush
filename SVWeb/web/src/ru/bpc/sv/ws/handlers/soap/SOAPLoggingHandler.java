package ru.bpc.sv.ws.handlers.soap;

import java.io.ByteArrayOutputStream;
import java.util.Set;

import javax.xml.soap.SOAPEnvelope;
import javax.xml.soap.SOAPHeader;
import javax.xml.soap.SOAPMessage;
import javax.xml.ws.handler.MessageContext;
import javax.xml.ws.handler.MessageContext.Scope;
import javax.xml.ws.handler.soap.SOAPHandler;
import javax.xml.ws.handler.soap.SOAPMessageContext;

import org.apache.log4j.Logger;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class SOAPLoggingHandler implements SOAPHandler<SOAPMessageContext> {

	private Logger logger = Logger.getLogger("SVIP");
	public static final String MESSAGE_ID = "MessageID";
    public static final String REPLY_TO = "ReplyTo";
    public static final String FAULT_TO = "FaultTo";
	
	@SuppressWarnings("unchecked")
	public Set getHeaders() {
		return null;
	}

	public boolean handleMessage(SOAPMessageContext smc) {
		if(smc.get(REPLY_TO) != null){
			replyTo(smc, (String) smc.get(REPLY_TO));
		}
		log(smc);
		return true;
	}

	public boolean handleFault(SOAPMessageContext smc) {
		log(smc);
		return true;
	}

	// nothing to clean up
	public void close(MessageContext messageContext) {
	}

	/*
	 * Check the MESSAGE_OUTBOUND_PROPERTY in the context to see if this is an outgoing or incoming
	 * message. Write a brief message to the print stream and output the message. The writeTo()
	 * method can throw SOAPException or IOException
	 */
	private void log(SOAPMessageContext smc) {
		Boolean outboundProperty = (Boolean) smc.get(MessageContext.MESSAGE_OUTBOUND_PROPERTY);
		String str = "";
		if (outboundProperty.booleanValue()) {
			str = "Outbound message:";
		} else {
			str = "Inbound message:";
		}

		SOAPMessage message = smc.getMessage();
		ByteArrayOutputStream baos = null;
		try {
			baos = new ByteArrayOutputStream();
			message.writeTo(baos);
			logger.trace(str + baos.toString("UTF-8"));
		} catch (Exception e) {
		} finally {
			try {
				if (baos != null) {
					baos.close();
				}
			} catch (Exception e) {
			}
		}
	}
	
	public void replyTo(SOAPMessageContext context, String replyTo) {
        Boolean isOutbound = (Boolean) context.get(SOAPMessageContext.MESSAGE_OUTBOUND_PROPERTY);
        if (isOutbound) {
            try {
                SOAPEnvelope envelope = context.getMessage().getSOAPPart().getEnvelope();
                SOAPHeader header = envelope.getHeader();

                /* extract the generated MessageID */
                String messageID = String.valueOf(System.currentTimeMillis());//getMessageID(header);
                context.put(MESSAGE_ID, messageID);
                context.setScope(MESSAGE_ID,   Scope.APPLICATION);

                /* change ReplyTo address */
                NodeList nodeListReplyTo = header.getElementsByTagName(REPLY_TO);
                
                if(nodeListReplyTo == null || nodeListReplyTo.getLength() == 0){
                	return;
                }
                
    	        NodeList nodeListAddress = nodeListReplyTo.item(0).getChildNodes();
    	        for (int i = 0; i < nodeListAddress.getLength(); i++) {
    	            Node node = nodeListAddress.item(i);
    	            if ("Address".equals(node.getLocalName())) {
    	                node.setTextContent(replyTo);
    	                break;
    	            }
    	        }
    	        
    	        nodeListReplyTo = header.getElementsByTagName(FAULT_TO);
                
                if(nodeListReplyTo == null || nodeListReplyTo.getLength() == 0){
                	return;
                }
                
    	        nodeListAddress = nodeListReplyTo.item(0).getChildNodes();
    	        for (int i = 0; i < nodeListAddress.getLength(); i++) {
    	            Node node = nodeListAddress.item(i);
    	            if ("Address".equals(node.getLocalName())) {
    	                node.setTextContent(replyTo);
    	                break;
    	            }
    	        }
            } catch (Exception ex) {
                throw new RuntimeException(ex);
            }
        }
    }

	public void setLogger(Logger logger) {
		this.logger = logger;
	}
}