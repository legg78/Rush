package ru.bpc.sv2.scheduler.process.mc.entity;

import ru.bpc.sv2.scheduler.process.mc.utils.EncodingSpec;

import java.nio.charset.Charset;
import java.util.HashMap;
import java.util.Map;

public class MCFieldsConfig {
	private Map<Integer, FieldConfig> fields= new HashMap<Integer, FieldConfig>();
	private String ENCODE = "CP037";
	private EncodingSpec encodingSpec;
	public MCFieldsConfig(){
		fields.put(1, new FieldConfig(true, 8));
		fields.put(2, new FieldConfig(false, 2));
		fields.put(3, new FieldConfig(true, 6));
		fields.put(4, new FieldConfig(true, 12));
		fields.put(5, new FieldConfig(true, 12));
		fields.put(6, new FieldConfig(true, 12));
		fields.put(9, new FieldConfig(true, 8));
		fields.put(10, new FieldConfig(true, 8));
		fields.put(12, new FieldConfig(true, 12));
		fields.put(14, new FieldConfig(true, 4));
		fields.put(22, new FieldConfig(true, 12));
		fields.put(23, new FieldConfig(true, 3));
		fields.put(24, new FieldConfig(true, 3));
		fields.put(25, new FieldConfig(true, 4));
		fields.put(26, new FieldConfig(true, 4));
		fields.put(30, new FieldConfig(true, 24));
		fields.put(31, new FieldConfig(false, 2));
		fields.put(32, new FieldConfig(false, 2));
		fields.put(33, new FieldConfig(false, 2));
		fields.put(37, new FieldConfig(true, 12));
		fields.put(38, new FieldConfig(true, 6));
		fields.put(40, new FieldConfig(true, 3));
		fields.put(41, new FieldConfig(true, 8));
		fields.put(42, new FieldConfig(true, 15));
		fields.put(43, new FieldConfig(false, 2));
		fields.put(48, new FieldConfig(false, 3));
		fields.put(49, new FieldConfig(true, 3));
		fields.put(50, new FieldConfig(true, 3));
		fields.put(51, new FieldConfig(true, 3));
		fields.put(54, new FieldConfig(false, 3));
		fields.put(55, new FieldConfig(false, 3));
		fields.put(62, new FieldConfig(false, 3));
		fields.put(63, new FieldConfig(false, 3));
		fields.put(71, new FieldConfig(true, 8));
		fields.put(72, new FieldConfig(false, 3));
		fields.put(73, new FieldConfig(true, 6));
		fields.put(93, new FieldConfig(false, 2));
		fields.put(94, new FieldConfig(false, 2));
		fields.put(95, new FieldConfig(false, 2));
		fields.put(100, new FieldConfig(false, 2));
		fields.put(111, new FieldConfig(false, 3));
		fields.put(123, new FieldConfig(false, 3));
		fields.put(124, new FieldConfig(false, 3));
		fields.put(125, new FieldConfig(false, 3));
		fields.put(127, new FieldConfig(false, 3));
	}
	
	public FieldConfig getField(Integer key){
		return fields.get(key);
	}
	
	public EncodingSpec getEncodeSpec(){
		if(encodingSpec == null){
			encodingSpec = new EncodingSpec( Charset.forName(ENCODE), 1 );
		}
		return encodingSpec;
	}
}
