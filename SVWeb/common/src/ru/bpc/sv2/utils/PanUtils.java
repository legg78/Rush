package ru.bpc.sv2.utils;

public class PanUtils {
	public static String mask(String pan) {
		if (pan != null && pan.length() >= 6) {
			StringBuilder sb = new StringBuilder(pan.substring(0, 6));
			while (sb.length() < pan.length() - 4) {
				sb.append('*');
			}
			sb.append(pan.substring(pan.length() - 4));
			return sb.toString();
		}
		return pan;
	}
}
