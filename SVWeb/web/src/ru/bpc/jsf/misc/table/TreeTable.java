package ru.bpc.jsf.misc.table;

import org.apache.log4j.Logger;
import org.openfaces.component.table.AbstractTable;
import org.openfaces.component.table.impl.TableDataModel;
import org.openfaces.renderkit.table.CustomRowRenderingInfo;
import org.openfaces.renderkit.table.TableStructure;
import ru.bpc.sv2.invocation.TreeIdentifiable;
import ru.bpc.sv2.ui.utils.CommonUtils;

import javax.faces.FacesException;
import javax.faces.component.ContextCallback;
import javax.faces.component.UIComponent;
import javax.faces.component.UINamingContainer;
import javax.faces.context.FacesContext;
import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * This class overrides default TreeTable to fix some bugs
 */
public class TreeTable extends org.openfaces.component.table.TreeTable {
	private static final Logger logger = Logger.getLogger("COMMON");

	public TreeTable() {
		super.setUiDataValue(new DataModel(this));
	}

	private boolean isRowAvailableAfterRestoringReenterFlag = false;

	@Override
	public boolean isRowAvailableAfterRestoring(int rowIndex) {
		boolean result = super.isRowAvailableAfterRestoring(rowIndex);
		if (!isRowAvailableAfterRestoringReenterFlag) {
			isRowAvailableAfterRestoringReenterFlag = true;
			try {
				getNodePath(rowIndex);
			} catch (IndexOutOfBoundsException e) {
				TableDataModel model = getModel();
				model.prepareForRestoringRowIndexes();
				restoreRows(false);
			} finally {
				isRowAvailableAfterRestoringReenterFlag = false;
			}
		}
		return result;
	}

	@Override
	public void processDecodes(FacesContext context) {
		// The following is to avoid NullPointerException on OUIData.processColumnChildren when accessing customRowRenderingInfos
		//noinspection unchecked
		Map<Integer, CustomRowRenderingInfo> customRowRenderingInfos = (Map) getAttributes().get(TableStructure.CUSTOM_ROW_RENDERING_INFOS_KEY);
		if (customRowRenderingInfos == null)
			getAttributes().put(TableStructure.CUSTOM_ROW_RENDERING_INFOS_KEY, new HashMap<Integer, CustomRowRenderingInfo>());
		try {
			super.processDecodes(context);
		}catch (IndexOutOfBoundsException e){
			logger.debug(e);
		}

	}

	public static class DataModel extends org.openfaces.component.table.impl.TableDataModel {
		public DataModel() {
		}

		public DataModel(AbstractTable table) {
			super(table);
		}

		@Override
		public RestoredRowIndexes restoreRowIndexes() {
			List previousRowKeys = getStoredRowKeys();
			if (previousRowKeys != null && previousRowKeys.isEmpty() && !getTable().isDataSourceEmpty()) {
				prepareForRestoringRowIndexes();
			}
			return super.restoreRowIndexes();
		}
	}

	@Override
	public boolean invokeOnComponent(FacesContext context, String clientId, ContextCallback callback) throws FacesException {
		try {
			return super.invokeOnComponent(context, clientId, callback);
		} catch (FacesException e) {
			if (!(e.getCause() instanceof NumberFormatException)) {
				throw e;
			}
			// This is the case when there is a try to find component with id like appForm:appTable:0_10_12_3_0:j_id107 in a tree table.
			// Standard implementation fails to parse table row index which is actually a node path (0_10_12_3_0) for treetable.
			try {
				setRowIndex(-1);
				String myId = super.getClientId(context);
				int myIdLength = myId.length();
				if (clientId.startsWith(myId) && myIdLength < clientId.length()) {
					Field field = TableDataModel.class.getDeclaredField("extractedRows");
					field.setAccessible(true);
					//noinspection unchecked
					List<TableDataModel.RowInfo> rows = (List<TableDataModel.RowInfo>) field.get(getDataModel());
					if (!rows.isEmpty() && rows.get(0).getRowData() instanceof TreeIdentifiable) {
						char sepChar = UINamingContainer.getSeparatorChar(context);
						if (clientId.charAt(myIdLength) == sepChar) {
							int index2 = clientId.indexOf(sepChar, myIdLength + 1);
							if (index2 > myIdLength) {
								String[] rowPath = clientId.substring(myIdLength + 1, index2).split("_");
								Long currentParentId = null;
								int indexWithinParent = -1;
								int rowPathIndex = 0;
								TreeIdentifiable found = null;
								for (TableDataModel.RowInfo row : rows) {
									int targetIndexWithinParent = Integer.valueOf(rowPath[rowPathIndex]);
									TreeIdentifiable element = (TreeIdentifiable) row.getRowData();
									if (CommonUtils.equals(currentParentId, element.getParentId())) {
										indexWithinParent++;
										if (indexWithinParent == targetIndexWithinParent) {
											currentParentId = element.getId();
											indexWithinParent = -1;
											rowPathIndex++;
											if (rowPathIndex == rowPath.length) {
												found = element;
												break;
											}
										}
									}
								}
								if (found != null) {
									restoreRows(false);
									for (int i = 0; i < rows.size(); i++) {
										TableDataModel.RowInfo rowInfo = rows.get(i);
										if (((TreeIdentifiable) rowInfo.getRowData()).getId().equals(found.getId())) {
											this.setRowIndex(i);
											if (this.isRowAvailable()) {
												Iterator<UIComponent> itr = this.getFacetsAndChildren();
												boolean flag = false;
												while (itr.hasNext() && !flag) {
													flag = itr.next().invokeOnComponent(context, clientId, callback);
												}
												return flag;
											}
										}
									}
								}
							}
						}
					}
				}
			} catch (Exception ignored) {
				logger.error(ignored.getMessage(), ignored);
			}
			return false;
		}
	}
}
