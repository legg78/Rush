package ru.bpc.sv.ws.integration.handler;

import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import java.io.ByteArrayOutputStream;
import java.util.Set;
import java.util.Collections;
import javax.xml.namespace.QName;
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPEnvelope;
import javax.xml.soap.SOAPPart;
import javax.xml.ws.handler.soap.SOAPHandler;
import javax.xml.ws.handler.MessageContext;
import javax.xml.ws.handler.soap.SOAPMessageContext;
import javax.xml.soap.SOAPMessage;
/**
 * Created by Gasanov on 10.10.2016.
 */
public class InstantIssueHandler implements SOAPHandler<SOAPMessageContext>
{
    private static final Logger logger = Logger.getLogger("ISSUING");
    public Set<QName> getHeaders()
    {
        return Collections.emptySet();
    }

    public boolean handleMessage(SOAPMessageContext messageContext)
    {
        Boolean outboundProperty = (Boolean)
                messageContext.get (MessageContext.MESSAGE_OUTBOUND_PROPERTY);
        String operation = ((QName)messageContext.get (MessageContext.WSDL_OPERATION)).getLocalPart();

        if (outboundProperty.booleanValue() && operation.equalsIgnoreCase("unloadCardData")) {
            try {
                SOAPPart soapPart = messageContext.getMessage().getSOAPPart();
                SOAPEnvelope soapEnvelope = soapPart.getEnvelope();
                SOAPBody soapBody = soapEnvelope.getBody();
                NodeList unloadCardDataResponse = soapBody.getElementsByTagName("unloadCardDataResponse");
                if(unloadCardDataResponse.getLength() == 0){
                    return true;
                }
                Node child = unloadCardDataResponse.item(0);
                NodeList nList = child.getChildNodes();
                Document document = soapBody.getOwnerDocument();

                for (int temp = 0; temp < nList.getLength(); temp++) {

                    Node nNode = nList.item(temp);

                    if (nNode.getNodeType() == Node.ELEMENT_NODE &&
                            (nNode.getLocalName().equalsIgnoreCase("accountInfo") || nNode.getLocalName().equalsIgnoreCase("cardInfo"))) {
                        Element eElement = (Element) nNode;
                        Node node = document.createCDATASection(eElement.getTextContent());
                        nNode.removeChild(nNode.getFirstChild());
                        nNode.appendChild(node);
                    }
                }
            }catch (Exception e){
                logger.error(e);
            }

        }

        return true;
    }

    public boolean handleFault(SOAPMessageContext messageContext)
    {
        return true;
    }
    public void close(MessageContext messageContext)
    {
    }
}
