package ru.bpc.jsf.uploadfile;

import javax.faces.webapp.UIComponentELTag;

public class FileUploadTag extends UIComponentELTag {

    public static final String COMP_TYPE = "ru.bpc.jsf.uploadfile.UIFileUpload";
	public static final String RENDER_TYPE = "ru.bpc.jsf.uploadfile.FileUploadRenderer";

	@Override
	public String getComponentType()
	{
		return COMP_TYPE;
	}
	
	@Override
	public String getRendererType()
	{
		return RENDER_TYPE;
	}
}
