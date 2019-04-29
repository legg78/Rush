package ru.bpc.sv2.common;

import java.util.HashMap;
import java.util.HashSet;

public class AddressFilter extends Address {
    private static final long serialVersionUID = -2071637636824727720L;

    private String  typeIdPairs;

    public String getTypeIdPairs() {
        return typeIdPairs;
    }

    public void setTypeIdPairs(String typeIdPairs) {
        this.typeIdPairs = typeIdPairs;
    }
}
