package ru.bpc.sv2.common.arrays;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;

/**
 * Created by Boldyrev on 27.01.14.
 */
public abstract class BaseArrayElement extends Parameter implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

    private Integer id;
    private Integer arrayId;


    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getArrayId() {
        return arrayId;
    }

    public void setArrayId(Integer arrayId) {
        this.arrayId = arrayId;
    }


    public Object getModelId() {
        return getId();
    }
}
