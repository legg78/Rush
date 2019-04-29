package ru.bpc.sv2.ui.ps.jcb.messages;


import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.JcbDao;
import ru.bpc.sv2.ps.jcb.JcbAddendum;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;

@ViewScoped
@ManagedBean (name = "MbJcbAddendumSearchBottom")
public class MbJcbAddendumSearchBottom extends AbstractBean{
    private static final Logger logger = Logger.getLogger("OPER_PROCESSING");
    private static String COMPONENT_ID = "addendumTable";
    private final DaoDataModel<JcbAddendum> addendumSource;
    private final TableRowSelection<JcbAddendum> selection;
    private JcbDao jcbDao = new JcbDao();
    private String tabName;
    private String parentSectionId;
    private JcbAddendum activeItem;

    public MbJcbAddendumSearchBottom() {
        addendumSource = new DaoDataModel<JcbAddendum>() {
            @Override
            protected JcbAddendum[] loadDaoData(SelectionParams params) {
                if (searching) {
                    try {
                        setFilters();
                        params.setFilters(filters.toArray(new Filter[filters.size()]));
                        JcbAddendum[] addendums = jcbDao.getJcbAddendums(userSessionId, params);
                        return addendums;
                    } catch(Exception e) {
                        setDataSize(0);
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                }
                return new JcbAddendum[0];
            }
            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    try {
                        setFilters();
                        params.setFilters(filters.toArray( new Filter[filters.size()] ));
                        return jcbDao.getJcbAddendumsCount(userSessionId, params);
                    } catch(Exception e) {
                        setDataSize(0);
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                }
                return 0;
            }
        };
        selection = new TableRowSelection<JcbAddendum>(null, addendumSource);
    }

    public void search(){
        searching = true;
        addendumSource.flushCache();
    }

    public void setTabName(String tabName) {
        this.tabName = tabName;
    }

    public void setParentSectionId(String parentSectionId) {
        this.parentSectionId = parentSectionId;
    }

    public SimpleSelection getSelection() {
        if (addendumSource.getRowCount() > 0) {
            SimpleSelection sel = new SimpleSelection();
            if (activeItem == null) {
                addendumSource.setRowIndex(0);
                activeItem = (JcbAddendum)addendumSource.getRowData();
                sel.addKey(activeItem.getModelId());
                selection.setWrappedSelection(sel);
            } else {
                sel.addKey(activeItem.getModelId());
                selection.setWrappedSelection(sel);
                activeItem = selection.getSingleSelection();
            }
        }
        return selection.getWrappedSelection();
    }
    public void setSelection(SimpleSelection selection) {
        this.selection.setWrappedSelection(selection);
        activeItem = this.selection.getSingleSelection();
    }
    public JcbAddendum getActiveItem(){
        return activeItem;
    }

    public ExtendedDataModel getItems(){
        return addendumSource;
    }

    @Override
    public void clearFilter(){
        searching = false;
        addendumSource.flushCache();
    }
    @Override
    public String getComponentId() {
        return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        if (params != null) {
            filters.add(new Filter("lang", userLang));
            filters.add(new Filter("finId", (Long)params.get("finId")));
        }
    }
}
