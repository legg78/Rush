package ru.bpc.sv2.utils;

import java.util.ArrayList;
import java.util.List;

import ru.bpc.sv2.common.TreeNode;

public class TreeUtils {
	public static <T extends TreeNode> int fillTreeByIndex(int startIndex,
			List<T> tree, List<T> floatList) {
		int i = 0;
		if (floatList.isEmpty()){
			return i;
		}
		int level = floatList.get(startIndex).getLevel();

		for (i = startIndex; i < floatList.size(); i++) {
			if (floatList.get(i).getLevel() != level) {
				break;
			}
			tree.add(floatList.get(i));
			if ((i + 1) != floatList.size()
					&& floatList.get(i + 1).getLevel() > level) {
				floatList.get(i).setChildren(new ArrayList<T>());
				i = fillTreeByIndex(i + 1, floatList.get(i).getChildren(), floatList);
			}
		}
		return i - 1;
	}
	
	public static <T extends TreeNode> List<T> fillTree(List<T> floatList){
		List<T> treeList = new ArrayList<T>();
		fillTreeByIndex(0,treeList,floatList);
		return treeList;
	}
}
