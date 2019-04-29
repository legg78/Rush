package ru.bpc.sv2.ui.reports.constructor.web;

import static com.google.common.base.Predicates.in;
import static com.google.common.base.Predicates.not;
import static com.google.common.collect.Iterables.filter;
import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Lists.transform;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Set;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;

import com.google.common.base.Strings;

import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.reports.constructor.dto.ParameterDto;
import ru.bpc.sv2.ui.reports.constructor.dto.ReportTemplateDto;
import ru.bpc.sv2.ui.reports.constructor.dto.SortingParamDto;
import ru.bpc.sv2.ui.reports.constructor.support.ExpressionBuilder;
import ru.bpc.sv2.ui.reports.constructor.support.ListShuttleSupport;
import ru.bpc.sv2.ui.reports.constructor.support.LogicalOperator;
import ru.bpc.sv2.ui.reports.constructor.support.MbReportTemplateSupport;
import ru.bpc.sv2.ui.reports.constructor.support.ReportCondition;
import ru.bpc.sv2.ui.session.UserSession;
import ru.jtsoft.dynamicreports.model.Parameter;
import ru.jtsoft.dynamicreports.report.ExpressionNode;
import ru.jtsoft.dynamicreports.report.ExpressionNodeList;
import ru.jtsoft.dynamicreports.report.LogicalConditionExpressionNode;
import ru.jtsoft.dynamicreports.report.OperatorType;
import ru.jtsoft.dynamicreports.report.ReportTemplate;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


@ManagedBean(name="MbEditReportTemplate")
@ViewScoped
public final class MbEditReportTemplate extends MbReportTemplateSupport implements Serializable {
	
	private static final long serialVersionUID = 2476610106020244016L;

	private transient ReportTemplateDto reportTemplate;

    private final static int INSERT_BEFORE = 0;
    private final static int INSERT_INTO = 1;
    private final static int INSERT_AFTER = 2;

	private final ListShuttleSupport<ParameterDto, ParameterDto> outputParams = new ListShuttleSupport<ParameterDto, ParameterDto>();
	private final ListShuttleSupport<ParameterDto, SortingParamDto> sortingParams = new ListShuttleSupport<ParameterDto, SortingParamDto>();
    private final List<LogicalOperator> logicalOperators = new ArrayList<LogicalOperator>(Arrays.asList(LogicalOperator.AND, LogicalOperator.OR, LogicalOperator.BRACKET));


	private boolean nullsFirst;
	private boolean nullsLast;

    private CommonDao _commonDao = new CommonDao();

	private List<ParameterDto> params;
	private transient ExpressionBuilder expressionBuilder;
	
	private int valueIndex;
    MbReportTemplateTree reportConditionBean;

    private boolean editMode;
    private ReportCondition currentTreeRow;
    private ExpressionNode currentNode;
    private LogicalOperator logicalOperator;

    private UserSession userSession;

    private String userLang;

    public LogicalOperator getLogicalOperator() {
        return logicalOperator;
    }

    public void setLogicalOperator(LogicalOperator operator) {
        this.logicalOperator = operator;
    }

    public boolean isEditMode() {
        return editMode;
    }

    public void setEditMode(boolean editMode) {
        this.editMode = editMode;
    }

	public ReportTemplateDto getReportTemplate() {
		return reportTemplate;
	}

	public ListShuttleSupport<ParameterDto, ParameterDto> getOutputParams() {
		return outputParams;
	}

	public ListShuttleSupport<ParameterDto, SortingParamDto> getSortingParams() {
		return sortingParams;
	}

	public boolean isNullsFirst() {
		return nullsFirst;
	}

	public void setNullsFirst(boolean nullsFirst) {
		this.nullsFirst = nullsFirst;
	}

	public boolean isNullsLast() {
		return nullsLast;
	}

	public void setNullsLast(boolean nullsLast) {
		this.nullsLast = nullsLast;
	}

	public List<ParameterDto> getParams() {
		return params;
	}

	public ExpressionBuilder getExpressionBuilder() {
		return expressionBuilder;
	}

	public OperatorType[] getOperators() {
		return OperatorType.values();
	}

	public String getConditionsString() {
		return expressionBuilder.toString(reportTemplate.getConditions());
	}

	
	public void setValueIndex(int valueIndex) {
		this.valueIndex = valueIndex;
	}

    public List<LogicalOperator> getLogicalOperators() {
        return logicalOperators;
    }

    @Override
	protected void initReportTemplate(Long reportTemplateId) {
        reportConditionBean = (MbReportTemplateTree) ManagedBeanWrapper
                .getManagedBean("MbReportTemplateTree");

        _commonDao.setUserContext(Long.valueOf(SessionWrapper.getField("userSessionId")),
                FacesContext.getCurrentInstance().getExternalContext().getUserPrincipal().getName());

        userSession = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
        userLang = userSession.getUserLanguage();

		reportTemplate = (reportTemplateId == null) 
				? new ReportTemplateDto(userLang)
				: getReportTemplateById(reportTemplateId, false, userLang);
        reportConditionBean.setExpressionNodeList(reportTemplate.getConditions());
        reportConditionBean.setDataModel(getReportingDataModel());
        reportConditionBean.loadTree();
		expressionBuilder = new ExpressionBuilder(getReportingDataModel());
		expressionBuilder.setCursor(reportTemplate.getConditions());

	
		List<Parameter> parameters = getReportingDataModel().getParameters();

		params = newArrayList(
				transform(parameters
						, ParameterDto.converter(getReportingDataModel()))
		);
		
		outputParams.setSourceValue(
				newArrayList(filter(params
						, not(in(reportTemplate.getOutputParams()))))
		);
				
		outputParams.setTargetValue(reportTemplate.getOutputParams());
		outputParams.setConverterValue(params);
		sortingParams.setSourceValue(newArrayList(params));
		sortingParams.setTargetValue(reportTemplate.getSorting());
	}

	public void removeSortingParam() {
		sortingParams.getTargetValue().removeAll(
				sortingParams.getTargetSelection());
		
		sortingParams.getTargetSelection().clear();
	}

	private void copyParam(boolean ascending) {
		for (ParameterDto param : sortingParams.getSourceSelection()) {
			SortingParamDto sortingParam = new SortingParamDto();
			sortingParam.setParam(param);
			sortingParam.setAscending(ascending);
			sortingParam.setNullsFirst(nullsFirst);
			sortingParam.setNullsLast(nullsLast);
			sortingParams.getTargetValue().add(sortingParam);
		}
	}

	public void copyParamAsc() {
		copyParam(true);
	}

	public void copyParamDesc() {
		copyParam(false);
	}

	public void changeParam() {
		expressionBuilder.changeParam();
	}

	public void changeOperation() {
		expressionBuilder.changeOperation();
	}

	public Set<?> getDictionaryEntrySet() {
		 return expressionBuilder.getParam().getDictionary().entrySet();
	}
	
	public void changeValue() {
		if (valueIndex < 0) { 
			expressionBuilder.changeNewValue();
		} else {
			expressionBuilder.changValue(valueIndex);
		}
	}


	public void addParamExpressionBefore() {
        addParamExpression(INSERT_BEFORE);
	}

    public void addParamExpressionInto() {
        addParamExpression(INSERT_INTO);
    }

    public void addParamExpressionAfter() {
        addParamExpression(INSERT_AFTER);
    }

    public void addOperatorBefore() {
        addOperator(INSERT_BEFORE);
    }

    public void addOperatorAfter() {
        addOperator(INSERT_AFTER);
    }

    public void addParamExpression(int insertType) {
        setCursor(insertType);
        if (expressionBuilder.isConditionAcceptable()) {
            expressionBuilder.addCondition();
            expressionBuilder.clearState();
            reportConditionBean.loadTree();
        } else {
            expressionBuilder.clearState();
            addErrorMessage("not_acceptable");
        }
    }

    private void addOperator(int insertType) {
        ReportCondition currentTreeRow = reportConditionBean.getCurrentTreeRow();
        if (logicalOperator != null && currentTreeRow != null) {
            if (logicalOperator == LogicalOperator.AND)
                addAnd(insertType);
            if (logicalOperator == LogicalOperator.OR)
                addOr(insertType);
            if (logicalOperator == LogicalOperator.BRACKET)
                addBracket(insertType);
        }
        reportConditionBean.loadTree();
    }

    private void addAnd(int insertType) {
        setCursor(insertType);
        expressionBuilder.addAnd();
    }

    private void addOr(int insertType) {
        setCursor(insertType);
        expressionBuilder.addOr();
    }

    private void addBracket(int insertType) {
        setCursor(insertType);
        expressionBuilder.openBracket();
    }

	public String save() {
		boolean result = true;
		
		if (Strings.isNullOrEmpty(reportTemplate.getName())) {
			addErrorMessage("validation_reportname_required");
			result = false;
		}
		
		if (outputParams.getTargetValue().isEmpty()) {
			addErrorMessage("validation_outputparams_required");
			result = false;
		} else {
			reportTemplate.setOutputParams(outputParams.getTargetValue());
		}
		
		if (reportTemplate.getConditions().getChildNodes().isEmpty()) {
			addErrorMessage("conditions_required");
			result = false;
        } else {
            if (hasErrorsInConditions()) {
                result = false;
                addErrorMessage("conditions_not_completed");
            }
		}
		
		if (result) {
			reportTemplate.setSorting(sortingParams.getTargetValue());
			ReportTemplate savable = ReportTemplateDto.BACK_CONVERTER
					.apply(reportTemplate);
			
			if (null == savable.getId()) {
				getReportTemplateDao().persist(savable);
			} else {
				getReportTemplateDao().update(savable);
			}
			
		}
		
		return result ? "list_report_templates" : null;
	}

	public void clearSorting() {
		sortingParams.getTargetValue().clear();
	}

	public void clearConditions() {
		reportTemplate.getConditions().getChildNodes().clear();
		expressionBuilder.setCursor(reportTemplate.getConditions());
	}

	public String cancel() {
		return "list_report_templates";
	}

    public void delete() {
        ReportCondition currentTreeRow = reportConditionBean.getCurrentTreeRow();
        removeNode(getReportTemplate().getConditions(), currentTreeRow.getConditionNode());
        reportConditionBean.loadTree();
        this.currentTreeRow = null;
        currentNode = null;
    }

    public void cancelParamExpression() {
        expressionBuilder.clearState();
        editMode = false;
    }

    public void applyParamExpression() {

        if (currentTreeRow != null && currentNode != null) {
            if (expressionBuilder.isConditionAcceptable()) {
                ExpressionNodeList parentNode = currentTreeRow.getConditionNodeParent();
                int index = parentNode.getChildNodes().indexOf(currentNode);
                parentNode.getChildNodes().remove(index);
                expressionBuilder.setCursorAndIndex(parentNode, index);
                expressionBuilder.addCondition();
            } else {
                addErrorMessage("not_acceptable");
            }
        }
        expressionBuilder.clearState();
        editMode = false;
    }

    public void edit() {
        try {
            currentTreeRow = reportConditionBean.getCurrentTreeRow();
            currentNode = currentTreeRow.getConditionNode();
            if (!(currentNode instanceof ExpressionNodeList || currentNode instanceof LogicalConditionExpressionNode)) {
                editMode = true;
                expressionBuilder.clearState();
                for (ParameterDto item : params) {
                    if (item.getId().equals(currentTreeRow.getParameterId())) {
                        expressionBuilder.setParam(item);
                        expressionBuilder.changeParam();
                        break;
                    }
                }
                if (expressionBuilder.getParam() == null)
                    return;
                expressionBuilder.setOperator(currentTreeRow.getOperType());
                expressionBuilder.getValues().clear();

                for (Object item : currentTreeRow.getValues()) {
                    Object value = expressionBuilder.convertToObject(item.toString());
                    expressionBuilder.getValues().add(value);
                }

            }
        } catch (Exception e) {
            addErrorMessage("parse_error");
        }
    }

    private void removeNode(ExpressionNodeList nodeList, ExpressionNode node) {
        nodeList.getChildNodes().remove(node);
        for (ExpressionNode item : nodeList.getChildNodes()) {
            if (item instanceof ExpressionNodeList) {
                removeNode((ExpressionNodeList) item, node);
            }
        }
    }

    private void setCursor(int insertType) {
        ReportCondition currentTreeRow = reportConditionBean.getCurrentTreeRow();
        if (currentTreeRow != null) {
            if (insertType == INSERT_INTO && currentTreeRow.getConditionNode() instanceof ExpressionNodeList) {
                expressionBuilder.setCursorAndIndex((ExpressionNodeList) currentTreeRow.getConditionNode(), 0);
            } else {
                ExpressionNodeList parent = currentTreeRow.getConditionNodeParent();
                int index = parent.getChildNodes().indexOf(currentTreeRow.getConditionNode());
                if (insertType == INSERT_AFTER)
                    index++;
                expressionBuilder.setCursorAndIndex(parent, index);
            }
        } else {
            expressionBuilder.setCursorAndIndex(reportTemplate.getConditions(), 0);
        }
    }

    public boolean isShowBeforeAfterButtons() {
        return !reportTemplate.getConditions().getChildNodes().isEmpty();
    }

    public boolean isShowIntoButton() {
        ReportCondition currentTreeRow = reportConditionBean.getCurrentTreeRow();
        return isShowBeforeAfterButtons() && currentTreeRow != null && currentTreeRow.getConditionNode() instanceof ExpressionNodeList;
    }

    public boolean hasErrorsInConditions(){
        return hasErrorsInConditions(reportConditionBean.getCoreItems());
    }

    private boolean hasErrorsInConditions(List<ReportCondition> rowList) {
        boolean orderError = false;
        boolean hasErrors = false;
        ExpressionNode node = null;
        for (int i = 0; i<rowList.size(); i++) {
            ReportCondition cond = rowList.get(i);
            node = cond.getConditionNode();
            if (node instanceof LogicalConditionExpressionNode){ //Логический оператор не может быть на четной позиции или последним в записи
                if (i%2 == 0) {
                    if(!orderError) {
                        orderError=true;
                        hasErrors=true;
                        addErrorMessage("wrong_order", cond.getId());
                    }
                }
                if(i == rowList.size() - 1){
                    hasErrors=true;
                    addErrorMessage("wrong_last_node", cond.getId());
                }

            } else {
                if (i%2 == 1) {
                    if (!orderError) {
                        orderError=true;
                        hasErrors=true;
                        addErrorMessage("wrong_order", cond.getId());
                    }
                }
            }
            if (node instanceof ExpressionNodeList) {
                if (((ExpressionNodeList) node).getChildNodes().isEmpty()) {
                    hasErrors = true;
                    addErrorMessage("empty_bracket", cond.getId());
                } else {
                    if (hasErrorsInConditions(cond.getChildren()))
                        hasErrors = true;
                }
            }
        }
        return hasErrors;
    }
 }
