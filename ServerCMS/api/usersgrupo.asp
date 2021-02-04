
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
dim Foto
dim longitud
dim latitud
dim accuracy
dim FotoPath
dim Rsusr
dim StrSql
dim Fotos(5)
dim cantFotos

FotoPath = Server.MapPath("hueco.jpg")
FotoPath = left(FotoPath,len(FotoPath)-16) + "repcipics"

Rsusr = Request.QueryString("usr")
dim GRP

GRP = Trim(Request.QueryString("grp"))

if Trim(Rsusr) = "" then
	response.write "NEG"
	response.end
end if

if Trim(GRP) = "" then
	response.write "NEG"
	response.end
end if


dim Conex
dim Rs

	'Se crea el objeto de la conexión
	set Conex = Server.CreateObject("ADODB.Connection")

	'Se abre la conexión y se ejecuta una consulta
	'Conex.Open "Provider=SQLOLEDB;Data Source=sql2k804.discountasp.net;" _
    '        & "Initial Catalog=SQL2008R2_768156_tuapoyo;User Id=SQL2008R2_768156_tuapoyo_user;Password=5592454;" _
    '        & "Connect Timeout=15;Network Library=dbmssocn;"
	Conex.Open "Provider=SQLOLEDB;Data Source=s07.everleap.com;" _
           & "Initial Catalog=DB_4666_tuapoyo;User Id=DB_4666_tuapoyo_user;Password=v5592454;" _
            & "Connect Timeout=15;Network Library=dbmssocn;"
	
	dim RexArray(500)
	dim NELONG
	dim NELAT
	dim SWLONG
	dim SWLAT
	dim retval
		
	SqlComd = "select distinct top 100 userid from usuariosgrupo where grupo=" & GRP & " order by userid"
	
	set Rs = Conex.Execute(SqlComd)

	retval = "["
	dim repciTId
	dim offset
	offset = -1
	While Not Rs.EOF
		if retval <> "[" then
			retval = retval + ","
		end if
		retval= retval & "{""userid"" : "" " &  Rs("userId") & " ""}"
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
