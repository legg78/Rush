package ru.bpc.sv2.ui.process.monitoring;

import org.openfaces.component.table.TreePath;
import ru.bpc.sv2.process.ProcessSession;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import java.io.Serializable;

@SessionScoped
@ManagedBean(name = "MbProcSess")
public class MbProcSess implements Serializable {
    private static final long serialVersionUID = 1L;

    private String tabName;
    private ProcessSession selectedProcessSession;
    private TreePath nodePath;
    private ProcessSession filter;

    public ProcessSession getFilter() {
        return filter;
    }

    public void setFilter(ProcessSession filter) {
        this.filter = filter;
    }

    public TreePath getNodePath() {
        return nodePath;
    }

    public void setNodePath(TreePath nodePath) {
        this.nodePath = nodePath;
    }

    public String getTabName() {
        return tabName;
    }

    public void setTabName(String tabName) {
        this.tabName = tabName;
    }

    public ProcessSession getSelectedProcessSession() {
        return selectedProcessSession;
    }

    public void setSelectedProcessSession(ProcessSession selectedProcessSession) {
        this.selectedProcessSession = selectedProcessSession;
    }
}
