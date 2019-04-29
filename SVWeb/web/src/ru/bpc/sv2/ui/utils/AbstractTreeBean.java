package ru.bpc.sv2.ui.utils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.openfaces.component.table.ExpansionState;
import org.openfaces.component.table.TreePath;

import ru.bpc.sv2.invocation.TreeIdentifiable;

public abstract class AbstractTreeBean<E extends TreeIdentifiable<E>> extends AbstractBean {
	private static final long serialVersionUID = 8122806310626870998L;
	
	protected E currentNode;
	protected List<E> coreItems;
	protected boolean treeLoaded;
	protected TreePath nodePath;
	private ExpansionState expandLevel;

	protected int addNodes(int startIndex, List<E> branches, E[] items) {
//      int counter = 1;
		int i;
		int level = items[startIndex].getLevel();

		for (i = startIndex; i < items.length; i++) {
			if (items[i].getLevel() != level) {
				break;
			}
			branches.add(items[i]);
			if ((i + 1) != items.length && items[i + 1].getLevel() > level) {
				items[i].setChildren(new ArrayList<E>());
				i = addNodes(i + 1, items[i].getChildren(), items);
			}
//          counter++;
		}
		return i - 1;
	}
	
	protected TreePath formNodePath(E[] items) {
		ArrayList<E> pathElements = new ArrayList<E>();
		pathElements.add(currentNode);
		E node = currentNode;
		while (node.getParentId() != null) {
			boolean found = false;
			for (E item: items) {
				if (item.getId().equals(node.getParentId())) {
					pathElements.add(item);
					node = item;
					found = true;
					break;
				}
			}
			if (!found) break;	// to evade infinite loops if sor some reason parent is absent 
		}

		Collections.reverse(pathElements); // make current node last and its very first parent - first

		TreePath nodePath = null;
		for (E item: pathElements) {
			nodePath = new TreePath(item, nodePath);
		}

		return nodePath;
	}

	protected boolean isElementInTree(E element, List<E> tree) {
		return isElementInTree(element.getId(), tree);
	}

	protected boolean isElementInTree(Number elementId, List<E> tree) {
		if (tree != null) {
			for (E item : tree) {
				if (item.getId().equals(elementId)) {
					return true;
				}
				if (item.isHasChildren() && isElementInTree(elementId, item.getChildren())) {
					return true;
				}
			}
		}
		return false;
	}

	protected boolean addElementToParent(E element, List<E> tree, TreePath path) {
		for (E item: tree) {
			if (item.getId().equals(element.getParentId())) {
				if (!item.isHasChildren()) {
					item.setChildren(new ArrayList<E>());
				}
				currentNode = element;
				item.getChildren().add(0, currentNode);
				setNodePath(new TreePath(currentNode, new TreePath(item, path)));
				return true;
			}
			if (item.isHasChildren()
					&& addElementToParent(element, item.getChildren(), new TreePath(item, path))) {
				return true;
			}
		}
		return false;
	}

	protected void addElementToTree(E element) {
		if (element == null)
			return;

		if (element.getParentId() == null || !addElementToParent(element, coreItems, null)) {
			currentNode = element;
			coreItems.add(0, currentNode);
			setNodePath(new TreePath(currentNode, null));
		}
		treeLoaded = true;
	}

	protected void replaceCurrentNode(E newNode) {
		if ((currentNode.getParentId() == null && newNode.getParentId() != null)
				|| (currentNode.getParentId() != null
						&& !currentNode.getParentId().equals(newNode.getParentId()))) {
			deleteNodeFromTree(currentNode, coreItems);
			if (currentNode.isHasChildren()) {
				newNode.setChildren(currentNode.getChildren());
			}
			addElementToTree(newNode);
		} else {
			replaceNode(currentNode, newNode, coreItems);
			currentNode = newNode;
			setNodePath(new TreePath(currentNode, nodePath.getParentPath()));
		}
	}

	/**
	 * <p>
	 * Replaces node in tree.
	 * </p>
	 * 
	 * @param list
	 *            - list of tree's core elements
	 * @return true - if oldNode was replaced with newNode, false - otherwise.
	 */
	protected boolean replaceNode(E oldNode, E newNode, List<E> list) {
		for (E item: list) {
			if (item.getId().equals(oldNode.getId()) && item.getLevel() == oldNode.getLevel()) {
				if (item.isHasChildren()) {
					newNode.setChildren(item.getChildren());
				}
				int i = list.indexOf(item);
				list.remove(i);
				list.add(i, newNode);
				return true;
			}
			if (item.isHasChildren() && replaceNode(oldNode, newNode, item.getChildren())) {
				return true;
			}
		}
		return false;
	}

	protected boolean deleteNodeFromTree(E node, List<E> list) {
		for (E item: list) {
			if (item.getId().equals(node.getId())) {
				list.remove(item);
				return true;
			}
			if (item.isHasChildren() && deleteNodeFromTree(node, item.getChildren())) {
				return true;
			}
		}
		return false;
	}

	@SuppressWarnings("unchecked")
	protected void expandTreeByNodePath() {
		currentNode = (E) nodePath.getValue();
		ArrayList<TreePath> nodesToExpand = new ArrayList<TreePath>();
		nodesToExpand.add(nodePath);
		TreePath parent = nodePath.getParentPath();
		while (parent != null) {
			nodesToExpand.add(0, parent);
			parent = parent.getParentPath();
		}

		parent = null;
		for (TreePath path: nodesToExpand) {
			// actually curPath is useless, it's introduced only for
			// better readability :)
			TreePath curPath = new TreePath(((E) path.getValue()).getId(), parent);
			expandLevel.setNodeExpanded(curPath, true);
			parent = curPath;
		}
	}
	
	public E findInCoreItemsIfPossible(E node) {
		if (node == null) {
			return null;
		}
		E result = findInItems(coreItems, node);
		return result != null ? result : node;
	}

	public E findInItems(List<E> items, E node) {
		if (node != null && node.getModelId() != null) {
			for (E item : items) {
				if (node.getModelId().equals(item.getModelId())) {
					return item;
				}
				if (item.getChildren() != null) {
					E result = findInItems(item.getChildren(), node);
					if (result != null) {
						return result;
					}
				}
			}
		}
		return null;
	}

	public ExpansionState getExpandLevel() {
		return expandLevel;
	}

	public void setExpandLevel(ExpansionState expandLevel) {
		this.expandLevel = expandLevel;
	}

	abstract protected void loadTree();
	
	abstract public TreePath getNodePath();

	abstract public void setNodePath(TreePath nodePath);
}
