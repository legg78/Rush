package ru.bpc.sv2.scheduler.process.external.btrt;

import java.io.PrintStream;

import ru.bpc.sv2.process.btrt.BTRTMapping;
import ru.bpc.sv2.process.btrt.NodeItem;

public class BTRTReader {
	private static final int MAX_NAME_LENGTH = 3;
	private static final int MAX_LENGTH_LENGTH = 2;
	private static final int TRANSFORMING_DECIMAL = 32768;
	private String in;
	
	private static String[] HEX = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" };
	private static String[] BINARY = { "0000", "0001", "0010", "0011", "0100", "0101", "0110", "0111", "1000", "1001", "1010", "1011",
	        "1100", "1101", "1110", "1111" };
	public BTRTReader(String in){
		this.in = in;
	}
	
	public NodeItem read(){
		return read(in, null);
	}
	
	private NodeItem read(String input, NodeItem parentNode) {
		if ("".equals(input)) {
			return null;
		}

		NodeItem node = new NodeItem();
		node.setParent(parentNode);
		if (parentNode != null) {
			parentNode.getChildren().add(node);
		}
		// read a line to create a Tree object
		int start = 0, end = 0;
		for (int i = 0; i < MAX_NAME_LENGTH + MAX_LENGTH_LENGTH; i++) {
			String s = input.substring(end, end + 2);
			end += 2;
			if (hexToBin(s).charAt(0) == '0' || ((node.getName() == null) && (end - start == MAX_NAME_LENGTH * 2))
			        || ((null != node.getName()) && (end - start == MAX_LENGTH_LENGTH * 2))) {
				String value = input.substring(start, end);
				start = end;

				if (node.getName() == null) {
					node.setName(value);
				} else {
					node.setLength(computeLength(value));
					// if node has no data
					if (node.getName().startsWith("FF")) {
						read(input.substring(start, start + node.getLength()), node);
						read(input.substring(start + node.getLength()), parentNode);
					} else {
						end = start + node.getLength();
						node.setData(input.substring(start, end));
						read(input.substring(end), parentNode);
					}
					break;
				}
			}
		}

		return node;
	}
	
	public static String hexToBin(String userInput) {
		String result = "";
		for (int i = 0; i < userInput.length(); i++) {
			char temp = userInput.charAt(i);
			String temp2 = "" + temp + "";
			for (int j = 0; j < HEX.length; j++) {
				if (temp2.equalsIgnoreCase(HEX[j])) {
					result = result + BINARY[j];
				}
			}
		}
		return result;
	}
	
	private int computeLength(String length) {
		if ("".equals(length)) {
			return 0;
		}
		String firstChar = length.charAt(0) + "";
		int firstCharValue = hexToDec(firstChar);
		int result = hexToDec(length);
		return (firstCharValue > 7) ? (result - TRANSFORMING_DECIMAL) : result;
	}
	
	public static int hexToDec(String input) {
		return Integer.parseInt(input, 16);
	}
	
	public static void printToPrintStream(NodeItem node, PrintStream ps, String spaces) {
		ps.println(spaces + node.getName() + "-" + BTRTMapping.get(node.getName()) + "(" + node.getLength() + ")" + "=" + node.getData());
		spaces += "  ";
		for (NodeItem ni : node.getChildren()) {
			printToPrintStream(ni, ps, spaces);
		}
    }
	
	public static void printToConsole(NodeItem node, String spaces) {
		printToPrintStream(node, System.out, spaces);
	}
}
