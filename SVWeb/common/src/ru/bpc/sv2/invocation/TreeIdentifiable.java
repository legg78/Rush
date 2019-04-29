package ru.bpc.sv2.invocation;

import java.util.List;

public interface TreeIdentifiable<E> extends ModelIdentifiable {
	public int getLevel();
	public List<E> getChildren();
	public void setChildren(List<E> children);
	public boolean isHasChildren();

	public Long getParentId();
	public Long getId();
}
