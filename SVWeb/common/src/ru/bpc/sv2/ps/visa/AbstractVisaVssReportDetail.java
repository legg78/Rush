package ru.bpc.sv2.ps.visa;

import ru.bpc.sv2.invocation.AbstractTreeIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.concurrent.atomic.AtomicLong;

public abstract class AbstractVisaVssReportDetail<T extends AbstractVisaVssReportDetail<T>> extends AbstractTreeIdentifiable<T> implements Serializable {

	private static final long serialVersionUID = 1L;
	private static AtomicLong fakeId = new AtomicLong(0);
	private String text;
	private boolean expandCollapseNode;

	public String getText() {
		return text;
	}

	public void setText(String text) {
		this.text = text;
	}

	@Override
	public void addChild(T child) {
		if (child.getId() == null)
			child.assignFakeId();
		super.addChild(child);
	}

	public void assignFakeId() {
		if (getId() == null)
			setId(fakeId.addAndGet(-1));
	}

	public abstract boolean hasValues();

	public boolean hasValue(BigDecimal num) {
		return num != null;// && num.compareTo(BigDecimal.ZERO) != 0;
	}

	public boolean hasValue(Long num) {
		return num != null;// && num != 0;
	}

	public boolean isExpandCollapseNode() {
		return expandCollapseNode;
	}

	public void setExpandCollapseNode(boolean expandCollapseNode) {
		this.expandCollapseNode = expandCollapseNode;
	}

	@Override
	public String toString() {
		return getModelId() + ": " + getText();
	}
}
