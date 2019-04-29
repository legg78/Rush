package ru.bpc.sv2.fcl.cycles;

import java.io.Serializable;
import java.util.List;

import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.invocation.TreeIdentifiable;

public class TreeCycleCounter extends CycleCounter implements Serializable, TreeIdentifiable<TreeCycleCounter>, ModelIdentifiable, Cloneable{

	private static final long serialVersionUID = 1L;
	private String name;
	private Long parentId;
	private int level;
	private boolean isLeaf;
	private List<TreeCycleCounter> children;
	
	
	public TreeCycleCounter() {
		
	}
	
	public TreeCycleCounter(CycleCounter counter) {
		super(counter);
	}
	
	public Object getModelId() {
		return getId();
	}

	public List<TreeCycleCounter> getChildren() {
		return children;
	}

	public void setChildren(List<TreeCycleCounter> children) {
		this.children = children;
	}
	
	public boolean isHasChildren() {
		return children != null ? children.size() > 0 : false;
	}
	
	
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((getId() == null) ? 0 : getId().hashCode());
		result = prime * result + level;
		result = prime * result
				+ ((parentId == null) ? 0 : parentId.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		TreeCycleCounter other = (TreeCycleCounter) obj;
		if (getId() == null) {
			if (other.getId() != null)
				return false;
		} else if (!getId().equals(other.getId()))
			return false;		
		
		return true;
	}
	
	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public boolean isLeaf() {
		return isLeaf;
	}

	public void setLeaf(boolean isLeaf) {
		this.isLeaf = isLeaf;
	}

	@Override
	public Long getParentId() {
		return parentId;
	}

	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
	
	@Override
	public TreeCycleCounter clone(){
		TreeCycleCounter result = null;
		Object cloneCounter = super.clone();
		result = (TreeCycleCounter)cloneCounter; 
		return result;
	}	
}
