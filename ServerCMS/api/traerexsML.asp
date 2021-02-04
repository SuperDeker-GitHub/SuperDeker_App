
<%@ Language=VBScript %>
<% 
option explicit 
Response.Expires = -1
Server.ScriptTimeout = 600
Response.CodePage = 65001    
Response.CharSet = "utf-8"
%>
<!--#include file ="CurrentCalendarLanguage.inc"-->
<%
dim objItem

dim SqlComd
dim Where
dim titulo
dim mod_date
dim Radius
dim LastWebId

dim Foto
dim longitud
dim latitud
dim accuracy
dim status
dim provider
dim tipo
dim creator

dim Rsusr
dim StrSql
dim Fotos(5)
dim cantFotos

dim RepID

cantFotos = 0
dim rexs

dim SqlDC
dim DcLabel
dim DcValue


Rsusr = Request.QueryString("usr")
dim TED
dim GRP
dim Cu
dim d1,d2
dim BX
dim STT

TED = Request.QueryString("ted")
GRP = Trim(Request.QueryString("grp"))
Cu = Trim(Request.QueryString("u"))
d1= Trim(Request.QueryString("d1"))
d2= Trim(Request.QueryString("d2"))
BX = Trim(Request.QueryString("bx")) 
STT = Trim(Request.QueryString("s"))


if Trim(Rsusr) = "" then
	response.write "NEG"
	response.end
end if

if STT = "" then
	STT="1"
end if


dim Tz
Tz = Request.QueryString("tz")

dim retval

dim Conex
dim Rs
dim Rsc
dim CC

dim CurrentYear,CurrentMonth, CurrentDay

if BX="Tareas" or BX="Recordatorios" or BX="Citas" or BX="Vencimientos" then
	TED = ""
	GRP = ""
	d1 = ""
	CurrentMonth = Month(Date())
	CurrentDay = Day(Date())
	CurrentYear = Year(Date())
	d2 = CurrentYear & "-" & (right("0" & CurrentMonth,2)) & "-" & (right("0" & CurrentDay,2))
end if

	'Se crea el objeto de la conexion
	set Conex = Server.CreateObject("ADODB.Connection")

	'Se abre la conexion y se ejecuta una consulta
%>
	<!--#include file="dbconex.inc"-->
<%	
	
	dim FindText
	dim FindTim
	dim FindGRP
	dim FindOw
	
	if TED <> "" then
		FindText = " and  repcis.titulo like '%" & TED & "%' "
	else
		FindText = ""
	end if
	
	if GRP <> "" and GRP <> "0" then
		FindGRP = " and  repcis.grupo =" & GRP & " "
	else
		FindGRP = ""
	end if

	if Cu <> "T" then
		FindOw = " and  repcis.owner = '" & Cu & "'"		
	else
		FindOw = ""
	end if
	
	
	
	if d1 <> "" then
		FindTim = " and ((CAST(repcis.when_date as date) BETWEEN '" & d1 & "' "  
		if d2 <> "" then
			FindTim = FindTim & "AND '" & d2 & "')"
		else
		    FindTim = FindTim & "AND '" & d1 & "')"
		end if
		FindTim = FindTim & " or (CAST(repcis.mod_date as date) BETWEEN '" & d1 & "' "  
		if d2 <> "" then
			FindTim = FindTim & "AND '" & d2 & "')"
		else
		    FindTim = FindTim & "AND '" & d1 & "')"
		end if
		FindTim = FindTim & ") "
	end if

	dim FROM
		
	SqlComd = "select distinct repcis.repciId, repcis.repciType, repcis.grupo, repcis.titulo, repcis.descrip, " 
	SqlComd = SqlComd & "CAST( datepart(year,repcis.when_date)*10000+datepart(mm,repcis.when_date)*100+datepart(dd,repcis.when_date) as varchar(8)) + 'T' + right('00'+cast(datepart(hour,repcis.when_date)*10000 + datepart(mi,repcis.when_date)*100 + datepart(ss,repcis.when_date) as varchar(6)),6) as when_date ,"
	SqlComd = SqlComd & "CAST( datepart(year,repcis.mod_date)*10000+datepart(mm,repcis.mod_date)*100+datepart(dd,repcis.mod_date) as varchar(8)) + 'T' + right('00'+cast(datepart(hour,repcis.mod_date)*10000 + datepart(mi,repcis.mod_date)*100 + datepart(ss,repcis.mod_date) as varchar(6)),6) as mod_date, "
	SqlComd = SqlComd & "repcis.longitud, repcis.latitud, repcis.accuracy,repcis.altitud, repcis.bearing, repcis.provider, repcis.owner, repcis.creator, "
	SqlComd = SqlComd & "repcis.status,  repcis.q_attached, repcis.NotificationType, "
' 	SqlComd = SqlComd & "isnull(cantanex,-1) as favor, (q_attached-isnull(cantanex,0)) as NRA, "
	
	SqlComd = SqlComd & " (select top 1 repciFilePlace.Path from repciFilePlace, repciMedia where repciMedia.repciId = repcis.repciId and repciMedia.fileId = repciFilePlace.id) as picFiles, (Select top 1 filepath  FROM repciDcs where repciDcs.repciid = repcis.repciid  and status >= 0 ) as Images "
		
	FROM = "from repcis  "
	
	'FROM = FROM & ", repciCreds  "
	
	dim BXSql
	BXSql=""
		
	if BX="Tareas" then	
		BXSql = "	and repcis.status>=1 and repcis.status<=2 and repcis.repciId in	(select " 
		BXSql = BXSql &	"       repciDcs.repciid "
		BXSql = BXSql &	"	from "
		BXSql = BXSql &	"		repciDcs,repciDCTuplas "
		BXSql = BXSql &	"	where "
		BXSql = BXSql &	"		repciDcs.status>=0 and repciDcs.status<=2 and  "
		BXSql = BXSql &	"		repciDcs.id=repciDcTuplas.idDC  " 'and "
		'BXSql = BXSql &	"		repciDcTuplas.value1='Estado' and "
		'BXSql = BXSql &	"		repciDcTuplas.value2>='Activa' "
		BXSql = BXSql &	"	intersect "
		BXSql = BXSql &	"	select "
		BXSql = BXSql &	"		repciDcs.repciid "
		BXSql = BXSql &	"		from "
		BXSql = BXSql &	"			repciDcs,repciDCTuplas "
		BXSql = BXSql &	"		where "
		BXSql = BXSql &	"			repciDcs.status>=0 and repciDcs.status<=2 and  "
		BXSql = BXSql &	"			repciDcs.id=repciDcTuplas.idDC and "
		BXSql = BXSql &	"			repciDcTuplas.value1='" & langtext(EjecutorTarea) & "' and "
		BXSql = BXSql &	"			repciDcTuplas.value2='" & Rsusr & "' " 
		BXSql = BXSql &	"	intersect "
		BXSql = BXSql &	"	select "
		BXSql = BXSql &	"		repciDcs.repciid "
		BXSql = BXSql &	"		from "
		BXSql = BXSql &	"			repciDcs,repciDCTuplas "
		BXSql = BXSql &	"		where "
		BXSql = BXSql &	"			repciDcs.status>=0 and "
		BXSql = BXSql &	"			repciDcs.id=repciDcTuplas.idDC and "
		BXSql = BXSql &	"			repciDcTuplas.value1= '" & langtext(FechaTarea) & "' and "
		BXSql = BXSql &	"			repciDcTuplas.value2<='"&d2&"') "
	end if
	
	if BX="Recordatorios" then	
		BXSql = " and repcis.repciId in	(select " 
		BXSql = BXSql &	"       repciDcs.repciid "
		BXSql = BXSql &	"	from "
		BXSql = BXSql &	"		repciDcs,repciDCTuplas "
		BXSql = BXSql &	"	where "
		BXSql = BXSql &	"		repciDcs.status>=0 and repciDcs.status<=2 and  "
		BXSql = BXSql &	"		repciDcs.fromUser='" & Rsusr & "' and "
		BXSql = BXSql &	"		repciDcs.id=repciDcTuplas.idDC and "
		BXSql = BXSql &	"		repciDcs.DcType = '"& langtext(Recordatorio) &"' and "
		BXSql = BXSql &	"		repciDcTuplas.value1='" & langtext(FechaRecordatorio) & "' and "
		BXSql = BXSql &	"		repciDcTuplas.value2<='"&d2&"' "
		BXSql = BXSql &	" INTERSECT "
		BXSql = BXSql &	" select repciDcs.repciid "
		BXSql = BXSql &	" 	from "
		BXSql = BXSql &	" 		repciDcs,repciDCTuplas "
		BXSql = BXSql &	" 	where "
		BXSql = BXSql &	" 		repciDcs.status>=0 and "
		BXSql = BXSql &	"		repciDcs.fromUser='" & Rsusr & "' and "
		BXSql = BXSql &	" 		repciDcs.id=repciDcTuplas.idDC and "
		BXSql = BXSql &	"		repciDcs.DcType = '" & langtext(Recordatorio) & "')" ' and "
		'BXSql = BXSql &	"		repciDcTuplas.value1='Estado' and "
		'BXSql = BXSql &	"		repciDcTuplas.value2='Activo')"
		
	end if
	
	if BX="Citas" then	
		BXSql = " and repcis.status>=1 and repcis.status<=2	and repcis.repciId in	(select " 
		BXSql = BXSql &	"       repciDcs.repciid "
		BXSql = BXSql &	"	from "
		BXSql = BXSql &	"		repciDcs,repciDCTuplas "
		BXSql = BXSql &	"	where "
		BXSql = BXSql &	"		repciDcs.status=0 and  "
		BXSql = BXSql &	"		repciDcs.fromUser='" & Rsusr & "' and "
		BXSql = BXSql &	"		repciDcs.id=repciDcTuplas.idDC and "
		BXSql = BXSql &	"		repciDcs.DcType = '" & langtext(Cita) & "' and "
		BXSql = BXSql &	"		repciDcTuplas.value1='" & langtext(FechaCita) & "' and "
		BXSql = BXSql &	"		repciDcTuplas.value2<='"&d2&"' "
		BXSql = BXSql &	" INTERSECT "
		BXSql = BXSql &	" select repciDcs.repciid "
		BXSql = BXSql &	" 	from "
		BXSql = BXSql &	" 		repciDcs,repciDCTuplas "
		BXSql = BXSql &	" 	where "
		BXSql = BXSql &	" 		repciDcs.status=0 and "
		BXSql = BXSql &	"		repciDcs.fromUser='" & Rsusr & "' and "
		BXSql = BXSql &	" 		repciDcs.id=repciDcTuplas.idDC and "
		BXSql = BXSql &	"		repciDcs.DcType = '" & langtext(Cita) & "' )" ' and "
		'BXSql = BXSql &	"		repciDcTuplas.value1='Estado' and "
		'BXSql = BXSql &	"		repciDcTuplas.value2='Activo')"
		
	end if
	
	if BX="Vencimientos" then	
		BXSql = " and repcis.status>=1 and repcis.status<=2	and repcis.repciId in	(select " 
		BXSql = BXSql &	"       repciDcs.repciid "
		BXSql = BXSql &	"	from "
		BXSql = BXSql &	"		repciDcs,repciDCTuplas "
		BXSql = BXSql &	"	where "
		BXSql = BXSql &	"		repciDcs.status>=0 and repciDcs.OriginalDC IS NULL and "
		BXSql = BXSql &	"		repciDcs.fromUser='" & Rsusr & "' and "
		BXSql = BXSql &	"		repciDcs.id=repciDcTuplas.idDC and "
		BXSql = BXSql &	"		(repciDcTuplas.value1='" & langtext(FechaVencimiento) & "' or repciDcTuplas.value1='" & langtext(FechaCompromiso) & "' or repciDcTuplas.value1='" & langtext(FechaAviso) & "') and "
		BXSql = BXSql &	"		repciDcTuplas.value2<='"&d2&"' )"
		
	end if

	'Where = " where  repcis.owner = repciCreds.userid and repcitype < 8 and repcis.status = 1 and repcis.grupo in (select grupo from usuariosgrupo where userid='" & Rsusr & "') " & FindText &  FindTim & FindGRP & FindOw & BXSql
	Where = " where repcis.status = " & STT & " and repcis.grupo in (select grupo from usuariosgrupo where userid='" & Rsusr & "') " & FindText &  FindTim & FindGRP & FindOw & BXSql
	
	'Zonas Favoritas
	dim SqlComdBase
	dim X
	
	
	SqlComdBase = SqlComd
	
	dim top
	top = 1000
	if Trim(Request.QueryString("top")) <> "" then
		top = Trim(Request.QueryString("top"))
	end if
	
	dim SqlU 
	SqlU = SqlComd
	SqlComd = "Select distinct top " & top & " * from ( " & SqlComd & FROM & Where
	
	if TED <> "" then
		'Buscando en comentarios de RepciDcs
		'if Mid(TED,1,1)="#" and IsNumeric(Mid(TED,2)) then
			'Nothing
		'else
			FindText = " and  repcis.titulo like '%" & TED & "%' "			
			FROM = "from repcis " ' left join repcisFavoritos on repcis.repciId=repcisFavoritos.repciId and repcisFavoritos.userId='" & Rsusr & "' "
			FROM = FROM & " left join repciDCs on repciDCs.repciId=repcis.repciId "
			'FROM = FROM & ", repciCreds  "
			'Where = " where repcis.owner = repciCreds.userid and repcitype < 8 and repcis.status = 1 and repcis.grupo in (select grupo from usuariosgrupo where userid='" & Rsusr & "') " & FindText &  FindTim & FindGRP & FindOw
			Where = " where repcis.status = "&STT&" and repcis.grupo in (select grupo from usuariosgrupo where userid='" & Rsusr & "') " & FindText &  FindTim & FindGRP & FindOw
			SqlComd = SqlComd & " union "
			SqlComd = SqlComd & SqlU &  FROM & Where
			'Buscando en Value2 de RepciDcTuplas
			FindText = " and  repciDcTuplas.value2 like '%" & TED & "%' "
			FROM = "from repcis " ' left join repcisFavoritos on repcis.repciId=repcisFavoritos.repciId and repcisFavoritos.userId='" & Rsusr & "' "
			FROM = FROM & " left join repciDCs on repciDCs.repciId=repcis.repciId "
			FROM = FROM & " left join repciDCTuplas on repciDCs.Id=repciDCTuplas.IdDC "
			'FROM = FROM & ", repciCreds  "
			'Where = " where  repcis.owner = repciCreds.userid and repcitype < 8 and repcis.status = 1 and repcis.grupo in (select grupo from usuariosgrupo where userid='" & Rsusr & "') " & FindText &  FindTim & FindGRP & FindOw
			Where = " where  repcis.status = "&STT&" and repcis.grupo in (select grupo from usuariosgrupo where userid='" & Rsusr & "') " & FindText &  FindTim & FindGRP & FindOw
			SqlComd = SqlComd & " union "
			SqlComd = SqlComd & SqlU &  FROM & Where
		'end if
	end if

	SqlComd = SqlComd & ") as XX order by grupo asc ,mod_date desc "
	
	'response.write SqlComd
	
	set Rs = Conex.Execute(SqlComd)

	retval = "["
	dim repciTId
	dim SqlComm2 
	SqlComm2 = ""
	dim offset
	offset = -1
	dim Rex
	dim strDobleComillaText
	dim strComillaText
	dim picfiles
	dim Images
	While Not Rs.EOF
		if retval <> "[" then
			retval = retval + ","
		end if
		strDobleComillaText = Chr(34)
		strComillaText = Chr(39)
		picfiles =  Rs("picFiles") & ""
		Images = Replace(Rs("Images")&"",",",""",""") & ""
		
		if picfiles = "" then
			picfiles = "default" & Rs("grupo") & ".jpg"
		end if
		retval= retval & "{""repciId"" : " &  Rs("repciId") & ", ""reptype"": " & Rs("repciType") & ", ""grupo"": " & Rs("grupo") & ", ""notift"": " & Rs("NotificationType") & ", ""titulo"": """ & Replace(Rs("titulo"),strDobleComillaText,strComillaText&strComillaText) & """, ""mod_date"": """ & Rs("mod_date") &  """, ""when_date"": """ & Rs("when_date") & """, ""creator"" : """ & Rs("creator") & """, ""owner"" : """ & Rs("owner") & """, ""longitud"" : " & Rs("longitud") & ", ""latitud"" : " & Rs("latitud") & ", ""accuracy"" : " & Rs("accuracy")  & ", ""status"" : " & Rs("status") & ", ""cantanex"" : " & Rs("q_attached") & ", ""picfiles"": [""" & picfiles & """] , ""Images"": [""" & Images & """] "
		retval= retval & "}"
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
