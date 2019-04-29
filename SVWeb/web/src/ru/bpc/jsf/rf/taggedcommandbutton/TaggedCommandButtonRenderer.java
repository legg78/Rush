package ru.bpc.jsf.rf.taggedcommandbutton;

import java.io.IOException;
import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.context.ResponseWriter;
import javax.faces.render.FacesRenderer;

import org.ajax4jsf.component.UIAjaxCommandButton;
import org.ajax4jsf.renderkit.ComponentVariables;
import org.ajax4jsf.renderkit.ComponentsVariableResolver;
import org.ajax4jsf.renderkit.html.CommandButtonRenderer;

@FacesRenderer(componentFamily="javax.faces.Command", rendererType="ru.bpc.jsf.rf.taggedcommandbutton.TaggedCommandButtonRenderer")
public class TaggedCommandButtonRenderer
	extends CommandButtonRenderer
{

	@Override
	protected Class<? extends javax.faces.component.UIComponent> getComponentClass()
	{
		return UIAjaxCommandButton.class;
	}
	
	private String convertToString(Object obj)
	{
		return ( ( obj == null ) ? "" : obj.toString() );
	}
	
	@Override
	public void doEncodeEnd( ResponseWriter writer, FacesContext context,
			UIAjaxCommandButton component, ComponentVariables variables )
		throws IOException
	{
		writer.endElement( "button" );
	}
	
	@Override
	public void doEncodeEnd( ResponseWriter writer, FacesContext context, UIComponent component )
		throws IOException
	{
		ComponentVariables variables = ComponentsVariableResolver.getVariables(	this, component );
		doEncodeEnd( writer, context, (UIAjaxCommandButton)component, variables );
		
		ComponentsVariableResolver.removeVariables( this, component );
	}
	
	@Override
	public void doEncodeBegin(ResponseWriter writer, FacesContext context, UIComponent component) throws IOException
	{
	  ComponentVariables variables = ComponentsVariableResolver.getVariables(this, component);
	  doEncodeBegin(writer, context, (UIAjaxCommandButton)component, variables);
	}

	private void doEncodeBegin( ResponseWriter writer, FacesContext context, UIAjaxCommandButton component, ComponentVariables variables )
		throws IOException
	{
		String clientId = component.getClientId( context );
		writer.startElement( "button", component );
		String styleClass = "pzKpfwBtn";
		Object styleClassAttr = component.getAttributes().get( "styleClass" );
		if ( styleClassAttr != null )
		{
			styleClass += " " + component.getAttributes().get( "styleClass" );
		}
		getUtils().writeAttribute( writer, "class",	styleClass );
		getUtils().writeAttribute( writer, "id", clientId );
		getUtils().writeAttribute( writer, "name", clientId );
		getUtils().writeAttribute( writer, "onclick", getOnClick( context, component ) );
		
		getUtils().encodeAttributesFromArray(
				context,
				component,
				new String[] { "accesskey", "alt",
						"dir", "disabled", "lang", 
						"onblur", "ondblclick", "onfocus",
						"onkeydown", "onkeypress", "onkeyup", "onmousedown",
						"onmousemove", "onmouseout", "onmouseover", "onmouseup", 
						"style", "tabindex", "title", "type", "usemap", "xml:lang" } );

		String text = convertToString( component.getValue() );
		if ( (String)component.getAttributes().get( "image" ) != null )
		{
			String iconPosition = (String)component.getAttributes().get( "iconPosition" );
			if ( iconPosition == null )
			{
				iconPosition = "left";
			}
			
			writer.startElement( "span", component );
			if ( iconPosition.equals( "left" ) )
			{
				writer.startElement( "nobr", component );
				writeImage( writer, context, component );
				writeText( writer, text, component );
				writer.endElement( "nobr" );
			}
			else if ( iconPosition.equals( "right" ) )
			{
				writer.startElement( "nobr", component );
				writeText( writer, text, component );
				writeImage( writer, context, component );
				writer.endElement( "nobr" );
			}
			else if ( iconPosition.equals( "top" ) )
			{
				writeText( writer, text, component );
				writer.startElement( "br", component );
				writer.endElement( "br" );
				writeImage( writer, context, component );
			}
			else if ( iconPosition.equals( "bottom" ) )
			{
				writeImage( writer, context, component );
				writer.startElement( "br", component );
				writer.endElement( "br" );
				writeText( writer, text, component );
			}
			else
			{
				writeImage( writer, context, component );
				writeText( writer, text, component );
			}
			writer.endElement( "span" );
		}
		else
		{
			writer.startElement( "span", component );
			writeText( writer, text, component );
			writer.endElement( "span" );
		}
	}

	private void writeText( ResponseWriter writer, String text, UIAjaxCommandButton component )
		throws IOException
	{
//		writer.startElement( "span", component );
		writer.writeText( text, component, "value" );
//		writer.endElement("span");
	}

	private void writeImage( ResponseWriter writer, FacesContext context,
			UIAjaxCommandButton component )
		throws IOException
	{
		String image = (String)component.getAttributes().get( "image" );
		if( image != null )
		{
			writer.startElement( "img", component );
			
			image = context.getApplication().getViewHandler().getResourceURL( context, image );
			image = context.getExternalContext().encodeResourceURL( image );
			
			writer.writeURIAttribute( "src", image, "image" );
			
			getUtils().encodeAttributesFromArray(
					context,
					component,
					new String[] { "alt", "usemap", "xml:lang" } );
			writer.endElement( "img" );
		}
	}
}
