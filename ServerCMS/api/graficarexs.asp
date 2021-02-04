
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
dim titulo
dim mod_date
dim LastWebId

dim SqlDC
dim DcLabel
dim DcValue

dim Rsusr

Rsusr = Request.QueryString("usr")
dim TED
dim TIM
dim GRP
dim Cu
dim d1,d2

TED = Request.QueryString("ted")
GRP = Trim(Request.QueryString("grp"))
Cu = Trim(Request.QueryString("u"))
d1= Trim(Request.QueryString("d1"))
d2= Trim(Request.QueryString("d2"))

if Trim(Rsusr) = "" then
	response.write "NEG"
	response.end
end if

dim retval

dim Conex
dim Rs
dim Rsc
dim CC


	'Se crea el objeto de la conexi�n
	set Conex = Server.CreateObject("ADODB.Connection")
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
	
	if GRP <> "" then
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
		FindTim = " and (CAST(repcis.when_date as date) BETWEEN '" & d1 & "' "  
		if d2 <> "" then
			FindTim = FindTim & "AND '" & d2 & "')"
		else
		    FindTim = FindTim & "AND '" & d1 & "')"
		end if
	end if

	dim FROM
	
		SqlComd = "select repcis.repciId, " 
		SqlComd = SqlComd & "CAST( repcis.when_date as date) as when_date "
		
		FROM = "from repcis, repciCreds  "
		
		Where = " where  repcis.owner = repciCreds.userid and  repcis.status = 1 " & FindText &  FindTim & FindGRP & FindOw 
		
		dim SqlComdBase
		dim X
		
		SqlComdBase = SqlComd
		
		
		dim SqlU 
		SqlU = SqlComd
		SqlComd = " Select count(*) as cantidad, when_date from ( Select distinct repciId,when_date from (" & SqlComd & FROM & Where
		
		if TED <> "" then
				'Buscando en Value2 de RepciDcTuplas
				FindText = " and  repciDcTuplas.value2 like '%" & TED & "%' "
				FROM = "from repcis "
				FROM = FROM & " left join repciDCs on repciDCs.repciId=repcis.repciId "
				FROM = FROM & " left join repciDCTuplas on repciDCs.Id=repciDCTuplas.IdDC "
				FROM = FROM & ", repciCreds  "
				Where = " where  repcis.owner = repciCreds.userid and repcis.status = 1 " & FindText &  FindTim & FindGRP & FindOw
				SqlComd = SqlComd & " union "
				SqlComd = SqlComd & SqlU &  FROM & Where
			'end if
		end if

		SqlComd = SqlComd & ") as YY) as XX group by when_date order by when_date"
	
	'response.write SqlComd & "<BR>"
	
	set Rs = Conex.Execute(SqlComd)

	retval = "{"
	retval = retval & " ""cols"": ["
	retval = retval & "{""id"":"""",""label"":""Dia"",""pattern"":"""",""type"":""string""},"
	retval = retval & "{""id"":"""",""label"":""Cantidad"",""pattern"":"""",""type"":""number""}"
	retval = retval & " ],"
	retval = retval & " ""rows"": ["
	While Not Rs.EOF
		retval= retval & "{""c"" :[{""v"":""" & RS("when_date") & """,""f"":null},{""v"":" &  Rs("cantidad") & ",""f"":null}]}"
		Rs.MoveNext
		if (Not Rs.EOF) then
			retval=retval & ","
		end if
	wend
	retval = retval & "]}"
			
	'Se eliminan los objetos de la memoria
	Set Rs = Nothing
	Set Conex = Nothing

%>
<% 
response.ContentType="application/json"
response.write retval
response.end
%>
