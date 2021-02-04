
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

Rsusr = Request.QueryString("usr")

if Trim(Rsusr) = "" then
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
		
	SqlComd = "select usuariosgrupo.grupo, grupo.name,grupo.icon from usuariosgrupo,grupo where usuariosgrupo.userid='" & Rsusr & "' and usuariosgrupo.grupo=grupo.id order by usuariosgrupo.grupo"
	
	set Rs = Conex.Execute(SqlComd)

	retval = "["
	dim repciTId
	dim offset
	offset = -1
	While Not Rs.EOF
		if retval <> "[" then
			retval = retval + ","
		end if
		retval= retval & "{""grupo"" : """ &  Rs("grupo") & """ , ""name"" : """ &  Rs("name") & """, ""icon"" : """ &  Rs("icon") & """}"
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
