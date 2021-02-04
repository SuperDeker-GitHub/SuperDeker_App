
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


dim StrSql

dim recs
dim usr
usr = Request.QueryString("u")
dim Dc
Dc = Request.QueryString("d")
dim repciId
repciId = Request.QueryString("r")
dim Table
Table = Request.QueryString("t")
'if Table <> "EstadoProrroga" and Table <> "Identificacion_Medica" and Table <> "tudesc_afiliados" and Table <> "inventariooce" and Table <> "srrempleados" and Table <> "tecnoequipo" and Table <> "credicardequipo" and Table <> "Cliente" and Table <> "Personas" and Table <> "Comercio" and Table <> "Gastos" and Table <> "Empresas" and Table <> "rdcs" and Table <> "rfqs" and Table <> "odcs" and Table <> "Acceso" and Table <> "Vacuna" then
'	response.write "NEG"
'	response.end
'end if

dim Status
Status = Request.QueryString("s")

if Trim(Status) = "" then
	Status="0"
end if

dim field
field = Request.QueryString("f")

dim GRP
GRP = Trim(Request.QueryString("grp"))

if Trim(usr) = "" then
	response.write "NEG"
	response.end
end if

dim NotInThisDC
NotInThisDC = Trim(Request.QueryString("nitdc"))

if NotInThisDC = "" then
	NotInThisDC=""
end if
dim nitdct
dim nitdcf
if NotInThisDC<>"" then
	nitdct=Request.QueryString("nitdct")
	nitdcf=Request.QueryString("nitdcf")	
end if


dim retval

dim Conex
dim Rs





	'Se crea el objeto de la conexión
	set Conex = Server.CreateObject("ADODB.Connection")
%>
	<!--#include file="dbconex.inc"-->
<%

	
	dim RecArray(100)
	dim top 
	top = 100
	
	if (DC="thisDossier") then	
		SqlComd = "Select repciDcs.id,value1,value2,repciDcs.repciId from repciDcs, repciDCTuplas where repciDcs.DCType='" & Table  & "' and repciDCTuplas.Value1 = '" & field & "' and repcidcTuplas.idDC=repciDcs.id and repciDcs.status = " & Status & " and repciDCs.repciid="& repciId 
		if NotInThisDC<>"" then
			SqlComd =SqlComd & " and repciDcs.id not in "
			SqlComd =SqlComd & " ( Select distinct left( (right(value2,len(value2)-charindex('dc(',value2)-2)) ,charindex( ',',(right(value2,len(value2)-charindex('dc(',value2)-2))) -1) "
			SqlComd =SqlComd & "  from repciDcs, repciDCTuplas, repcis "
			SqlComd =SqlComd & "  where repciDcs.DCType='"
			SqlComd =SqlComd & nitdct & "' and "
			SqlComd =SqlComd & " repciDCTuplas.Value1 = '" 
			SqlComd =SqlComd & nitdcf & "' and "
			SqlComd =SqlComd & " repcidcTuplas.idDC=repciDcs.id and repciDcs.repciid=repcis.repciid "
			SqlComd =SqlComd & " and repciDcs.status >= 0 ) " ' Para sacar el caso de que quede solo en status negativos (anulados)
		end if	
		SqlComd = SqlComd & " order by value2"
	else
		if (DC="DC") then
			SqlComd = "Select repciDcs.id,value1,value2,repciDcs.repciId from repciDcs, repciDCTuplas, repcis where repciDcs.DCType='" & Table  & "' and repciDCTuplas.Value1 = '" & field & "' and repcidcTuplas.idDC=repciDcs.id and repciDcs.status = " & Status & " and repciDcs.repciid=repcis.repciid and repcis.status=1 "
			if NotInThisDC<>"" then
				SqlComd =SqlComd & " and repciDcs.id not in "
				SqlComd =SqlComd & " ( Select distinct left( (right(value2,len(value2)-charindex('dc(',value2)-2)) ,charindex( ',',(right(value2,len(value2)-charindex('dc(',value2)-2))) -1) "
				SqlComd =SqlComd & "  from repciDcs, repciDCTuplas, repcis "
				SqlComd =SqlComd & "  where repciDcs.DCType='"
				SqlComd =SqlComd & nitdct & "' and "
				SqlComd =SqlComd & " repciDCTuplas.Value1 = '" 
				SqlComd =SqlComd & nitdcf & "' and "
				SqlComd =SqlComd & " repcidcTuplas.idDC=repciDcs.id and repciDcs.repciid=repcis.repciid "
				SqlComd =SqlComd & " and repciDcs.status >= 0 ) " ' Para sacar el caso de que quede solo en status negativos (anulados)
			end if
			'SqlComd =SqlComd & " order by repciDcs.id "
			SqlComd =SqlComd & " order by value2 "
		end if
	end if
	
	'response.write SqlComd
	
	set Rs = Conex.Execute(SqlComd)
	dim strDobleComillaText
	dim strComillaText
	strDobleComillaText = Chr(34)
	strComillaText = Chr(39)
	retval = "["		
	
	'if Not Rs.EOF then
	'	retval = retval & "{"
	'end if
	While Not Rs.EOF
		if retval <> "[" then
			retval = retval + ","
		end if
		retval = retval + "{"
		dim value1
		dim posDC
		value1 = Rs.Fields(2)
		posDC = InStr(value1,"dc(")
		if (IsNull(posDC) or posDC=0) then ' En caso de que ya value1 tenga un dc(Rex,Dc) es una indirección, se toma este dclink en lugar del que viene del query
			retval= retval & strDobleComillaText & "desc" & strDobleComillaText & ":" & strDobleComillaText & Rs.Fields(2) & strDobleComillaText & ","  & strDobleComillaText & "value" & strDobleComillaText  & ":" & strDobleComillaText & Rs.Fields(2) & " dc(" & Rs.Fields(0) & "," & Rs.Fields(3) & ")" & strDobleComillaText 
		else
			retval= retval & strDobleComillaText & "desc" & strDobleComillaText & ":" & strDobleComillaText & left(Rs.Fields(2),posDC-1) & strDobleComillaText & ","  & strDobleComillaText & "value" & strDobleComillaText  & ":" & strDobleComillaText & Rs.Fields(2) & strDobleComillaText 
		end if
		retval = retval + "}"
		Rs.MoveNext
	wend
'	if retval <> "[" then
'		retval= retval & "}"	
'	end if
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
