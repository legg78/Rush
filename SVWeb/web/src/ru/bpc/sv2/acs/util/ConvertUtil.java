package ru.bpc.sv2.acs.util;

public class ConvertUtil {

	public static boolean fn_Is_Byte_Multiple(String str){
		int i = str.length();
		int k = i%2;
		if (str.length()%2==1) return false;
		else return true;
	}
	
	public static int length_NVL(String str){
		if (str==null) return 0;
		else return str.length(); 
	}

	public static String fn_Get_Str_Padded_to_Byte_Len(String p_Str, 
													   Long p_Length_Bytes, 
													   String p_Pad_Symbol,
													   Boolean p_Rightpad){
		
		if (p_Pad_Symbol==null) p_Pad_Symbol="0";
		if (p_Rightpad==null) p_Rightpad=Boolean.FALSE;
		
		StringBuffer str = new StringBuffer();
		if (p_Rightpad) str.append(p_Str);
		
		long v_Length = (p_Length_Bytes!=null)?p_Length_Bytes/2:(p_Str.length()%2);
		
		for (int i=0; i<=v_Length-1; i++)
			str.append(p_Pad_Symbol);
		
		if (p_Rightpad) 
			return str.toString();

		return str.append(p_Str).toString();
	}
	

}
