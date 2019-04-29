package ru.bpc.jsf.misc.fieldset;

import javax.faces.webapp.UIComponentELTag;

public class UIFieldsetTag
	extends UIComponentELTag
{
	@Override
	public String getComponentType()
	{
		return "ru.bpc.jsf.misc.Fieldset";
	}
	
	@Override
	public String getRendererType()
	{
		return "ru.bpc.jsf.misc.FieldsetRenderer";
	}
	
}
