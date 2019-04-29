package ru.bpc.jsf.uploadfile;

import java.io.IOException;
import java.util.Map;

import javax.faces.component.UIComponent;
import javax.faces.component.UIForm;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.faces.context.ResponseWriter;
import javax.faces.render.FacesRenderer;
import javax.faces.render.Renderer;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ru.bpc.jsf.FacesUtils;

import org.apache.commons.fileupload.FileItem;
import ru.bpc.sv2.ui.utils.RequestContextHolder;

@FacesRenderer(componentFamily="ru.bpc.jsf.uploadfile.UIFileUpload", rendererType="ru.bpc.jsf.uploadfile.FileUploadRenderer")
public class FileUploadRenderer extends Renderer {
	
	public static final String PROGRESS_REQUEST_PARAM_NAME		= "FileUploadRenderer.progressRequest";

    public void decode(FacesContext context, UIComponent component) {
        assertValidInput(context, component);
        
        UIFileUpload input = (UIFileUpload) component;
        
        //Check whether this is a request for the progress of the upload, 
        //or if it is an actual upload request.
          
        ExternalContext extContext = context.getExternalContext();
        Map<String,String> parameterMap = extContext.getRequestParameterMap();
        String clientId = input.getClientId(context);
        Map<String,String> requestMap = extContext.getRequestParameterMap();
        
        if(requestMap.get(clientId) == null){
        	//Nothing to do.
        	return;
        }
 
        if(parameterMap.containsKey(PROGRESS_REQUEST_PARAM_NAME)){
        	//This is a request to get the progress on the file request.
        	//Get the progress and render it as XML
        	        	
        	HttpServletResponse response = RequestContextHolder.getResponse();
            
            // set the header information for the response
            response.setContentType("text/xml");
            response.setHeader("Cache-Control", "no-cache");
            
//            try {
//                ResponseWriter writer = FacesUtils.setupResponseWriter(context);
//                writer.startElement("progress", input);
//                writer.startElement("percentage", input);
//                //writer.writeText(result, null);
//                //Get the current progress percentage from the session (as set by the filter).
//                Double progressCount = (Double)extContext.getSessionMap().get("FileUpload.Progress." + input.getClientId(context));
//                
//                if(progressCount != null){
//                	writer.writeText(progressCount, null);
//                }else{
//                	//We havn't received the upload yet.
//                	writer.writeText("1", null);
//                }
//                
//                writer.endElement("percentage");
//                writer.startElement("clientId", input);
//                writer.writeText(input.getClientId(context), null);
//                writer.endElement("clientId");
//                writer.endElement("progress");
//                
//            } catch(Exception e){
//            	//Do some sot of error logging...
//            	throw new RuntimeException(e);
//            }
//             
        }else{
        	//Normal decoding request.
        	if(requestMap.get(clientId).toString().equals("file")){
        		try{
        			HttpServletRequest request = RequestContextHolder.getRequest();
        			FileItem fileData = (FileItem)request.getAttribute(clientId);
        			if(fileData != null) input.setSubmittedValue(fileData);
        			
        			//Now we need to clear any progress associated with this item.
        			extContext.getSessionMap().put("FileUpload.Progress." + input.getClientId(context),new Double(100));
        			
        		}catch(Exception e){
        			throw new RuntimeException("Could not handle file upload - please ensure that you have correctly configured the filter.",e);
        		}
        	}
        }
    }

    public void encodeEnd(FacesContext context, UIComponent component) throws IOException {

        if (!component.isRendered()) {
            return;
        }

        assertValidInput(context, component);
        ResponseWriter writer = context.getResponseWriter();
        UIFileUpload input = (UIFileUpload)component;
        
        writer.startElement("div", component);
        
        String style = (String)input.getAttributes().get( "style" );
        if(style!= null){
            writer.writeAttribute("style", style, "style"); 
        }
        
        String styleClass = (String)input.getAttributes().get( "styleClass" );
        if(styleClass!= null){
            writer.writeAttribute("styleClass", styleClass, "styleClass"); 
        }
        
        writer.startElement("div", component);
        writer.writeAttribute("id", input.getClientId(context) + "_stage1", "id"); //This id will be used by the Javascript 
        writer.writeAttribute("style", "display:block", "style");
         
        String iframeName = component.getClientId(context).replace(":","_") + "_iframe";
       
        //The File upload component
        writer.startElement("input", component);
        writer.writeAttribute("type", "file", null);
        writer.writeAttribute("name", component.getClientId(context), "id");
        writer.writeAttribute("id", component.getClientId(context),"id");
        writer.writeAttribute("readonly","true","readonly");
        String onclick = (String)component.getAttributes().get( "onclick" );
        writer.writeAttribute("onclick", onclick, "onclick");
        if(input.getValue() != null){
        	//Render the name of the file if available.
            FileItem fileData = (FileItem)input.getValue();
            writer.writeAttribute("value", fileData.getName(), fileData.getName());
        }
      //Render Additional javascript handles on the image if applicable;
        String onSubmit = (String)component.getAttributes().get( "onsubmit" );
        if(onSubmit != null){
        	writer.writeAttribute("onchange",onSubmit,"onsubmit");
    	}
        writer.endElement("input");

//        String iconURL = input.getUploadIcon();
        String iconURL = (String)component.getAttributes().get( "uploadIcon" );
        //Render the image, and attach the javascript event to it. 
        writer.startElement("div", component);
        writer.writeAttribute("style","display:block;width:100%;text-align:center;", "style"); 
        writer.startElement("img", component);
//        writer.writeAttribute("src",iconURL,"src");
        iconURL = context.getApplication().getViewHandler().getResourceURL( context, iconURL );
        iconURL = context.getExternalContext().encodeResourceURL( iconURL );
        String onimageclick = (String)component.getAttributes().get( "onimageclick" );
        if(onimageclick != null){
        	writer.writeAttribute("onclick",onimageclick,"onimageclick");
    	}
        
        Boolean hidebutton = Boolean.parseBoolean((String)component.getAttributes().get( "hidebutton" ));
       
        String imgStyle = "cursor:hand;cursor:pointer;";
        if (hidebutton) {
        	imgStyle += " display:none;";
        }
        writer.writeURIAttribute( "src", iconURL, "src" );
		writer.writeAttribute("id", input.getClientId(context) + ":submit_img", "id"); //This id will be used by the Javascript
        writer.writeAttribute("type","image","type"); 
        writer.writeAttribute("style",imgStyle,"style");
        
//        String image = context.getApplication().getViewHandler().getResourceURL( context, iconURL );
//		image = context.getExternalContext().encodeResourceURL( image );
//        writer.writeURIAttribute( "src", image, "src" );
        UIForm form = FacesUtils.getForm(context,component);
        
        if(form != null) {        	
        	String getFormJS = "document.getElementById('" + form.getClientId(context) + "')";
//        	String jsFriendlyClientID = input.getClientId(context).replace(":","_");
        	
        	//Sets the encoding of the form to be multipart required for file uploads and
        	//to submit its content through an IFRAME. The second stage of the component is 
        	//also initialised after 500 milliseconds.
        	
        	writer.writeAttribute("onclick",getFormJS + ".encoding='multipart/form-data';" + 
        									getFormJS + ".target='" + iframeName + "';" + 
        									getFormJS + ".submit();" +
        									getFormJS + ".encoding='application/x-www-form-urlencoded';" +
        									getFormJS + ".target='_self';",
        						  "onclick");
        }
        
        writer.endElement("img");
        
         //Now do the IFRAME we are going to submit the file/form to.
        writer.startElement("iframe", component);
        writer.writeAttribute("id", iframeName, null);
        writer.writeAttribute("name",iframeName,null);
        writer.writeAttribute("style","display:none;",null);
        String onframeload = (String)component.getAttributes().get( "onframeload" );
        if(onframeload != null){
        	writer.writeAttribute("onload",onframeload, "onframeload");
        }
        writer.endElement("iframe");
        writer.endElement("div");
        writer.endElement("div"); //End of Stage1
        
//        writer.startElement("div", component);
//        writer.writeAttribute("id", input.getClientId(context) + "_stage2", "id"); //Stage2.
//        writer.writeAttribute("align","center",null); 
//        writer.writeAttribute("style","display:none", "style");  
//        
//        String progressBarID = component.getClientId(context) + "_progressBar";
//        String progressBarLabelID = component.getClientId(context) + "_progressBarlabel";
//        
//        writer.startElement("div", component);
//        writer.writeAttribute("id",progressBarID,"id");
//        
//        String progressBarStyleClass = input.getProgressBarStyleClass();
//        if(progressBarStyleClass != null)  writer.writeAttribute("class",progressBarStyleClass,"class");
//        
//        for(int i=0;i<100;i++){
//        	 writer.write("<span>&nbsp;</span>");
//        }
//        
//        writer.endElement("div");
//        
//        writer.write("\n");
        
//        writer.startElement("div", component);
//        writer.writeAttribute("id",progressBarLabelID,"id");
//        writer.writeAttribute("style","text-align:center;font-weight:bold;","style");
//        writer.endElement("div");
        
//        writer.endElement("div"); //End of Stage2
//        
//        writer.write("\n");
        
        //Now some javascript
//        writer.startElement("script", component);
//        writer.write(getProgressBarJavaScript(context,form,input));
//        writer.endElement("script");
//        writer.endElement("div"); 
        
    }
    
    /*
    private String getProgressBarJavaScript(FacesContext context, UIForm form, UIFileUpload input){
    	StringBuilder builder = new StringBuilder();
    	String jsFriendlyClientID = input.getClientId(context).replace(":","_");
    	//Build a javascript function specific to this component.
    	builder.append("function refreshProgress" + jsFriendlyClientID + "(){												 \n" + 
    					//  Assume we are entering stage 2.
    					"	document.getElementById('" + input.getClientId(context) + "_stage1').style.display = 'none';	 \n" +
    					"	document.getElementById('" + input.getClientId(context) + "_stage2').style.display = '';		 \n" +
    					"	document.getElementById('" + input.getClientId(context) + "_stage3').style.display = 'none';	 \n" +
    					//  Create the AJAX post
						" AjaxRequest.post(					 \n" + 
						"   {								  \n" + 
						//  Specify the correct paramters so that the component is correctly handled 
						//ont the serverside.
						"    'parameters':{ '" + form.getClientId(context) + "':'" + form.getClientId(context) + "', " +
											 "'" + input.getClientId(context) + "':'" + input.getClientId(context) + "', " +
											 "'" + PROGRESS_REQUEST_PARAM_NAME + "':'1'," +
											 "'" + PagePhaseListener.AJAX_ABORT_PHASE + "':'4' }  \n" + //Abort at Phase 4.
						
						// Specify the callback method for successful processing.
						"    ,'onSuccess':function(req) {  \n" + 
					 	"   		var xml = req.responseXML; \n" + 
					 	"			if( xml.getElementsByTagName('clientId').length == 0) {  \n"+
					 	"				setTimeout(' refreshProgress" + jsFriendlyClientID + "()',200); \n" + 
					 	"				return; \n " + 
					 	"			} \n" + 
					 	"   		var clientId = xml.getElementsByTagName('clientId')[0].firstChild.nodeValue + '_progressBar'; \n" + 
					 	"   		var percentage = xml.getElementsByTagName('percentage')[0].firstChild.nodeValue; \n" + 
					 	"   		var innerSpans = document.getElementById(clientId).getElementsByTagName('span'); \n" + 
					 	"   		document.getElementById(clientId + 'label').innerHTML = Math.round(percentage) + '%'; \n" + 
					 	"   		 \n" +
					 	// Set the style classes of the spans based on the current progress.  
					 	"   		for(var i=0;i<innerSpans.length;i++){ \n" + 
					 	"   			if(i < percentage){ \n" + 
					 	"   				innerSpans[i].className = '" + input.getActiveStyleClass() + "'; \n" + 
					 	"   			}else{ \n" + 
					 	"   				innerSpans[i].className = '" + input.getCellStyleClass() + "';  \n" + 
					 	"   			}  \n" + 
					 	"   		}  \n" + 
					 	"   		 \n" + 
					 	// If the percentage is not 100, we need to carry on polling the server for updates.
					 	"   		if(percentage != 100){ \n" + 
					 	"   			setTimeout(' refreshProgress" + jsFriendlyClientID + "()',400); \n" + 
					 	"   		} else {  \n" +
					 	// The file upload is done - we now need to move the component into stage 3.
					 	"				document.getElementById('" + input.getClientId(context) + "_stage1').style.display = 'none';	 \n" +
					 	"				document.getElementById('" + input.getClientId(context) + "_stage2').style.display = 'none';	 \n" +
					 	"				document.getElementById('" + input.getClientId(context) + "_stage3').style.display = '';	 \n" +
					 	"			} 		\n" + 
					 	"   } \n" + 
					 	" } \n" + 
						"); \n" + 
					    "} \n");
    	
    	return builder.toString();
    }
*/
    private void assertValidInput(FacesContext context, UIComponent component) {
        if (context == null) {
            throw new NullPointerException("context should not be null");
        } else if (component == null) {
            throw new NullPointerException("component should not be null");
        }
    }

}