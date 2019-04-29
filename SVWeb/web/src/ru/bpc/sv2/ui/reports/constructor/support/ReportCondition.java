package ru.bpc.sv2.ui.reports.constructor.support;

import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.invocation.TreeIdentifiable;
import ru.bpc.sv2.ui.reports.constructor.dto.ParameterDto;
import ru.jtsoft.dynamicreports.report.ExpressionNode;
import ru.jtsoft.dynamicreports.report.ExpressionNodeList;
import ru.jtsoft.dynamicreports.report.OperatorType;

import java.io.Serializable;
import java.util.List;

/**
 * Created by Sonin on 16.05.2016.
 */
public class ReportCondition implements TreeIdentifiable<ReportCondition>, Serializable {
    private static final long serialVersionUID = 1L;
    private Long id;
    private int level;
    private List<ReportCondition> children;
    private Long parentId;
    private String parameterId;
    private String parameterName;
    private String parameterLabel;
    private OperatorType operType;
    private List<String> values;
    private ExpressionNode conditionNode;
    private ExpressionNodeList conditionNodeParent;

    @Override
    public int getLevel() {
        return level;
    }

    @Override
    public List<ReportCondition> getChildren() {
        return children;
    }

    @Override
    public void setChildren(List<ReportCondition> children) {
        this.children = children;
    }

    @Override
    public boolean isHasChildren() {
        return children != null && !children.isEmpty();
    }

    @Override
    public Long getParentId() {
        return parentId;
    }

    @Override
    public Long getId() {
        return id;
    }

    @Override
    public Object getModelId() {
        return id;
    }

    public String getParameterLabel() {
        return parameterLabel;
    }

    public void setParameterLabel(String parameterLabel) {
        this.parameterLabel = parameterLabel;
    }

    public boolean isMultipleValues() {
        return null != operType && operType.isMultiple();
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public void setParentId(Long parentId) {
        this.parentId = parentId;
    }

    public String getParameterId() {
        return parameterId;
    }

    public void setParameterId(String parameterId) {
        this.parameterId = parameterId;
    }

    public OperatorType getOperType() {
        return operType;
    }

    public void setOperType(OperatorType operType) {
        this.operType = operType;
    }

    public List<String> getValues() {
        return values;
    }

    public void setValues(List<String> values) {
        this.values = values;
    }

    public void setParameterName(String parameterName) {
        this.parameterName = parameterName;
    }

    public ExpressionNode getConditionNode() {
        return conditionNode;
    }

    public void setConditionNode(ExpressionNode node) {
        this.conditionNode = node;
    }

    public ExpressionNodeList getConditionNodeParent() {
        return conditionNodeParent;
    }

    public void setConditionNodeParent(ExpressionNodeList conditionNodeParent) {
        this.conditionNodeParent = conditionNodeParent;
    }

    public String getValuesString(){
        String separator = ", ";
        if (operType != null && operType.equals(OperatorType.BETWEEN))
            separator = " AND ";
        return  StringUtils.join(values, separator);
    }

    public String getParameterName(){
        if (operType == null || parameterName != null)
            return parameterName;
        StringBuilder sb = new StringBuilder("[").append(parameterLabel).append("] ").append(operType.getValue()).append(" ");
        if (operType.equals(OperatorType.IN) || operType.equals(OperatorType.NOT_IN)) {
            sb.append("(");
        }
        sb.append(getValuesString());
        if (operType.equals(OperatorType.IN) || operType.equals(OperatorType.NOT_IN)) {
            sb.append(")");
        }
        return sb.toString();
    }
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((id == null) ? 0 : id.hashCode());
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
        ReportCondition other = (ReportCondition) obj;
        if (conditionNode == null) {
            if (other.conditionNode != null)
                return false;
        } else if (!conditionNode.equals(other.conditionNode))
            return false;

        return true;
    }
}
