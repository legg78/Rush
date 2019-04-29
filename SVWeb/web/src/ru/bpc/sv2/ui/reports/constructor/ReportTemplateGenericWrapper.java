package ru.bpc.sv2.ui.reports.constructor;

import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.jtsoft.dynamicreports.report.ReportTemplateGeneric;

public class ReportTemplateGenericWrapper extends ReportTemplateGeneric implements ModelIdentifiable{
    public ReportTemplateGenericWrapper(Long id, String name, String description) {
        super(id, name, description);
    }

    public ReportTemplateGenericWrapper() {
        super(null, null, null);
    }

    @Override
    public Object getModelId() {
        return getId();
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((getId() == null) ? 0 : getId().hashCode());
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
        ReportTemplateGenericWrapper other = (ReportTemplateGenericWrapper) obj;
        if (getId() == null) {
            if (other.getId() != null)
                return false;
        } else if (!getId().equals(other.getId()))
            return false;
        return true;
    }
}
