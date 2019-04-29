package ru.bpc.jsf;

import com.sun.faces.spi.DiscoverableInjectionProvider;
import com.sun.faces.spi.InjectionProviderException;
import com.sun.faces.vendor.WebContainerInjectionProvider;

import javax.faces.context.FacesContext;
import javax.servlet.ServletContext;
import java.lang.reflect.Method;

/**
 * Created by Nikishkin on 30.03.2015.
 */
public class WasInjectionProvider extends DiscoverableInjectionProvider {

	private Object annotationHelper;
	private WebContainerInjectionProvider provder;

	public WasInjectionProvider() throws Exception {
		Method annotationHelperManagerGetInstanceMethod = Class.forName(
				"com.ibm.wsspi.webcontainer.annotation.AnnotationHelperManager").getDeclaredMethod("getInstance",
				ServletContext.class);

		Object annotationHelperManager = annotationHelperManagerGetInstanceMethod.invoke(null,
				(ServletContext) FacesContext.getCurrentInstance().getExternalContext().getContext());

		annotationHelper = annotationHelperManager.getClass().getDeclaredMethod("getAnnotationHelper")
				.invoke(annotationHelperManager);
		annotationHelper.getClass().getMethod("inject", Object.class);

		provder = new WebContainerInjectionProvider();
	}

	@Override
	public void inject(Object paramObject) throws InjectionProviderException {
		try {
			annotationHelper.getClass().getMethod("inject", Object.class).invoke(annotationHelper, paramObject);
		} catch (Exception e) {
			throw new InjectionProviderException(e);
		}
	}

	@Override
	public void invokePreDestroy(Object paramObject) throws InjectionProviderException {
		provder.invokePreDestroy(paramObject);
	}

	@Override
	public void invokePostConstruct(Object paramObject) throws InjectionProviderException {
		provder.invokePostConstruct(paramObject);
	}

}
