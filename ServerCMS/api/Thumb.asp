<%
Response.Expires = 0

' create instance of AspJpeg

Set Jpeg = Server.CreateObject("Persits.Jpeg")

' Open source file
Path = Server.MapPath("/repci/repcipics/" & Request("path"))

dim YearMonth
YearMonth=""

dim fs
set fs=Server.CreateObject("Scripting.FileSystemObject")
if fs.FileExists(Path) then
	if InStr(Path,".jpg") then
		
		Jpeg.Open( Path )

		' Set new height and width
		if Request("Width") = 0 then 
			Jpeg.Width = 800
		else
			Jpeg.Width = Request("Width")
		end if

		Jpeg.Height = Jpeg.OriginalHeight * Jpeg.Width / Jpeg.OriginalWidth

		' Perform resizing and 
		' send resultant image to client browser
		Jpeg.SendBinary
		set fs=nothing
	end if
	if InStr(Path,".mp3") then
		response.redirect "https://www.tuapoyo.net/repci/repcipics/" & Request("path")
	end if
else
	set fs=nothing
	Path = Request("path")
	if InStr(Path,"-D") = 0 then
		YearMonth=StrReverse(Path)
		YearMonth=left(YearMonth,19)
		YearMonth=StrReverse(YearMonth)
		YearMonth=left(YearMonth,6)
	else
		' Proxima version con la estructura de nombre de archivo tipo user-GgrupoDfechaThora.jpg
		YearMonth=mid(Path,InStr(Path,"-D")+2,6)
	end if
	response.Redirect "../DCImages/"&Request("path")
	'response.Redirect "http://www.emodydynamics.org/VeraClips/timthumb.php?src=" & YearMonth & "/" + Request("path")&"&w="&Request("Width")
end if



%>