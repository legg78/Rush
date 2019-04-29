package ru.bpc.sv2.ui.reports.constructor.dto;

import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.ui.reports.constructor.ReportTemplateGenericWrapper;
import ru.jtsoft.dynamicreports.ReportingDataModel;
import ru.jtsoft.dynamicreports.report.Column;
import ru.jtsoft.dynamicreports.report.ColumnSort;
import ru.jtsoft.dynamicreports.report.ColumnSort.Nulls;
import ru.jtsoft.dynamicreports.report.ColumnSort.Order;
import ru.jtsoft.dynamicreports.report.ExpressionNodeList;
import ru.jtsoft.dynamicreports.report.ExpressionNodePrettyPrintVisitor;
import ru.jtsoft.dynamicreports.report.ReportTemplate;

import com.google.common.base.Function;
import com.google.common.collect.Iterables;
import com.google.common.collect.Lists;

public final class ReportTemplateDto implements ModelIdentifiable, Cloneable{
	private Long id;
	private String name;
	private String description;
	private List<ParameterDto> outputParams = new ArrayList<ParameterDto>();
	private List<SortingParamDto> sorting = new ArrayList<SortingParamDto>();
	private final ExpressionNodeList conditions;
	private String conditionsString;
    private String lang = SystemConstants.ENGLISH_LANGUAGE;

	private ReportTemplateDto(ExpressionNodeList conditions, String lang) {
		this.conditions = conditions;
		this.lang = lang;
	}

	public ReportTemplateDto() {
		this(new ExpressionNodeList(null), null);
	}

	public ReportTemplateDto(String lang) {
		this();
		this.lang = lang;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public List<ParameterDto> getOutputParams() {
		return outputParams;
	}

	public void setOutputParams(List<ParameterDto> outputParams) {
		this.outputParams = outputParams;
	}

	public List<SortingParamDto> getSorting() {
		return sorting;
	}

	public ExpressionNodeList getConditions() {
		return conditions;
	}

	public void setSorting(List<SortingParamDto> sorting) {
		this.sorting = sorting;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getOutputParamsString() {
		return iterableToString(outputParams);
	}

	public String getSortingString() {
		return iterableToString(sorting);
	}

	public String getConditionsString() {
		return conditionsString;
	}

	private String iterableToString(Iterable<?> iterable) {
		StringBuilder builder = new StringBuilder();
		Iterator<?> iterator = iterable.iterator();
		if (iterator.hasNext()) {
			builder.append(iterator.next());
			while (iterator.hasNext()) {
				builder.append(", ").append(iterator.next());
			}
		}
		return builder.toString();
	}

	public static Function<ReportTemplate, ReportTemplateDto> converter(
			final ReportingDataModel reportingDataModel,
			final boolean eveluateConditionsString,
			final String curLang) {
		return new Function<ReportTemplate, ReportTemplateDto>() {
			private final Function<String, ParameterDto> paramConverter = new Function<String, ParameterDto>() {
				@Override
				public ParameterDto apply(String input) {
					return ParameterDto.converter(reportingDataModel).apply(
							reportingDataModel.getParameterById(input));
				}
			};

			private final Function<Column, ParameterDto> columnConverter = new Function<Column, ParameterDto>() {
				@Override
				public ParameterDto apply(Column input) {
					return paramConverter.apply(input.getParameterId());
				}
			};

			private final Function<ColumnSort, SortingParamDto> columnSortConverter = new Function<ColumnSort, SortingParamDto>() {
				@Override
				public SortingParamDto apply(ColumnSort input) {
					SortingParamDto output = new SortingParamDto();
					output.setParam(paramConverter.apply(input.getParameterId()));
					output.setAscending(Order.ASC == input.getOrder());
					if (Nulls.FIRST == input.getNulls()) {
						output.setNullsFirst(true);
					} else if (Nulls.LAST == input.getNulls()) {
						output.setNullsLast(true);
					}
					return output;
				}
			};

			@Override
			public ReportTemplateDto apply(ReportTemplate input) {
				final ReportTemplateDto output;
				if (null == input) {
					output = null;
				} else {
					output = new ReportTemplateDto(input.getConditions(), curLang);
					output.setId(input.getId());
					output.setName(input.getName());
					output.setDescription(input.getDescription());
					output.setOutputParams(Lists.newArrayList(Iterables
							.transform(input.getColumns(), columnConverter)));
					output.setSorting(Lists.newArrayList(Iterables.transform(
							input.getSorting(), columnSortConverter)));
					if (eveluateConditionsString) {
						StringWriter writer = new StringWriter();
						new ExpressionNodePrettyPrintVisitor(writer,
								reportingDataModel)
								.visitExpressionNodeList(input.getConditions());
						output.conditionsString = writer.toString();
					}
				}
				return output;
			}
		};
	}

	public static final Function<ReportTemplateDto, ReportTemplate> BACK_CONVERTER = new Function<ReportTemplateDto, ReportTemplate>() {
		@Override
		public ReportTemplate apply(ReportTemplateDto input) {
			final ReportTemplate output;
			if (null == input) {
				output = null;
			} else {
				ReportTemplate.Builder template = new ReportTemplate.Builder();
				template.reportTempateGeneric(input.getId()
						, input.getName()
						, input.getDescription());
				
				template.conditions(input.getConditions());
				for (ParameterDto outParam : input.getOutputParams()) {
					template.addParameterAsColumn(outParam.getId());
				}
				
				for (SortingParamDto sortParam : input.getSorting()) {
					template.addSort(new ColumnSort(sortParam.getParam()
							.getId(), sortParam.isAscending() ? Order.ASC
							: Order.DESC,
							sortParam.isNullsFirst() ? Nulls.FIRST : sortParam
									.isNullsLast() ? Nulls.LAST : null));
				}
				output = template.build();
			}
			return output;
		}
	};

    @Override
    public Object getModelId() {
        return getId();
    }

    public ReportTemplateDto clone() throws CloneNotSupportedException {
        return (ReportTemplateDto) super.clone();
    }

    public ReportTemplateGenericWrapper getWrapped() {
        return new ReportTemplateGenericWrapper(getId(), getName(), getDescription());
    }

    public String getLang() {
        return lang;
    }

    public void setLang(String lang) {
        this.lang = lang;
    }
}
