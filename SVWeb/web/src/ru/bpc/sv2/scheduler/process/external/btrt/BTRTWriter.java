package ru.bpc.sv2.scheduler.process.external.btrt;

import java.io.IOException;
import java.io.Writer;
import java.util.List;

import ru.bpc.sv2.process.btrt.NodeItem;

public class BTRTWriter {
	private NodeItem node;

	public BTRTWriter(NodeItem node) {
		this.node = node;
	}

	public void write(Writer writer) throws IOException {
		calculateLength(node);
		write(writer, node);
	}

	private void write(Writer writer, NodeItem node) throws IOException {
		writer.write(node.getName());
		int decLen = node.getLength();
		if (decLen >= 0x80 && decLen < 0x8000)
			decLen += 0x8000;
		String hexLen = Integer.toHexString(decLen).toUpperCase();
		if (decLen < 0x10) {
			hexLen = "0" + hexLen;
		}
		writer.write(hexLen);
		if (!node.getChildren().isEmpty()) {
			for (NodeItem child : node.getChildren()) {
				write(writer, child);
			}
		}
		if (node.getData() != null) {
			writer.write(node.getData());
		}
	}

	private void calculateLength(NodeItem node) {
		int length = 0;
		if (!node.getChildren().isEmpty()) {
			for (NodeItem child : node.getChildren()) {
				calculateLength(child);
				length += child.getLength();
				if (child.getLength() >= 0x80
						&& child.getLength() < 0x8000) {
					length += 4;
				} else {
					length += 2;
				}
				length += child.getName().length();
			}
		}
		if (node.getData() != null) {
			length += node.getData().length();
		}
		node.setLength(length);
	}
}
