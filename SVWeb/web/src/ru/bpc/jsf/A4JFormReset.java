package ru.bpc.jsf;
import java.util.Iterator;
import java.util.Set;
 
import javax.faces.component.EditableValueHolder;
import javax.faces.component.UIComponent;
import javax.faces.component.UIForm;
import javax.faces.context.FacesContext;
import javax.faces.event.AbortProcessingException;
import javax.faces.event.ActionEvent;
import javax.faces.event.ActionListener;
 
import org.ajax4jsf.context.AjaxContext;
 
public class A4JFormReset implements ActionListener {
 
     @Override
     public void processAction(ActionEvent event) throws AbortProcessingException {          
 
          FacesContext facesContext = FacesContext.getCurrentInstance();
          AjaxContext ajaxContext = AjaxContext.getCurrentInstance(facesContext);
          UIComponent root = facesContext.getViewRoot();          
 
          ajaxContext.addRegionsFromComponent(event.getComponent());
          Set<String> ids = ajaxContext.getAjaxAreasToRender();          
 
          for (String id : ids) {
               UIComponent form = findParentForm(root.findComponent(id));
               if (form != null) {
                    clearComponentHierarchy(form);
               }
          }
     }
     
     public UIComponent findParentForm(UIComponent component) {                    
 
          for (UIComponent parent = component; parent != null; parent = parent.getParent()) {
               if (parent instanceof UIForm) {
                    return parent;
               }
          }          
 
          return null;
     }
 
     public void clearComponentHierarchy(UIComponent pComponent) {
 
          if (pComponent.isRendered()) {
 
               if (pComponent instanceof EditableValueHolder) {
                    EditableValueHolder editableValueHolder = (EditableValueHolder) pComponent;
                    editableValueHolder.setSubmittedValue(null);
                    editableValueHolder.setValue(null);
                    editableValueHolder.setLocalValueSet(false);
                    editableValueHolder.setValid(true);
               }          
 
               for (Iterator<UIComponent> iterator = pComponent.getFacetsAndChildren(); iterator.hasNext();) {
                    clearComponentHierarchy(iterator.next());
               }          
 
          }
     }
 
}