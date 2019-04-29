package ru.bpc.sv2.ui.reports.constructor.support;

import java.util.Collections;
import java.util.Iterator;
import java.util.List;

import org.richfaces.model.DataProvider;
import org.richfaces.model.ExtendedTableDataModel;
import org.richfaces.model.FilterField;
import org.richfaces.model.Modifiable;
import org.richfaces.model.Ordering;
import org.richfaces.model.SortField2;

import ru.jtsoft.dynamicreports.db.PageRequest;
import ru.jtsoft.dynamicreports.db.PageRequest.Sort;

public final class SortableTableDataModel<T> extends ExtendedTableDataModel<T>
		implements Modifiable {
	private static final long serialVersionUID = 1825569187920044432L;

	private String sortField;
	private boolean sortAscending;

	public SortableTableDataModel(DataProvider<T> dataProvider) {
		super(dataProvider);
	}

	@Override
	public void modify(List<FilterField> filterFields,
			List<SortField2> sortFields) {
		Iterator<SortField2> iterator = sortFields.iterator();
		if (iterator.hasNext()) {
			SortField2 sortField2 = iterator.next();
			if (sortField2.getExpression().isLiteralText()) {
				sortField = sortField2.getExpression().getExpressionString();
			} else {
				sortField = sortField2.getExpression().getExpressionString()
						.replaceAll("^#\\{.*?\\.", "").replaceAll("\\}$", "");
			}
			sortAscending = Ordering.ASCENDING == sortField2.getOrdering();
			reset();
		}
	}

	public PageRequest getPageRequest(int firstRow, int endRow) {
		PageRequest result;
		if (null == sortField) {
			result = new PageRequest(firstRow, endRow, Collections.<Sort>emptyList());
		} else {
			result = new PageRequest(firstRow, endRow, new Sort(sortField,
					sortAscending));
		}
		return result;
	}
}
