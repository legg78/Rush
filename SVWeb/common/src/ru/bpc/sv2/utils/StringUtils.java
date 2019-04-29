package ru.bpc.sv2.utils;

public class StringUtils {
	static final byte[] HEX_CHAR_TABLE = {
	    (byte)'0', (byte)'1', (byte)'2', (byte)'3',
	    (byte)'4', (byte)'5', (byte)'6', (byte)'7',
	    (byte)'8', (byte)'9', (byte)'A', (byte)'B',
	    (byte)'C', (byte)'D', (byte)'E', (byte)'F'
	  };    

	/**
	 * Fast convert of byte array to hex string 
	 * @param raw
	 * @return hex string	 
	 */
	  public String getHexString1(byte[] raw)
	  {
	    byte[] hex = new byte[2 * raw.length];
	    int index = 0;

	    for (byte b : raw) {
	      int v = b & 0xFF;
	      hex[index++] = HEX_CHAR_TABLE[v >>> 4];
	      hex[index++] = HEX_CHAR_TABLE[v & 0xF];
	    }
	    return new String(hex);
	  }

	  static final String HEXES = "0123456789ABCDEF";
	  /**
	   * Slow convert of byte array to hex string 
	   * @param raw
	   * @return hex string		 
	   */
	  public String getHexString2( byte [] raw ) {
	    if ( raw == null ) {
	      return null;
	    }
	    final StringBuilder hex = new StringBuilder( 2 * raw.length );
	    for ( final byte b : raw ) {
	      hex.append(HEXES.charAt((b & 0xF0) >> 4))
	         .append(HEXES.charAt((b & 0x0F)));
	    }
	    return hex.toString();
	  }

	  public String getHexString3( byte [] raw ) {
		    if ( raw == null ) {
		      return null;
		    }
		    String hex = new String();
		    for(int i = 0; i < raw.length; i++){
		    	hex+=Integer.toHexString((int)raw[i]);
		    }
		    return hex.toString();
		  }
}
