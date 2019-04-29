package ru.bpc.sv2.io;

import java.io.IOException;
import java.io.InputStream;

import javax.jms.BytesMessage;
import javax.jms.JMSException;
import javax.jms.MessageEOFException;


public class BytesMessageInputStream extends InputStream {
	
	private final BytesMessage message;
	
	public BytesMessageInputStream(BytesMessage message) {
	    this.message = message;
	}

	@Override
	public int read(byte b[]) throws IOException {
	    try {
	        return message.readBytes(b);
	    }
	    catch (JMSException ex) {
	        ex.printStackTrace();
	    }
		return 0;
	}

	@Override
	public int read(byte b[], int off, int len) throws IOException {
	    if (off == 0) {
	        try {
	            return message.readBytes(b, len);
	        }
	        catch (JMSException ex) {
	        	ex.printStackTrace();
	        }
	    }
	    else {
	        return super.read(b, off, len);
	    }
		return len;
	}

	@Override
	public int read() throws IOException {
	    try {
	        return message.readByte();
	    }
	    catch (MessageEOFException ex) {
	        return -1;
	    }
	    catch (JMSException ex) {
	    	ex.printStackTrace();
	    }
		return 0;
	}

}
