package ru.bpc.jsf;

import ru.bpc.sv2.ui.utils.RequestContextHolder;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.faces.FactoryFinder;
import javax.faces.component.UIComponent;
import javax.faces.component.UIForm;
import javax.faces.context.FacesContext;
import javax.faces.context.ResponseWriter;
import javax.faces.render.RenderKit;
import javax.faces.render.RenderKitFactory;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * General Utilies used with Java Server Faces.
 * 
 * @author jsteenkamp
 *
 */
public class FacesUtils {
	
	/**
	 * Private constructor to prevent this class form being instantiated directly.
	 */
	private FacesUtils(){
	}
	
	public static ResponseWriter setupResponseWriter(FacesContext context) throws IOException {
		
		ResponseWriter writer = context.getResponseWriter();
		if (writer == null) {
			HttpServletRequest request = RequestContextHolder.getRequest();
			HttpServletResponse response = RequestContextHolder.getResponse();
			
			RenderKitFactory renderFactory = (RenderKitFactory)
			FactoryFinder.getFactory(FactoryFinder.RENDER_KIT_FACTORY);
			RenderKit renderKit = renderFactory.getRenderKit(context, context.getViewRoot().getRenderKitId());

			writer =  renderKit.createResponseWriter(response.getWriter(),"text/html", request.getCharacterEncoding());
			context.setResponseWriter(writer);
		}
		
		return writer;
	}
	
	 public static UIForm getForm(FacesContext context, UIComponent component) {
    	
    	//Try to get a containing form
    	List<UIForm> forms = new ArrayList<UIForm>();
    	findSubForms(context,component,forms);
    	
    	if(forms.isEmpty()){
    		//We have not found any sub forms inside this component, therefore we need
    		//search for any parent forms.
    		UIComponent parent = component.getParent();
    		while(parent != null){
    			if(parent instanceof UIForm){
    				break;
    			}
    			parent = parent.getParent();
    		}
    		if(parent != null){
    			forms.add((UIForm)parent);
    		}
    	}
    	
    	if(forms.isEmpty()){
    		return null;
    	}else{
    		return forms.get(0);
    	}
    }
    
    private static void  findSubForms(FacesContext context, UIComponent component, List<UIForm> forms){
    	List<UIComponent> children = component.getChildren();
    	for(UIComponent comp : children){
    		if(comp instanceof UIForm){
    			forms.add((UIForm)comp);
    		}
    		findSubForms(context,comp,forms);
    	}
    }
    
    public static void encodeRecursive(FacesContext context, UIComponent component) throws IOException {
        if (!component.isRendered()) return;
        // Render this component and its children recursively
        component.encodeBegin(context);
        if (component.getRendersChildren()) {
            component.encodeChildren(context);
        } else {
            Iterator<UIComponent> kids = component.getChildren().iterator();
            while (kids.hasNext()) {
                UIComponent kid = (UIComponent) kids.next();
                encodeRecursive(context, kid);
            }
        }
        component.encodeEnd(context);
    }
	
}
