/*
 * Created on 18.10.2006 by maxim
 */
package util.auxil;

import javax.el.ELContext;
import javax.el.ExpressionFactory;
import javax.el.ValueExpression;
import javax.faces.application.Application;
import javax.faces.context.FacesContext;

public class ManagedBeanWrapper {
	/**
	 * There is the approach every developer of this project should follow to - name of a bean 
	 * registered in faces-config.xml is equals to its class name. In order to this, the safest way to retrieve
	 * a bean instance from faces bean pool is use getSimpleName() method of it's class. ManagedBeanWrapper already
	 * contains appropriate method that should be used in most of the cases- getManagedBean(Class<T> clazz). 
	 */
	public synchronized static <T> T getManagedBean(String name) {
		FacesContext context = FacesContext.getCurrentInstance();

		T result = null;

		if (context != null)
		{
			ELContext elctx = context.getELContext();
			Application jsApp = context.getApplication();
			ExpressionFactory exprFactory = jsApp.getExpressionFactory();
			ValueExpression valueExpr = exprFactory.createValueExpression(
			                            elctx,
			                           "#{"+name+"}",
			                            Object.class);
			try {
				//noinspection unchecked
				result = (T) valueExpr.getValue(elctx);
			} catch (NullPointerException ignored) {
				// might be thrown when getManagedBean is called not from faces context, i.e. from web service
			}
		}
		return result;
	}

	public static <T> T getManagedBean(Class<T> clazz){
		String className = clazz.getSimpleName();
		Object result = getManagedBean(className);
		//noinspection unchecked
		return (T) result;
	}
	
}
