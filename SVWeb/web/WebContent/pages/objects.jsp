<%@page import="java.util.*" %>
<table border=10%>
<TR><TH>Session Attribute Name</TH><TH>Session Attribute Value</TH><TH>STATUS</TH></TR>
<%
Enumeration en=session.getAttributeNames();
while(en.hasMoreElements())
{
String attrName=(String)en.nextElement();
if(session.getAttribute(attrName) instanceof java.io.Serializable)
out.println("<TR><TD>"+attrName+"</TD><TD></TD><TD><font color=green> SERIALIZABLE</font></TD></TR>");
else
out.println("<TR><TD>"+attrName+"</TD><TD></TD><TD><font color=red><b>NOT SERIALIZABLE</b></font></TD></TR>");
}

%>
</table>