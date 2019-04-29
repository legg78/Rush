package ru.bpc.sv2.invocation;

import java.util.ArrayList;
import java.util.List;

public class AbstractTreeIdentifiable<T extends AbstractTreeIdentifiable> implements TreeIdentifiable<T> {
	private Long id;
	private T parent;
	private List<T> children = new ArrayList<T>();

	@Override
	public int getLevel() {
		return getParent() == null ? 0 : getParent().getLevel() + 1;
	}

	@Override
	public List<T> getChildren() {
		return children;
	}

	@Override
	public void setChildren(List<T> children) {
		this.children = children;
		for (T child : children) {
			//noinspection unchecked
			child.setParent(this);
		}
	}

	public void addChild(T child) {
		//noinspection unchecked
		child.setParent(this);
		getChildren().add(child);
	}

	public boolean isFirstChild() {
		return getParent() == null || getParent().getChildren().indexOf(this) == 0;
	}

	@Override
	public boolean isHasChildren() {
		return getChildren() != null && !getChildren().isEmpty();
	}

	public T getParent() {
		return parent;
	}

	public void setParent(T parent) {
		this.parent = parent;
	}

	@Override
	public Long getParentId() {
		return null;
	}

	@Override
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	@Override
	public Long getModelId() {
		return getId();
	}
}
