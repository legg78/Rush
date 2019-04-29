package ru.bpc.sv2.acs.util;

public class ConvToDer {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		new ConvToDer().conv("CFEEF9262483B8D25E0D62695CF25154F498A8D0D150C8B593E074EBA6572704A5377E069FDF338D915D265EC581A8E719F29841A5F41982A0B7BB16EC8FC1261BCA4F10E2355CAEF61E1BEFB82990D21A9811B46F88A0BE2173E17C4299EBB7A596CBFBB9D5C60400278C38011EE559DDE3773377911788B4A8D414BB1DD23B");
	}
	public String conv(String key){
		String [] keys = new String[2];
		keys[0]=key;
		keys[1]="03";
		return toDer(keys,null,null);
	}
	public String toDer(String[] p_Values , String[] p_Tags , String p_Constructed_Tag){
		String v_Tag;
		if (p_Constructed_Tag==null) p_Constructed_Tag="30";
		String Default_Primitive_Tag = "02";
		StringBuffer v_Result = new StringBuffer();
		for (int i=0; i <= p_Values.length-1; i++){
			if(p_Tags!=null && p_Tags.length>=i)
				v_Tag=p_Tags[i];
			else 
				v_Tag=Default_Primitive_Tag;
			
			v_Result.append(fn_Encode_DER(p_Values[i],v_Tag));
		}
		if (p_Values.length > 1){
			String temp = v_Result.toString();
			return fn_Encode_DER(v_Result.toString(), p_Constructed_Tag);
		}
		
		return v_Result.toString();
	}

	public String fn_Encode_DER(String p_Value, String p_Tag){
		StringBuffer v_Result = new StringBuffer();
		if (!ConvertUtil.fn_Is_Byte_Multiple(p_Value)) return null;
		if (ConvertUtil.length_NVL(p_Tag)/2>1) return null;
		
		String v_DER_Length= fn_Get_DER_Length(p_Value);
		
		v_Result.append(p_Tag).append(v_DER_Length).append(p_Value);
		return v_Result.toString();
	}

	public String fn_Get_DER_Length(String p_Value){
		String v_Result;
		int v_Length = ConvertUtil.length_NVL(p_Value)/2;
		String v_Length_hex = ConvertUtil.fn_Get_Str_Padded_to_Byte_Len(Integer.toHexString(v_Length),null,null,null);
		if (v_Length>127){
			int v_Bytes_Count = ConvertUtil.length_NVL(v_Length_hex)/2;
			if (v_Bytes_Count > 127) return null;
			v_Result = String.valueOf(80 | v_Bytes_Count) + v_Length_hex;
		}
		else
        	v_Result = v_Length_hex;
		return v_Result;
	}

}