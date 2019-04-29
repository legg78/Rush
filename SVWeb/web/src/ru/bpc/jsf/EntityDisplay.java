package ru.bpc.jsf;

import org.apache.log4j.Logger;
import ru.bpc.sv2.ui.utils.EntityIcons;
import util.auxil.SessionWrapper;

import javax.faces.component.UIComponentBase;
import javax.faces.context.FacesContext;
import javax.faces.context.ResponseWriter;
import java.io.IOException;

public class EntityDisplay extends UIComponentBase{
	private static final Logger logger = Logger.getLogger(EntityDisplay.class);

	private ResponseWriter writer;
	private Object entityId;
	private String value;
	private String description;
	private Boolean show = false;
	private String displayOrder;
	private String entityName;
	private Boolean rendered;
	private String styleClass;
	private String style;
	private Integer intEntityId;
	private String contextType;
	private static final String onMouseupR="if (showMenu(this)) {document.lkjasdf = event; selectContextMenu(':ENTITY',':BEAN');}";
	private static final String onMouseupL="if(!rightButton && isSelectedRow(this,rightButton) && :LINK && !disableContext) {setDisableContext(true); beforePrepareDefaultAction(':ENTITY',':BEAN');}";
	private String contextLink;
	private String bean;
	
	public final static String NO_DATA = " ";
	
	public final static String CODE_NAME = "LVAPCDNM";
	public final static String NAME_CODE = "LVAPNMCD";
	public final static String NAME = "LVAPNAME";
	public final static String CODE = "LVAPNODE";
	
	public final static String DIV = "div";
	public final static String TITLE = "title";
	public final static String CLASS = "class";
	public final static String ID = "id";
	public final static String VALUE = "value";
	public final static String STYLE = "style";
	public final static String SPAN = "span";
	public final static String ONMOUSEUP = "onmouseup";
	
	public final static String ENTITY_ID = "entityId";
	public final static String DESCRIPTION = "description";
	public final static String ENTITY_NAME = "entityName";
	public final static String SHOW = "showIcon";
	public final static String DISPLAY_ORDER = "displayOrders";
	public final static String RENDERED = "rendered";
	public final static String STYLE_CLASS = "styleClass";
	public final static String CONTEXT_TYPE = "contextType";
	public final static String CONTEXT_LINK = "link";
	public final static String LINK_STYLE = "ctxSummoner";
	public final static String BEAN = "bean";
	
	@Override
	public String getFamily() {
		return "Entity";
	}
	
	@Override
	public void encodeBegin(FacesContext context) throws IOException{
		try {
			writer = context.getResponseWriter();
			getParameters();
			nullChecker();
			if (rendered){
				writer.startElement(DIV, this);

				if (styleClass != null){
					writer.writeAttribute(CLASS, styleClass, null);
				}

				if (style != null){
					writer.writeAttribute(STYLE, style, null);
				}

				if(contextType!=null){
					writer.writeAttribute(ONMOUSEUP, onMouseupR.replaceAll(":ENTITY", contextType).replaceAll(":LINK", contextLink).replaceAll(":BEAN",bean), null);
					writer.startElement(SPAN, this);
					writer.writeAttribute(ONMOUSEUP, onMouseupL.replaceAll(":ENTITY", contextType).replaceAll(":LINK", contextLink).replaceAll(":BEAN",bean), null);
					if (contextLink.equals("true")){
						writer.writeAttribute(CLASS, LINK_STYLE, null);
					}
				}

				writer.writeAttribute(TITLE, description, null);
				if (show){
					writer.startElement(DIV, this);
					String icon;
					if (intEntityId == null){
						if (entityId instanceof Integer) {
							entityId = entityId.toString();
						}
						icon = EntityIcons.getInstance().
								getObjectsMap().
								get(entityName).
								get(entityId);

					} else {
						icon = EntityIcons.getInstance().
								getObjectsMap().
								get(entityName).
								get(intEntityId);
					}
					writer.writeAttribute(CLASS, icon, null);
					writer.endElement(DIV);
				} if ((!value.equals(NO_DATA)) && (entityId == null)){
					writer.writeText(value, VALUE);
				} else if (!value.equals(NO_DATA)){
					if (displayOrder.equalsIgnoreCase(CODE_NAME)){
						writeCodeName();
					} else if (displayOrder.equalsIgnoreCase(NAME_CODE)){
						writeNameCode();
					} else if (displayOrder.equalsIgnoreCase(NAME)){
						writeName();
					} else if (displayOrder.equalsIgnoreCase(CODE)){
						writeCode();
					} else {
						writeCodeName();
					}
				}	else if (entityId != null) {
					writer.writeText(entityId, ID);
				}

				if(contextType!=null){
					writer.endElement(SPAN);
				}

				writer.endElement(DIV);
			}
		} catch(Exception e) {
			logger.error(toString(), e);
			throw e;
		}
	}
	
	private void writeCodeName() throws IOException{
		writer.writeText(entityId + " - ", ID);
		writer.writeText(value, VALUE);
	}
	
	private void writeNameCode() throws IOException{
		writer.writeText(value + " - ", VALUE);
		writer.writeText(entityId , ID);		
	}
	
	private void writeName() throws IOException{
		writer.writeText(value, VALUE);		
	}

	private void writeCode() throws IOException{
		writer.writeText(entityId , ID);		
	}	
	

	private void getParameters() {
		initValues();

		Object objectEntity = getAttributes().get(RENDERED);
		if (objectEntity != null){
			if(objectEntity.getClass() == String.class){
				rendered = ((String) objectEntity).equalsIgnoreCase("true");
			}
		}
		
		objectEntity = getAttributes().get(STYLE_CLASS);
		if (objectEntity != null){
			if (objectEntity.getClass() == String.class){
				styleClass = (String) objectEntity;
			}
		}
		
		entityName = (String)getAttributes().get(ENTITY_NAME);
		
		objectEntity = getAttributes().get(ENTITY_ID); 		
		if (objectEntity != null){
			if (objectEntity.getClass() == String.class){
				entityId = objectEntity;
				checkEntityId();
			} else if (objectEntity.getClass() == (Integer.class)){
				entityId = objectEntity;
			} else if (objectEntity.getClass() == (Long.class)){
				entityId = objectEntity.toString();
			} 
		}
		
		objectEntity = getAttributes().get(VALUE);
		if  (objectEntity != null){
			if (objectEntity.getClass().equals(String.class)){
				value = (String)objectEntity;				
			} else if (objectEntity.getClass() == (Long.class)){
				value = objectEntity.toString();
			} else if (objectEntity.getClass() == (Integer.class)){
				value = objectEntity.toString();
			} else if (objectEntity.getClass() == Boolean.class){
				value = objectEntity.toString();
			}
		}
		
		objectEntity = getAttributes().get(DESCRIPTION);
		if  (objectEntity != null){
			if (objectEntity.getClass() == String.class){
				description = (String)objectEntity;				
			} else if (objectEntity.getClass() == (Long.class)){
				description = objectEntity.toString();
			} else if (objectEntity.getClass() == (Integer.class)){
				description = objectEntity.toString();
			} else if (objectEntity.getClass() == (Boolean.class)){
				description = objectEntity.toString();
			}
		}
		
		if (getAttributes().get(SHOW) != null){
			show = getAttributes().get(SHOW).equals("true");
		}	
		
		displayOrder = (String)getAttributes().get(DISPLAY_ORDER);
		if (displayOrder == null){
			displayOrder = (String)SessionWrapper.getObjectField("articleFormat");			
		}
		
		if (description == null){
			setDescription();
		}
		
		objectEntity = getAttributes().get(STYLE);
		if  (objectEntity != null){
			if (objectEntity.getClass().equals(String.class)){
				style = (String)objectEntity;				
			}
		}
		
		objectEntity = getAttributes().get(CONTEXT_LINK);
		contextLink=(String) ((objectEntity!=null)?objectEntity:"false");
		
		objectEntity = getAttributes().get(CONTEXT_TYPE);
		if (objectEntity != null){
			if(objectEntity.getClass() == String.class){
				contextType=(String)objectEntity;
			}
		}
		
		objectEntity = getAttributes().get(BEAN);
		if (objectEntity != null){
			if(objectEntity.getClass() == String.class){
				bean = ((String)objectEntity);
				bean = bean.substring(bean.lastIndexOf(".")+1);
			}
		}
	}
	
	private void initValues(){
		entityId = null;
		value = null;
		entityName = null;
		rendered = true;
		show = false;
		description = null;
		styleClass = null;
		style = null;
		intEntityId = null;
		contextType = null;
		contextLink = null;
		bean = "";
	}
	
	private void nullChecker(){
		if (value == null){
			value = NO_DATA;
		}
	}
	
	private void setDescription(){
		if (displayOrder.equalsIgnoreCase(CODE_NAME)){
			description = (entityId != null) ? entityId + " - " + value : value;
		} else if (displayOrder.equalsIgnoreCase(NAME_CODE)){
			description = (entityId != null) ? value + " - " + entityId : value;
		} else if (displayOrder.equalsIgnoreCase(NAME)){
			description = value;
		} else if (displayOrder.equalsIgnoreCase(CODE)){
			description = ""+entityId;
		} else {
			description = (entityId != null) ? value + " - " + entityId : value;
		}
	}
	
	private void checkEntityId(){
		if (!entityId.toString().contains("%")){
			if ("ENTTACCT".equalsIgnoreCase(entityName)){
				intEntityId = Integer.parseInt(entityId.toString());
			}
			
		}
	}

	@Override
	public String toString() {
		return "EntityDisplay{" +
				"entityId=" + entityId +
				", value='" + value + '\'' +
				", description='" + description + '\'' +
				", show=" + show +
				", displayOrder='" + displayOrder + '\'' +
				", entityName='" + entityName + '\'' +
				", rendered=" + rendered +
				", styleClass='" + styleClass + '\'' +
				", style='" + style + '\'' +
				", intEntityId=" + intEntityId +
				", contextType='" + contextType + '\'' +
				", contextLink='" + contextLink + '\'' +
				", bean='" + bean + '\'' +
				'}';
	}
}
