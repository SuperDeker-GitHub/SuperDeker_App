var LocalLanguage = 'en';

var langtext=[
    { 
        "Textos en Scripts":"langtext[0].;",
        "NoTareas":"can't retrieve Tasks",
        "NoReminders":"can't retrieve Reminders",
        "NoAppointments":"can't retrieve Appointments",
        "NoAvisos":"can't retrieve Alerts",
        "NoVencimientos":"can't retrieve Due dates",
        "NoCompromisos":"can't retrieve agreed dates",
        "Hoy":"Today",
        "mes":"month",
        "lista":"list",
        "InvalidDate":"Invalid date"
    },
    {
        "Titles en html":""
        
    },
    {
        "alt Texts": ""      
    },
    {
        "innerHTML Text":"",
        "RefTareas":"Tasks",
        "ReReminder":"Re",
        "minder":"minder",
        "RefCitas":"Appointments",
        "Due":"Due",
        "DueDates":" dates",
        "AleAlerts":" Ale",
        "Alerterts":"rts",
        "Comps":" Agreed",
        "promisos":" dates"
    },
    {
        "Placeholders":""
        
    }

];
function SetCurrentLanguageTexts(){
    var elem=null;
    
    for(var Tit in langtext[1]){//Titles
        try{
            elem = document.getElementById(Tit);
            elem.title = langtext[1][Tit];
        }catch(e){}
    }
    for(var alts in langtext[2]){//alts
        try{
            elem = document.getElementById(alts);
            elem.alt = langtext[2][alts];
        }catch(e){}
    }
    for(var inners in langtext[3]){//innerHtml
        try{
            elem = document.getElementById(inners);
            elem.innerHTML = langtext[3][inners];
        }catch(e){}
    }
    for(var places in langtext[4]){//placeholders
        try{
            elem = document.getElementById(places);
            elem.placeholder = langtext[4][places];
        }catch(e){}
    }

}




