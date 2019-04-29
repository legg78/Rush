package ru.bpc.sv2.ui.process;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.openfaces.util.Faces;

import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessParameter;
import ru.bpc.sv2.process.ProcessStatSummary;

public class ContainerLaunchData {

	private List<ProcessBO> containerTree = new ArrayList<ProcessBO>();
	private List<ProcessBO> containerList;
	private ProcessBO currentStructureItem;
	private ProcessParameter[] processParameters;
	private Date processDate = new Date();
	private boolean inProcessing = false;
	private List<ProcessStatSummary> processStatistics;

	public List<ProcessBO> getStructNodeChildren() {
		ProcessBO structureItem = getStructureItem();
		if (structureItem == null) {
			return containerTree;
		} else {
			return structureItem.getChildren();
		}
	}

	public boolean getStructNodeHashChildren() {
		return (getStructureItem() != null) && getStructureItem().hasChildren();
	}

	private ProcessBO getStructureItem() {
		return (ProcessBO) Faces.var("structureItem");
	}

	private void loadContainerTree() {
		if (containerList != null && containerList.size() > 0) {
			fillBranches(0, containerTree, containerList);
		}
	}

	private int fillBranches(int startIndex, List<ProcessBO> branches,
			List<ProcessBO> source) {
		int i;
		int level = source.get(startIndex).getLevel();

		for (i = startIndex; i < source.size(); i++) {
			if (source.get(i).getLevel() != level) {
				break;
			}
			branches.add(source.get(i));
			if ((i + 1) != source.size()
					&& source.get(i + 1).getLevel() > level) {
				source.get(i).setChildren(new ArrayList<ProcessBO>());
				i = fillBranches(i + 1, source.get(i).getChildren(), source);
			}
		}
		return i - 1;
	}

	// ///

	public void setContainerList(List<ProcessBO> containerList) {
		this.containerList = containerList;
		loadContainerTree();
	}

	public ProcessBO getCurrentStructureItem() {
		return currentStructureItem;
	}

	public void setCurrentStructureItem(ProcessBO currentStructureItem) {
		this.currentStructureItem = currentStructureItem;
	}

	public ProcessParameter[] getProcessParameters() {
		return processParameters;
	}

	public void setProcessParameters(ProcessParameter[] processParameters) {
		this.processParameters = processParameters;
	}

	public Date getProcessDate() {
		return processDate;
	}

	public void setProcessDate(Date processDate) {
		this.processDate = processDate;
	}

	public boolean isInProcessing() {
		return inProcessing;
	}

	public void setInProcessing(boolean inProcessing) {
		this.inProcessing = inProcessing;
	}
	
	public List<ProcessBO> getContainerTree() {
		return containerTree;
	}

	public List<ProcessStatSummary> getProcessStatistics() {
		return processStatistics;
	}

	public void setProcessStatistics(List<ProcessStatSummary> processStatistics) {
		this.processStatistics = processStatistics;
	}
}
