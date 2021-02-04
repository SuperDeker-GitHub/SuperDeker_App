
<%@ Language=VBScript %>
<% 
option explicit 
Response.Expires = -1
Server.ScriptTimeout = 600
Response.CodePage = 65001    
Response.CharSet = "utf-8"
%>

<%
dim objItem

dim SqlComd
dim Where
dim Rsusr
dim StrSql
dim GRP

Rsusr = Request.QueryString("usr")

GRP = Request.QueryString("grp")

if Trim(Rsusr) = "" then
	response.write "NEG"
	response.end
end if

if Trim(GRP) = "" then
	response.write "NEG"
	response.end
end if

if Not IsNumeric(GRP) then
	response.write "NEG"
	response.end
end if

dim Conex
dim Rs

	'Se crea el objeto de la conexión
	set Conex = Server.CreateObject("ADODB.Connection")
%>
	<!--#include file="dbconex.inc"-->
<%			
	dim RexArray(500)
	dim NELONG
	dim NELAT
	dim SWLONG
	dim SWLAT
	dim retval
		
	SqlComd = "select value,icon,tipo from optionsgroup where grupo=" & GRP & " order by tipo, value"
	
	set Rs = Conex.Execute(SqlComd)

	retval = "["
	dim repciTId
	dim offset
	offset = -1
	While Not Rs.EOF
		if retval <> "[" then
			retval = retval + ","
		end if
		retval= retval & "{""value"" : """ &  Rs("value") & """ , ""icon"" : """ &  Rs("icon") & """ , ""tipo"" : """ &  Rs("tipo") & """}"
		Rs.MoveNext
	wend
	retval = retval & "]"
			
	'Se eliminan los objetos de la memoria
	Set Rs = Nothing
	Set Conex = Nothing

%>
<% 
response.ContentType="application/json"
response.write retval
response.end
%>
