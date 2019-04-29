package ru.bpc.sv2.common.arrays;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by Boldyrev on 27.01.14.
 */
public class DefaultArrayElement extends BaseArrayElement {
    private static final long serialVersionUID = 1L;


    private Integer elementNumber;

    public Integer getElementNumber() {
        return elementNumber;
    }

    public void setElementNumber(Integer elementNumber) {
        this.elementNumber = elementNumber;
    }



    @Override
    public DefaultArrayElement clone() throws CloneNotSupportedException {
        return (DefaultArrayElement) super.clone();
    }

    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("valueV", this.getValueV());
        result.put("valueN", this.getValueN());
        result.put("valueD", this.getValueD());
        result.put("elementNumber", this.getElementNumber());
        result.put("lovId", this.getLovId());
        result.put("name", this.getName());
        result.put("description", this.getDescription());

        return result;
    }




}
