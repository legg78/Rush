package ru.bpc.jsf.misc.fieldset;

import java.io.IOException;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.context.ResponseWriter;
import javax.faces.render.FacesRenderer;
import javax.faces.render.Renderer;
@FacesRenderer(componentFamily="ru.bpc.jsf.misc.Fieldset", rendererType="ru.bpc.jsf.misc.FieldsetRenderer")
public class UIFieldsetRenderer
	extends Renderer
{
	
	@Override
	public void encodeBegin( FacesContext context, UIComponent component )
		throws IOException
	{
		ResponseWriter writer = context.getResponseWriter();
		writer.startElement( "fieldset", component );
		
		writeAttribute( writer, "style", component );
		writeAttribute( writer, "styleClass", "class", component );

		if ( component.getAttributes().containsKey( "text" ) )
		{
			writer.startElement( "legend", component );
			writer.writeText( component.getAttributes().get( "text" ), null );
			writer.endElement( "legend" );
		}
		else if ( component.getFacet( "header" ) != null )
		{
			writer.startElement( "legend", component );
			renderChild( context, component.getFacet( "header" ) );
			writer.endElement( "legend" );
		}
	}

	@Override
	public void encodeEnd( FacesContext context, UIComponent component )
		throws IOException
	{
		context.getResponseWriter().endElement( "fieldset" );
	}
	
	protected void renderChild( FacesContext context, UIComponent component )
		throws IOException
	{
		if ( !component.isRendered() )
		{
			return;
		}
		
		if ( component.getRendersChildren() )
		{
			component.encodeAll( context );
		}
		else
		{
			component.encodeBegin( context );
			for ( UIComponent child : component.getChildren() )
			{
				renderChild( context, child );
			}
			component.encodeEnd( context );
		}
	}
	
	protected void writeAttribute( ResponseWriter writer, String attributeName, String writtenName, UIComponent component )
		throws IOException
	{
		Object attrValue = component.getAttributes().get( attributeName );
		
		if ( attrValue != null )
		{
			writer.writeAttribute( writtenName, attrValue, null );
		}
	}
	
	protected void writeAttribute( ResponseWriter writer, String attributeName, UIComponent component )
		throws IOException
	{
		writeAttribute( writer, attributeName, attributeName, component );
	}
}
