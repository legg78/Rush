package ru.bpc.sv2.ui.reports.constructor.support;

import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

import ru.bpc.sv2.ui.reports.constructor.dto.ParameterDto;
import ru.jtsoft.dynamicreports.ReportingDataModel;
import ru.jtsoft.dynamicreports.model.DateContainer;
import ru.jtsoft.dynamicreports.model.ValueContainer;
import ru.jtsoft.dynamicreports.model.types.DictionaryDateType;
import ru.jtsoft.dynamicreports.model.types.Type;
import ru.jtsoft.dynamicreports.report.BetweenConditionExpressionNode;
import ru.jtsoft.dynamicreports.report.ExpressionNode;
import ru.jtsoft.dynamicreports.report.ExpressionNodeList;
import ru.jtsoft.dynamicreports.report.ExpressionNodePrettyPrintVisitor;
import ru.jtsoft.dynamicreports.report.InConditionExpressionNode;
import ru.jtsoft.dynamicreports.report.IsNullConditionExpressionNode;
import ru.jtsoft.dynamicreports.report.LogicalConditionExpressionNode;
import ru.jtsoft.dynamicreports.report.LogicalConditionType;
import ru.jtsoft.dynamicreports.report.OperatorType;
import ru.jtsoft.dynamicreports.report.UnaryConditionExpressionNode;

import com.google.common.base.Function;
import com.google.common.collect.Iterables;
import com.google.common.collect.Lists;

public final class ExpressionBuilder {
	private final ReportingDataModel dataModel;
	private ParameterDto param;
	private Type<?> paramType;
	private OperatorType operator;
	private final List<Object> values = new ArrayList<Object>();
	private Object newValue;
	private ExpressionNodeList cursor;
	private static final String RAW_DATE_ITEM = "raw";
    private Integer curNodeIndex;

	public ExpressionBuilder(ReportingDataModel reportingDataModel) {
		this.dataModel = reportingDataModel;
	}

	public ParameterDto getParam() {
		return param;
	}

	public void setParam(ParameterDto param) {
		this.param = param;
	}

	public OperatorType getOperator() {
		return operator;
	}

	public void setOperator(OperatorType operator) {
		this.operator = operator;
	}

	public List<Object> getValues() {
		return values;
	}

	public Object getNewValue() {
		return newValue;
	}

	public void setNewValue(Object newValue) {
		this.newValue = newValue;
	}

	public String getRawDateItem() {
		return RAW_DATE_ITEM;
	}

	public boolean isMultipleValues() {
		return null != operator && operator.isMultiple();
	}

	public void setCursor(ExpressionNodeList cursor) {
		this.cursor = cursor;
	}

	public void changeParam() {
		paramType = dataModel.getParameterById(param.getId()).getType();
		if (isMultipleValues()) {
			values.clear();
			newValue = nullParam();
		} else {
			for (int i = 0; i < values.size(); i++) {
				values.set(i, nullParam());
			}
		}
	}

	public void changeOperation() {
		if (isMultipleValues()) {
			values.clear();
			newValue = nullParam();
		} else {
			int valuesCount = operator.getCount();
			while (valuesCount < values.size()) {
				values.remove(valuesCount);
			}
			while (values.size() < valuesCount) {
				values.add(nullParam());
			}
		}
	}

	private void changeDateValue(DateContainer value) {
		if (RAW_DATE_ITEM.equals(value.getDictionaryValue())) {
			if (value.isRawMode()) {
				if (null == value.getRawValue()) {
					value.setRawMode(false);
					value.setDictionaryValue("0");
				}
			} else {
				value.setRawMode(true);
				value.setRawValue(new Date());
			}
		}
	}

	public void changValue(int index) {
		if (isEmpty(values.get(index))) {
			if (isMultipleValues()) {
				values.remove(index);
			}
		} else if (isDictionaryDateParam()) {
			changeDateValue((DateContainer) values.get(index));
		}
	}

	public void changeNewValue() {
		if (!isEmpty(newValue)) {
			if (isDictionaryDateParam()) {
				changeDateValue((DateContainer) newValue);
			}
			values.add(newValue);
			newValue = nullParam();
		}
	}

    private void add(ExpressionNode expressionNode) {
        if (curNodeIndex != null) {
            cursor.getChildNodes().add(curNodeIndex, expressionNode);
        } else {
            cursor.getChildNodes().add(expressionNode);
        }
    }


    public void addCondition() {
		final ExpressionNode condition;

		if (0 == operator.getCount()) {
			condition = new IsNullConditionExpressionNode(param.getId(),
					operator);
		} else {
			final Function<Object, String> converter = new Function<Object, String>() {
				@SuppressWarnings("unchecked")
				@Override
				public String apply(Object input) {
					return ((Type<Object>) paramType).serialize(input);
				}
			};
			if (1 == operator.getCount()) {
				condition = new UnaryConditionExpressionNode(param.getId(),
						operator, converter.apply(values.get(0)));
			} else if (2 == operator.getCount()) {
				condition = new BetweenConditionExpressionNode(param.getId(),
						operator, converter.apply(values.get(0)),
						converter.apply(values.get(1)));
			} else if (isMultipleValues()) {
				condition = new InConditionExpressionNode(param.getId(),
						operator, Lists.newArrayList(Iterables.transform(
								values, converter)));
			} else {
				throw new IllegalStateException("Unsupport operation type "
						+ operator);
			}
		}
		add(condition);
	}

	public static boolean isEmpty(Object value) {
		return null == value
				|| (value instanceof String && ((String) value).isEmpty())
				|| (value instanceof ValueContainer && ((ValueContainer<?>) value)
						.isEmpty());
	}

	public void addAnd() {
		add(new LogicalConditionExpressionNode(LogicalConditionType.AND));
	}

	public void addOr() {
		add(new LogicalConditionExpressionNode(LogicalConditionType.OR));
	}

	public void openBracket() {
		ExpressionNodeList newCursor = new ExpressionNodeList(cursor);
		add(newCursor);
		cursor = newCursor;
	}

	public void closeBracket() {
		cursor = (ExpressionNodeList) cursor.getRoot();
	}

	private boolean isEmptyOrLastExpressionOperator() {
        return  true;
	}

    public boolean isConditionAcceptable() {
        //boolean result = isEmptyOrLastExpressionOperator();

        boolean result = null != param && null != operator;
        if (result) {
            result = isMultipleValues() ? !values.isEmpty() : operator
                    .getCount() == values.size();
            Iterator<Object> iterator = values.iterator();
            while (result && iterator.hasNext()) {
                result = !isEmpty(iterator.next());
            }
        }

        return result;
    }

	public boolean isLogicalOperatorAcceptable() {
		return !isEmptyOrLastExpressionOperator();
	}

	public boolean isBracketOpenable() {
		return isEmptyOrLastExpressionOperator();
	}

	public boolean isBracketClosable() {
		return !(null == cursor.getRoot() || isEmptyOrLastExpressionOperator());
	}

	public boolean isCompleted() {
		return null == cursor.getRoot() && !isEmptyOrLastExpressionOperator();
	}

	public String toString(ExpressionNodeList expressionNodeList) {
		StringWriter writer = new StringWriter();
		new ExpressionNodePrettyPrintVisitor(writer, dataModel) {
			private boolean nodeCompleted = true;

			@Override
			protected boolean isNodeCompleted(ExpressionNode node) {
			//	if (nodeCompleted) {
			//		nodeCompleted = cursor != node;
			//	}
				return nodeCompleted;
			}
		}.visitExpressionNodeList(expressionNodeList);
		return writer.toString();
	}

	private boolean isDictionaryDateParam() {
		return paramType instanceof DictionaryDateType;
	}

	private Object nullParam() {
		return isDictionaryDateParam() ? new DateContainer() : null;
	}

    public void setCursorAndIndex(ExpressionNodeList cursor, Integer index){
        this.cursor = cursor;
        this.curNodeIndex = index;
    }

    public Object convertToObject(String value) {
        return paramType.deserialize(value);
    }

    public void clearState(){
        param = null;
        operator = null;
        paramType = null;
        values.clear();
        newValue = nullParam();
    }
}
