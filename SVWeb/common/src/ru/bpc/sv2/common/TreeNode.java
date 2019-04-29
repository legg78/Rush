package ru.bpc.sv2.common;

import java.util.List;

public interface TreeNode<T> {
	public int getLevel();
	public void setLevel(int level);
	
	public List<T> getChildren();
	public void setChildren(List<T> children);
}
