package ru.bpc.sv2.ui.reports.constructor.web;

import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import ru.bpc.sv2.ui.reports.constructor.dto.ParameterDto;
import ru.bpc.sv2.ui.reports.constructor.support.ReportCondition;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.jtsoft.dynamicreports.ReportingDataModel;
import ru.jtsoft.dynamicreports.report.BetweenConditionExpressionNode;
import ru.jtsoft.dynamicreports.report.ExpressionNode;
import ru.jtsoft.dynamicreports.report.ExpressionNodeList;
import ru.jtsoft.dynamicreports.report.InConditionExpressionNode;
import ru.jtsoft.dynamicreports.report.IsNullConditionExpressionNode;
import ru.jtsoft.dynamicreports.report.LogicalConditionExpressionNode;
import ru.jtsoft.dynamicreports.report.UnaryConditionExpressionNode;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Sonin on 16.05.2016.
 */
@ManagedBean(name="MbReportTemplateTree")
@ViewScoped
public class MbReportTemplateTree extends AbstractTreeBean<ReportCondition> {
    private ReportCondition reportConditions;
    private ExpressionNodeList expressionNodeList;
    private TreePath nodePath;
    private Long treeId = 0l;
    private ReportingDataModel dataModel;

    @Override
    protected void loadTree() {
        try {
            coreItems = new ArrayList<ReportCondition>();
            treeId = 0l;
            convert(0, null, expressionNodeList);
            refreshCurrentTreeRow();

            if (!searching)
                return;

            treeLoaded = true;
        } catch (Exception ee) {
            FacesUtils.addMessageError(ee);
        }
    }

    @Override
    public TreePath getNodePath() {
        return nodePath;
    }

    @Override
    public void setNodePath(TreePath nodePath) {
        this.nodePath = nodePath;

    }

    @Override
    public void clearFilter() {

    }

    public void setDataModel(ReportingDataModel dataModel) {
        this.dataModel = dataModel;
    }

    public ReportCondition getReportConditions() {
        return reportConditions;
    }

    public void setReportConditions(ReportCondition reportConditions) {
        this.reportConditions = reportConditions;
    }

    public ExpressionNodeList getExpressionNodeList() {
        return expressionNodeList;
    }

    public void setExpressionNodeList(ExpressionNodeList expressionNodeList) {
        this.expressionNodeList = expressionNodeList;
    }

    public void convert(int level, ReportCondition parentNode, ExpressionNodeList nodeList){
        for (ExpressionNode node : nodeList.getChildNodes()) {
            treeId++;
            ReportCondition condition = new ReportCondition();
            condition.setConditionNode(node);
            condition.setId(treeId);
            condition.setLevel(level);
            condition.setConditionNodeParent(nodeList);
            condition.setValues(new ArrayList<String>());

            if (nodeList.getRoot()!= null) {
                condition.setParentId(parentNode.getId());
                parentNode.getChildren().add(condition);
            }
            if (node instanceof BetweenConditionExpressionNode) {
                condition.setParameterId(((BetweenConditionExpressionNode) node).getParameterId());
                condition.setOperType(((BetweenConditionExpressionNode) node).getOperator());
                condition.getValues().add(((BetweenConditionExpressionNode) node).getValueLeft());
                condition.getValues().add(((BetweenConditionExpressionNode) node).getValueRight());
            } else if (node instanceof InConditionExpressionNode) {
                condition.setParameterId(((InConditionExpressionNode) node).getParameterId());
                condition.setOperType(((InConditionExpressionNode) node).getOperator());
                condition.getValues().addAll(((InConditionExpressionNode) node).getValues());
            } else if (node instanceof IsNullConditionExpressionNode){
                condition.setParameterId(((IsNullConditionExpressionNode) node).getParameterId());
                condition.setOperType(((IsNullConditionExpressionNode) node).getOperator());
            } else if (node instanceof LogicalConditionExpressionNode) {
                condition.setParameterName(((LogicalConditionExpressionNode) node).getCondition().getValue());
            } else if (node instanceof UnaryConditionExpressionNode) {
                condition.setOperType(((UnaryConditionExpressionNode) node).getOperator());
                condition.setParameterId(((UnaryConditionExpressionNode) node).getParameterId());
                condition.getValues().add(((UnaryConditionExpressionNode) node).getValue());
            } else if (node instanceof ExpressionNodeList) {
                condition.setParameterName("(...)");
                condition.setChildren(new ArrayList<ReportCondition>());
                convert(level+1, condition, (ExpressionNodeList)node);

            }
            if (condition.getParameterId() != null) {
                ParameterDto dto = ParameterDto.converter(dataModel).apply(
                        dataModel.getParameterById(condition.getParameterId()));
                if (dto != null)
                    condition.setParameterLabel(dto.getLabel());
            }
            if (level == 0)
                coreItems.add(condition);
        }
    }

    private ReportCondition getCondition() {
        return (ReportCondition) Faces.var("cond");
    }

    public boolean getNodeHasChildren() {
        return (getCondition() != null) && getCondition().isHasChildren();
    }

    public List<ReportCondition> getNodeChildren() {
        ReportCondition cond = getCondition();
        if (cond == null) {
            if (!treeLoaded || coreItems == null) {
                loadTree();
            }
            return coreItems;
        } else {
            return cond.getChildren();
        }
    }

    public ReportCondition getCurrentTreeRow() {
        return currentNode;
    }

    public void setCurrentTreeRow(ReportCondition node) {
        try {
            if (node == null)
                return;

            this.currentNode = node;

        } catch (Exception e) {
            FacesUtils.addMessageError(e);
        }
    }

    private ReportCondition getTreeRowByCondition(List<ReportCondition> tree, ExpressionNode node){
        ReportCondition retVal = null;
        for (ReportCondition condition : tree){
            if (condition.getConditionNode().equals(node)) {
                retVal = condition;

            } else if (condition.getChildren() != null) {
                retVal = getTreeRowByCondition(condition.getChildren(), node);
            }
            if (retVal != null)
                break;
        }
        return retVal;
    }

    public  void refreshCurrentTreeRow(){
        if (coreItems.size() > 0) {
            if (currentNode == null) {
                currentNode = coreItems.get(0);
            } else {
                ReportCondition newTreeRow = getTreeRowByCondition(coreItems, currentNode.getConditionNode());
                if (!currentNode.equals(newTreeRow))
                    currentNode = coreItems.get(0);
            }
        }
        else {
            currentNode = null;
        }
        setNodePath(new TreePath(currentNode, null));
    }

    public List<ReportCondition> getCoreItems(){
        return coreItems;
    }
}
