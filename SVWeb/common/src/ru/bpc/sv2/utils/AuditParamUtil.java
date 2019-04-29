package ru.bpc.sv2.utils;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.IAuditableObject;

public class AuditParamUtil {

	@SuppressWarnings("unchecked")
	public static CommonParamRec[] getCommonParamRec(Object parameter) {
		if (parameter instanceof IAuditableObject) {
			parameter = ((IAuditableObject) parameter).getAuditParameters();
		}
		List<CommonParamRec> paramsAsArray = null;
		if (parameter instanceof Map<?, ?>) {
			paramsAsArray = new ArrayList<CommonParamRec>(0);
			doMap((Map<String, Object>) parameter, paramsAsArray);
		} else if (parameter instanceof Filter[]) {
			paramsAsArray = new ArrayList<CommonParamRec>(0);
			for (Filter filter : (Filter[]) parameter) {
				if (filter.getValue() instanceof Map<?, ?>) {
					doMap((Map<String, Object>) filter.getValue(), paramsAsArray);
				} else if (filter.getValue() instanceof Class<?>) {
					/** TODO should we add the class name to audit values list? */
				} else {
					CommonParamRec paramRec = new CommonParamRec(filter.getElement(),
																 filter.getValue(),
																 filter.getConditionRealValue());
					paramsAsArray.add(paramRec);
				}
			}
		}
		CommonParamRec[] paramsRecs = null;
		if (paramsAsArray != null) {
			paramsRecs = paramsAsArray.toArray(new CommonParamRec[paramsAsArray.size()]);
		}
		return paramsRecs;
	}

	public static CommonParamRec[] getCommonParamRec(Number objectId, String entityType) {
		return new CommonParamRec[]{
				new CommonParamRec(IAuditableObject.AUDIT_PARAM_OBJECT_ID, objectId),
				new CommonParamRec(IAuditableObject.AUDIT_PARAM_ENTITY_TYPE, entityType)
		};
	}

	@SuppressWarnings("unchecked")
	private static void doMap(Map<String, Object> map, List<CommonParamRec> paramsAsArray) {
		for (String elementName : map.keySet()) {
			if (map.get(elementName) instanceof Map<?, ?>) {
				doMap((Map<String, Object>) map.get(elementName), paramsAsArray);
			} else {
				paramsAsArray.add(new CommonParamRec(elementName, map.get(elementName)));
			}
		}
	}
}