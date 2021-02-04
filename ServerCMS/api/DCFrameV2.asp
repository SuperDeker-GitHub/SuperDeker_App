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
dim id
dim comment
dim repciId
dim fromUser
dim priv
dim when_date
dim fileId

dim dcId

dim StrSql
dim cantComments

cantComments = 0

dim retval

dim Conex
dim Rs
dim Rsc
dim CC
dim usr
dim especial


	'Se crea el objeto de la conexión
	set Conex = Server.CreateObject("ADODB.Connection")

	'Se abre la conexion y se ejecuta una consulta 
%>
	<!--#include file="dbconex.inc"-->
<%	
    dim ArchivosSalvados

	
	dcId = request.querystring("dcid")
	
	dim highlight
	
	highlight = ""
	
	highlight=request.querystring("hi")

	if trim(dcId) = "" then
		response.write "[ ],<BR>" 
		response.end
	end if
	
	usr = trim(request.querystring("usr")) ' para actualizar la cantidad de comentarios y dataclips leidos en repcisFavoritos
	
	'Checkinf if user can add comments to DataClips
	
	'SqlComd = "select gcmId from repciCreds where userid = '" & usr & "'"
	'set Rs = Conex.Execute(SqlComd)
	'especial = ""
	'if Not Rs.EOF then
'		especial = Rs("gcmId")			
	'end if
	'Set Rs = Nothing
	
	
	SqlComd = "select top 1 repciDCs.Id, repciDCs.comment, repciId, fromUser, convert(varchar, when_date, 100) as when_date,status,PrevDC,NextDC,(select titulo from repcis where repciid = repciDcs.repciId ) as Titulo,(select grupo from repcis where repciid = repciDcs.repciId ) as grupo,(select status from repcis where repciid = repciDcs.repciId ) as repcistatus, "
	SqlComd = SqlComd & "CAST( YEAR(when_date)*10000  + MONTH(when_date)* 100 + DAY(when_date) as nvarchar) +  'T'+ RIGHT('0' + CAST(DATEPART(HOUR,when_date)*10000 + DATEPART(MINUTE,when_date)*100 + DATEPART(SECOND,when_date) as nvarchar),6) as when_date2445,"
	SqlComd = SqlComd & "path as fileId, DCType, longitud, latitud, accuracy, filepath, IP, LocationOrigin, OriginalDC, SelloImage  from repciDCs Left Join repciFilePlace on repciFilePlace.id = repciDCs.fileId where repciDcs.id = " + dcId
	
	
	set Rs = Conex.Execute(SqlComd)

	retval = "["
	dim repciTId
	dim CantAnex

	CantAnex = 0
	repciTId=""
	CC = "'"

%>
<!DOCTYPE html><html lang='en' class=''>
<head><script src='//static.codepen.io/assets/editor/live/console_runner-ce3034e6bde3912cc25f83cccb7caa2b0f976196f2f2d52303a462c826d54a73.js'></script><script src='//static.codepen.io/assets/editor/live/css_reload-2a5c7ad0fe826f66e054c6020c99c1e1c63210256b6ba07eb41d7a4cb0d0adab.js'></script><meta charset='UTF-8'><meta name="robots" content="noindex"><link rel="shortcut icon" type="image/x-icon" href="//static.codepen.io/assets/favicon/favicon-8ea04875e70c4b0bb41da869e81236e54394d63638a1ef12fa558a4a835f1164.ico" /><link rel="mask-icon" type="" href="//static.codepen.io/assets/favicon/logo-pin-f2d2b6d2c61838f7e76325261b7195c27224080bc099486ddd6dccb469b8e8e6.svg" color="#111" /><link rel="canonical" href="https://codepen.io/andytran/pen/BNjymy" />
<script src="//use.typekit.net/xyl8bgh.js"></script>
<script>try{Typekit.load();}catch(e){}</script>
<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/meyer-reset/2.0/reset.min.css'><link rel='stylesheet' href='../assets/css/font-awesome.min.css'><link rel='stylesheet' href='//codepen.io/andytran/pen/vLmRVp.js.css'>
<style class="cp-pen-styles">body {
  background: #f2f2f2;
  font-family: 'proxima-nova-soft', sans-serif;
  font-size: 14px;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
.post-module {
  position: relative;
  z-index: 1;
  display: block;
  background: #FFFFFF;
  min-width: 270px;
  height: 460px;
  -webkit-box-shadow: 0px 1px 2px 0px rgba(0, 0, 0, 0.15);
  -moz-box-shadow: 0px 1px 2px 0px rgba(0, 0, 0, 0.15);
  box-shadow: 0px 1px 2px 0px rgba(0, 0, 0, 0.15);
  -webkit-transition: all 0.3s linear 0s;
  -moz-transition: all 0.3s linear 0s;
  -ms-transition: all 0.3s linear 0s;
  -o-transition: all 0.3s linear 0s;
  transition: all 0.3s linear 0s;
}
.post-module:hover,
.hover {
  -webkit-box-shadow: 0px 1px 35px 0px rgba(0, 0, 0, 0.3);
  -moz-box-shadow: 0px 1px 35px 0px rgba(0, 0, 0, 0.3);
  box-shadow: 0px 1px 35px 0px rgba(0, 0, 0, 0.3);
}
.post-module:hover .thumbnail img,
.hover .thumbnail img {
  -webkit-transform: scale(1.1);
  -moz-transform: scale(1.1);
  transform: scale(1.1);
  opacity: 1;

}
.post-module .thumbnail {
  background: #000000;
  height: 400px;
  overflow: hidden;
}
.post-module .thumbnail .date {
  position: absolute;
  top: 20px;
  right: 20px;
  z-index: 1;
  background: #e74c3c;
  width: 55px;
  height: 55px;
  padding: 12.5px 0;
  -webkit-border-radius: 100%;
  -moz-border-radius: 100%;
  border-radius: 100%;
  color: #FFFFFF;
  font-weight: 700;
  text-align: center;
  -webkti-box-sizing: border-box;
  -moz-box-sizing: border-box;
  box-sizing: border-box;
}

.fotoautor {
  position: absolute;
  top: 20px;
  right: 20px;
  z-index: 1;
   width: 55px;
  height: 55px;
  padding: 12.5px 0;
  -webkit-border-radius: 100%;
  -moz-border-radius: 100%;
  border-radius: 100%;
  color: #FFFFFF;
  text-align: center;
  -webkti-box-sizing: border-box;
  -moz-box-sizing: border-box;
  box-sizing: border-box;
}
.post-module .thumbnail .date .day {
  font-size: 18px;
}

.date > img {
	padding:0px;
}
.post-module .thumbnail .date .month {
  font-size: 12px;
  text-transform: uppercase;
}
.post-module .thumbnail img {
	position:relative;
  display: block;
  width: 120%;
  -webkit-transition: all 0.3s linear 0s;
  -moz-transition: all 0.3s linear 0s;
  -ms-transition: all 0.3s linear 0s;
  -o-transition: all 0.3s linear 0s;
  transition: all 0.3s linear 0s;
  top:-25%
}
.post-module .post-content {
  position: absolute;
  bottom: 0;
  background: #FFFFFF;
  width: 100%;
  padding: 30px;
  -webkti-box-sizing: border-box;
  -moz-box-sizing: border-box;
  box-sizing: border-box;
  -webkit-transition: all 0.3s cubic-bezier(0.37, 0.75, 0.61, 1.05) 0s;
  -moz-transition: all 0.3s cubic-bezier(0.37, 0.75, 0.61, 1.05) 0s;
  -ms-transition: all 0.3s cubic-bezier(0.37, 0.75, 0.61, 1.05) 0s;
  -o-transition: all 0.3s cubic-bezier(0.37, 0.75, 0.61, 1.05) 0s;
  transition: all 0.3s cubic-bezier(0.37, 0.75, 0.61, 1.05) 0s;
}
.post-module .post-content .category {
  position: absolute;
  top: -34px;
  left: 0;
  background: orange;
  nose:#e74c3c;
  padding: 10px 15px;
  color: #FFFFFF;
  font-size: 14px;
  font-weight: 600;
  text-transform: uppercase;
}
.post-module .post-content .title {
  margin: 0;
  padding: 0 0 10px;
  color: #333333;
  font-size: 20px;
  font-weight: 700;
}
.post-module .post-content .sub_title {
  margin: 0;
  padding: 0 0 20px;
  color: #e74c3c;
  font-size: 20px;
  font-weight: 400;
}
.post-module .post-content .description {
  display: none;
  color: #666666;
  font-size: 14px;
  line-height: 1.8em;
}
.post-module .post-content .post-meta {
  margin: 30px 0 0;
  color: #999999;
}
.post-module .post-content .post-meta .timestamp {
  margin: 0 16px 0 0;
}
.post-module .post-content .post-meta a {
  color: #999999;
  text-decoration: none;
}
.hover .post-content .description {
  display: block !important;
  height: auto !important;
  opacity: 1 !important;
}
.container {
  max-width: 600px;
    min-width: 300px;
  margin: 0 auto;
  font-size: 16px;
}
.container:before,
.container:after {
  content: '';
  display: block;
  clear: both;
}
.container .column {
  width: 100%;
  padding: 0 5px;
  -webkti-box-sizing: border-box;
  -moz-box-sizing: border-box;
  box-sizing: border-box;
  float: left;
}
.container .column .demo-title {
  margin: 0 0 15px;
  color: #666666;
  font-size: 18px;
  font-weight: bold;
  text-transform: uppercase;
}
.container .info {
  width: 300px;
  margin: 50px auto;
  text-align: center;
}
.container .info h1 {
  margin: 0 0 15px;
  padding: 0;
  font-size: 24px;
  font-weight: bold;
  color: #333333;
}
.container .info span {
  color: #666666;
  font-size: 12px;
}
.container .info span a {
  color: #000000;
  text-decoration: none;
}
.container .info span .fa {
  color: #e74c3c;
}
th, td {
    border-bottom: 1px solid #ddd;
}
tr:hover {background-color: #f5f5f5;}

#DcContent {
-webkit-transition: height 2s;
 transition: height 2s;
}
.shortDcContent{
	-webkit-transition: height 2s;
	transition: height 2s;
	height:10px;
}
.fullDcContent{
-webkit-transition: height 2s;
 transition: height 2s;
	height:260px;
}


</style>

<%

FUNCTION DescDC(DCCode)
		DescDC = DCCode
end function

Function parseURL(strText)
	dim regEx
  Set regEx = New RegExp
  regEx.Global = true
  regEx.IgnoreCase = True
  regEx.Pattern = "(\b(ht|f)tp(s?)://[^ ]+\b)"
  parseURL = regEx.Replace(strText,"<a href=""$1"" target=""_blank"">$1</a>")
End Function

FUNCTION DetectDCLink(Ctext)
	Dim CCtext
	CCtext = Ctext
	DcPos=InStr(CCtext,"dc(")
	dim DcPos
	dim Cierre
	dim Numero
	dim DcParams
	dim ComaSep
	dim DcId
	dim RexId
	if DcPos>0 then
		Cierre = InStr(DcPos,CCtext,")")
		if Cierre > 0 then
			DcParams = Mid(Ctext,DcPos + 3,Cierre-1)
			ComaSep = InStr(DcParams,",")
			if (ComaSep > 0) then
				DcId = left(DcParams,ComaSep-1)
				RexId = Mid(DcParams,ComaSep+1)
				RexId = Left(RexId,len(RexId)-1)
				CCtext = "<span>" & left(CCtext,DcPos-1) & "<i class='fa fa-list-alt' onclick='parent.ShowDCinGridById(" & DcId & "," & RexId & ")'> </i>" & Mid(CCtext,Cierre+1) & "</span>" '
				DcPos=InStr(CCtext,"dc(")
			else
				CCtext = "<span>" & left(CCtext,DcPos-1) & Mid(CCtext,Cierre+1) & "</span>" '
			end if
		else
			DcPos = 0
		end if
	end if
	DetectDCLink = CCtext
end function

Function GetTextFromUrl(url)
	Set HttpReq = Server.CreateObject("MSXML2.ServerXMLHTTP")
	HttpReq.open "GET", url, false
	HttpReq.Send("")	
    GetTextFromUrl = HttpReq.responseText
End Function


dim DCType
dim UltDC
dim Tuplas
dim SqlTuplas
dim RsTuplas
dim Texto
dim pos
dim resaltar

dim imagesrc
dim fotousr
'dim comment
'dim fromUser
dim DescDcType
dim fotoDc
dim status
dim PrevDC
dim NextDC
dim status0style
dim statusDC
dim Titulo
dim ShortTitulo
dim IP
dim LocationOrigin
dim DebugTrace
dim OriginalDC
dim Grupo
dim SelloImage
dim repcistatus

	
	While Not Rs.EOF
		repciId = Rs("repciId")
		OriginalDC = Rs("OriginalDC")&""
		if OriginalDC="" then
			OriginalDC ="0"
		end if
		
		fotousr="../aicons/user-" &  Rs("fromUser") & ".jpg"
		fotoDc = "Thumb.asp?path=" &  Rs("fileId")
		fromUser = Rs("fromUser")
		comment = Rs("comment")
		'comment = DetectDC(comment)
		status = Rs("status")
		repcistatus = Rs("repcistatus")
		PrevDC = Rs("PrevDC")&""
		if PrevDC="" then
			PrevDC ="0"
		end if
		NextDC = Rs("NextDC")&""
		if NextDC="" then
			NextDC ="0"
		end if
		
		Titulo = Rs("Titulo")
		IP = Rs("IP")
		LocationOrigin = Rs("LocationOrigin")
		if (len(Titulo)>30) then
			ShortTitulo = left(Titulo,30) & "..."
		else
			ShortTitulo = Titulo
		end if
		DCType = Trim(Rs("DCType"))
		
		DescDcType = DescDC(DCType)
		if DescDcType = "" then
			DescDcType = DCType
		end if
		Grupo=Rs("grupo")
		statusDC=status
		DebugTrace="DCType="&DCType&", status="&statusDC
		SelloImage=Rs("SelloImage")
		if status=-1 then
			status0style="opaque:0.5;background-image: url('../assets/NoValido2.png');background-repeat: no-repeat;background-position: 75% 75%; opacity:1;height:242px"
		else
			if DCType = "Tarea" then
				if statusDC = "1" or statusDC = "-2" then
					status0style="opaque:0.5;background-image: url('../assets/sello/aceptada.png');background-repeat: no-repeat;background-position: 75% 75%; opacity:1;height:242px"
				end if
				if statusDC = "2" or statusDC = "-3" then
					status0style="opaque:0.5;background-image: url('../assets/sello/enprogreso.png');background-repeat: no-repeat;background-position: 75% 75%; opacity:1;height:242px"
				end if
				if statusDC = "3" or statusDC = "-4" then
					status0style="opaque:0.5;background-image: url('../assets/sello/lista.png');background-repeat: no-repeat;background-position: 75% 75%; opacity:1;height:242px"
				end if
				if statusDC = "4" or statusDC = "-5" then
					status0style="opaque:0.5;background-image: url('../assets/sello/incompleta.png');background-repeat: no-repeat;background-position: 75% 75%; opacity:1;height:242px"
				end if
				if statusDC = "5" or statusDC = "-6" then
					status0style="opaque:0.5;background-image: url('../assets/sello/anulada.png');background-repeat: no-repeat;background-position: 75% 75%; opacity:1;height:242px"
				end if
				if statusDC = "6" or statusDC = "-7" then
					status0style="opaque:0.5;background-image: url('../assets/sello/borrada.png');background-repeat: no-repeat;background-position: 75% 75%; opacity:1;height:242px"
				end if
			else
				if DCType = "Recordatorio" then
					if statusDC = "3" or statusDC = "-4" then
						status0style="opaque:0.5;background-image: url('../assets/sello/listo.png');background-repeat: no-repeat;background-position: 75% 75%; opacity:1;height:242px"
					end if
					if statusDC = "6" or statusDC = "-7" then
						status0style="opaque:0.5;background-image: url('../assets/sello/borrada.png');background-repeat: no-repeat;background-position: 75% 75%; opacity:1;height:242px"
					end if
				else
					if DCType = "Cita" then
						if statusDC = "3" or statusDC = "-4" then
							status0style="opaque:0.5;background-image: url('../assets/sello/lista.png');background-repeat: no-repeat;background-position: 75% 75%; opacity:1;height:242px"
						end if
						if statusDC = "5" or statusDC = "-6" then
							status0style="opaque:0.5;background-image: url('../assets/sello/anulada.png');background-repeat: no-repeat;background-position: 75% 75%; opacity:1;height:242px"
						end if
						if statusDC = "6" or statusDC = "-7" then
							status0style="background-image: url('../assets/sello/borrada.png');background-repeat: no-repeat;background-position: 75% 75%; opacity:1;height:242px"
						end if
					else
						'cualquier sello en la estructura del dataclip
						if statusDC <> "0" then
							if statusDC < 0 then
								statusDC=(statusDC+1)*-1
							end if
							if Not IsNull(SelloImage) then
								status0style="background-image: url('../assets/sello/" &SelloImage & "');background-repeat: no-repeat;background-position: 75% 75%; opacity:1;height:242px"
							else
								SqlComd = "select src from sellos where grupo=" & Grupo & " and "
								SqlComd =SqlComd & " dctype = '"& DCType & "' and valor = " & statusDC
								dim selloRS
		
								set selloRS = Conex.Execute(SqlComd)
								if  Not selloRS.EOF then
									dim src
									src = selloRS("src")
									status0style="background-image: url('../assets/sello/" &src & "');background-repeat: no-repeat;background-position: 75% 75%; opacity:1;height:242px"
								end if
								Set selloRS = Nothing
							end if								
						end if
					end if
				end if
			end if
			if (OriginalDC<>"0") then
					if status0style <> "" then
						status0style = status0style + ";"
					end if
					status0style=status0style& " background-color: lightyellow "
			else
				OriginalDC="0"
			end if
			DebugTrace=DebugTrace & ", Style="&status0style
		end if
		
		if Not IsNull(Rs("filepath")) then
			imagesrc = Rs("filepath")
			fotoDc = "Thumb.asp?path=" &  Rs("filepath")	
		else
			if  Not IsNull(Rs("fileId")) then
				imagesrc = Rs("fileId")
			else
				imagesrc=""
			end if
		end if
		
		when_date = Rs("when_date")

		dim DCTr
		dim idDC 
		dim dummy
		dim TableContent
		idDC = id ' la primera puede que sea null, por lo que asi nos aseguramos que entre
		
		
		SqlTuplas = "select id,value1,value2,value3,value4,value5 from repciDCTuplas where idDC = " & Rs("Id")
	
		set RsTuplas = Conex.Execute(SqlTuplas)
		Tuplas = ""
		TableContent = "<table id='DcTable' border='0' style='padding:4px' width=""100%"">"
		While Not RsTuplas.EOF
			if RsTuplas("value2") <> "" or RsTuplas("value3") <> "" or RsTuplas("value4") <> "" or RsTuplas("value5") <> "" then
			
				TableContent = TableContent & "<tr>"
				TableContent = TableContent & "<td>"
				TableContent = TableContent & RsTuplas("value1")
				TableContent = TableContent & ":</td>"
				TableContent = TableContent & "<td style='word-break: break-word;'>"
				Texto = DetectDCLink(RsTuplas("value2"))
				
				Texto = replace(Texto,"//n", "<br>") ' para el caso de los EdtML que tienen CRLF
				Texto = parseURL(Texto)
				if (IsNumeric(Texto) and len(Texto)>=11) then 'puede ser un telefono
					Texto = "<a href=""tel:"&Texto&""">"&Texto&"</a>"
				end if
				
				if len(Texto) > 20 then
					dim res
					res = InStr(Texto," ")
					if res > 20 or res=0 then
						Texto=mid(Texto,1,20)& " " & mid(Texto,21)
					end if
				end if
				'pos = instr(ucase(Texto),ucase(highlight))	
				'if pos > 0 and len(highlight)>0 and len(Texto) > 0 then
				'	resaltar = mid(Texto,pos,len(highlight))
				'else
					resaltar = ""
				'end if

				TableContent = TableContent & Texto ' replace(Texto, resaltar, "<mark>" & resaltar & "</mark>")
				TableContent = TableContent & "</td>"
				if RsTuplas("value3") <> "" then
					TableContent = TableContent & "<td>"
					TableContent = TableContent & RsTuplas("value3")
					TableContent = TableContent & "</td>"
				end if
				if RsTuplas("value4") <> "" then
					TableContent = TableContent & "<td>"
					TableContent = TableContent & RsTuplas("value4")
					TableContent = TableContent & "</td>"
				end if
				if RsTuplas("value5") <> "" then
					TableContent = TableContent & "<td>"
					TableContent = TableContent & RsTuplas("value5")
					TableContent = TableContent & "</td>"
				end if
								
				TableContent = TableContent & "</tr>"
			end if
			RsTuplas.MoveNext
		wend
		Set RsTuplas = Nothing
		TableContent = TableContent & "</table>"
	
		Rs.MoveNext
	wend
	
	'Se eliminan los objetos de la memoria
	Set Rs = Nothing	
	
	Set Conex = Nothing
%>
<script>
function randomNumber(){
	return (Math.floor(Math.random() * 13));
}

function noimage(image){
	document.getElementById('DcImage').style.display = 'none';
	if ("<%=fotoDc%>".slice(-3)=='pdf'){
		document.getElementById('DcPdf').src="<%=fotoDc%>#toolbar=0&page=1&view=FitH";
		normalPdf();
		//document.getElementById('DcContent').style.height = '242px';
	}
	else{
		document.getElementById('DcContent').style.height = '400px';
	}
}

function noPdf(image){
	document.getElementById('DcPdf').style.display = 'none';
	if (document.getElementById('DcImage').style.display == 'none')
		document.getElementById('DcContent').style.height = '400px';
	//else
		//document.getElementById('DcContent').style.height = '242px';
}
var ImageZoomed=false;
var ImageHeight=0;

function fullImage(){
	if (document.getElementById('DcImage').style.display=='none'){
		fullPdf();
	}
	else{
		if (!ImageZoomed){
			DcContentHeight = document.getElementById('DcContent').style.height;
			document.getElementById('DcTable').style.display='none';	
			document.getElementById('DcFooter').style.display='none';	
			document.getElementById('DcContent').style.height = '10px';	
			ImageHeight=document.getElementById('DcImage').height*2;
			document.getElementById('DcImage').style.width = '100%'; //200%
			ImageZoomed=true;
		}else{
			normalImage();
		}
	}
}

function fullPdf(){
	if (document.getElementById('DcImage').style.display=='none'){
		if (!ImageZoomed){
			DcContentHeight = document.getElementById('DcContent').style.height;
			document.getElementById('DcTable').style.display='none';	
			document.getElementById('DcFooter').style.display='none';	
			document.getElementById('DcContent').style.height = '10px';	
			document.getElementById('DcPdf').style.height='400px';
			ImageHeight=document.getElementById('DcPdf').height;
			document.getElementById('DcPdf').style.width = '100%';
			ImageZoomed=true;
		}
		else{
			normalPdf();
		}
	}
}
function trackmouse(event){
			return;// esto funcionaba perfecto cuando el DcImage era 200% cuando zoom
	if (ImageZoomed){
		var x = event.clientX;
		var y = event.clientY;
		document.getElementById('DcImage').style.top = "-" + (ImageHeight-y)/400*y + "px";
		document.getElementById('DcImage').style.left =  "-" + (x-75) +"px";
	}
}
var DcContentHeight=-1;
function normalImage(){
	if (document.getElementById('DcImage').style.display=='none')
		normalPdf();	
	else{
		if (DcContentHeight==-1)
			DcContentHeight=document.getElementById('DcContent').style.height;
		document.getElementById('DcContent').style.height = DcContentHeight;	
		document.getElementById('DcTable').style.display='';//'block';	
		document.getElementById('DcFooter').style.display='';//'block';	
			
		document.getElementById('DcImage').style.left = '0px';
		document.getElementById('DcImage').style.top = '0px';
		
		document.getElementById('DcImage').style.width = '100%';
		document.getElementById('DcImage').style.heigth = '100%';
		
		ImageHeight=document.getElementById('DcImage').height;
		ImageZoomed=false;
	}
}

function normalPdf(){
	if (document.getElementById('DcImage').style.display=='none'){
		if (DcContentHeight==-1)
			DcContentHeight=document.getElementById('DcContent').style.height;
		document.getElementById('DcContent').style.height = DcContentHeight;	
		document.getElementById('DcTable').style.display='';//'block';	
		document.getElementById('DcFooter').style.display='';//'block';	
			
		document.getElementById('DcPdf').style.left = '0px';
		document.getElementById('DcPdf').style.top = '0px';
		
		document.getElementById('DcPdf').style.width = '100%';
		document.getElementById('DcPdf').style.height = '400px';
		
		ImageHeight=document.getElementById('DcPdf').height;
		ImageZoomed=false;
	}
}

function prevDC(DcId){
	alert ("Prev=>" + DcId);
}


function nextDC(DcId){
	alert ("Next=>" + DcId);
}

//function ActivaBotones(){
//	prevDC(<%=PrevDC%>);
//	nextDC(<%=NextDC%>);
//}

  
</script>
</head><body onload="window.parent.ActivaBotones(<%=PrevDC%>,<%=NextDC%>,<%=OriginalDC%>,<%=repcistatus%>);window.parent.ActivaBotonesEnGrid(<%=dcId%>,<%=PrevDC%>,<%=NextDC%>,<%=OriginalDC%>,<%=repcistatus%>);">
 <div class="container">
  <!-- Normal Demo-->
  <div class="column">
    <!-- Post-->
    <div class="post-module">
      <!-- Thumbnail-->
      <div class="thumbnail">
		<div class="fotoautor" id="fotoa">
			<img style="border-radius: 50%;border:black;border-style:solid;" src="<%=fotousr%>" title="<%=fromUser%>"  onerror="this.src='../aicons/default0.png'"/> 
		</div>
		<img id="DcImage" src="<%=fotoDc%>" style="background-color:white;" onload="normalImage()"  onerror="this.error=null;noimage(this);" onclick="fullImage()" onmousemove="trackmouse(event)" /> 
		<embed id="DcPdf" width="100%" heigth = "100%" type="application/pdf" style="background-color:white;" onload="normalPdf()"  onerror="noPdf(this);" onfocus="fullPdf()">
      </div>
      <!-- Post Content-->
      <div class="post-content" id="DcContent" style="<%=status0style%>">
        <div class="category" Title="<%=Titulo%>"><i class="fa fa-folder-o" style="font-size:18px;" onclick="parent.app.$refs.RexSelected.getRexData(parseInt(<%=repciId%>));"></i> <span onclick="fullImage()"><%=ShortTitulo%></span></div>
        <h1 class="title"><%=comment%></h1>
        <h2 class="sub_title"><%=DescDcType%></h2>
        <p class="description novalido" ><%=TableContent%></p>		
		<input type="hidden" id="statusDC" class="statusDC" value="<%=statusDC%>">
 		<input type="hidden" id="DCType" class="DCType" value="<%=DCType%>">
		<input type="hidden" id="DebugTrace"  value="<%=DebugTrace%>">
        
        <div id="DcFooter" class="post-meta">
			<div><span class="comments"><i class="fa fa-user-circle-o"></i><a href="#"><%=" " & fromUser & " "%></a></span><span class="timestamp"><i class="fa fa-clock-o"></i> <%=when_date%></span></div>
			<div ><span class="comments"><i class="fa fa-map-marker"></i><a href="#"><%=" " & LocationOrigin & " "%></a></span><span class="timestamp"><i class="fa fa-wifi"></i> <%=IP%></span></div>
		</div>
      </div>
    </div>
  </div>
  
</div>

</body></html>