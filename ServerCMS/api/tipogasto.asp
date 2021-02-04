
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

	Conex.Open "Provider=SQLOLEDB;Data Source=s07.everleap.com;" _
           & "Initial Catalog=DB_4666_tuapoyo;User Id=DB_4666_tuapoyo_user;Password=v5592454;" _
            & "Connect Timeout=15;Network Library=dbmssocn;"
	
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
	
			
		SqlComd =           "select count(*) as cantidad, repciDcTuplas.value2 as TipoGasto "
		SqlComd = SqlComd & "from repcis left join repciDCs on repciDCs.repciId=repcis.repciId "
		SqlComd = SqlComd & "left join repciDCTuplas on repciDCs.Id=repciDCTuplas.IdDC , "
		SqlComd = SqlComd & "repciCreds "
		SqlComd = SqlComd & "where "
		SqlComd = SqlComd & "repcis.owner = repciCreds.userid and "
		SqlComd = SqlComd & "repcis.status = 1 "
		if TED <> "" then
			FindText = " and repcis.titulo like '%" & TED & "%' "
		else
			FindText = ""
		end if
		SqlComd = SqlComd & FindText 
		SqlComd = SqlComd &	" and repciDcTuplas.value1 like 'TipoGasto' " 
		SqlComd = SqlComd & FindTim '" (CAST(repcis.when_date as date) BETWEEN '2018-11-01' AND '2018-11-30') and "
		if GRP <> "" then
			FindGRP = " and  repcis.grupo =" & GRP & " "
		else
			FindGRP = ""
		end if
		SqlComd = SqlComd & FindGRP 
		SqlComd = SqlComd & " group by repciDcTuplas.value2 order by cantidad"
	
	
	'response.write SqlComd & "<BR>"
	
	set Rs = Conex.Execute(SqlComd)

	retval = "{"
	retval = retval & " ""cols"": ["
	retval = retval & "{""id"":"""",""label"":""TipoGasto"",""pattern"":"""",""type"":""string""},"
	retval = retval & "{""id"":"""",""label"":""Cantidad"",""pattern"":"""",""type"":""number""}"
	retval = retval & " ],"
	retval = retval & " ""rows"": ["
	While Not Rs.EOF
		retval= retval & "{""c"" :[{""v"":""" & RS("TipoGasto") & """,""f"":null},{""v"":" &  Rs("cantidad") & ",""f"":null}]}"
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
