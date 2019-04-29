package ru.bpc.sv2.ui.navigation;

import java.util.Iterator;
import java.util.Map.Entry;

import org.richfaces.model.TreeNode;

public class NavigationGroup
	extends RoleVisibility
{
	private final TreeNode<NavTreeElement> _branch;
	private final String _name;
	public NavigationGroup( String name, TreeNode<NavTreeElement> branch )
	{
		_branch = branch;
		_name = name;
	}

	public String getName()
	{
		return _name;
	}

	public TreeNode<NavTreeElement> getBranch()
	{
		return _branch;
	}
	
	public boolean contain(Long sectionId) {
		if (_branch == null || sectionId == null) {
			return false;
		}
		return contain(_branch, sectionId);			
	}
	
	private boolean contain(TreeNode<NavTreeElement> node, Long id) {
		boolean found = false;
		Iterator<Entry<Object, TreeNode<NavTreeElement>>> it = node.getChildren();
		while (it.hasNext()) {
			Entry<Object, TreeNode<NavTreeElement>> entry = it.next();
			TreeNode<NavTreeElement> elem = entry.getValue();
			if (id.equals(elem.getData().getId())) {
				found = true;				
			} else if (elem.getChildren() != null) {
				found = contain(elem, id);
			}
			if (found) {
				break;
			}
		}
		return found;	
	}
}
