importScripts('https://storage.googleapis.com/workbox-cdn/releases/4.3.1/workbox-sw.js');

importScripts('https://unpkg.com/dexie@2.0.4/dist/dexie.js');

const db = new Dexie('RexSet');
if (db) {
	db.version(1).stores({
		rexs: '++id,repciId,when_date',
		DataClips:'++id,repciId,filename',
		Tuplas:'++id,idDC,value1,value2',
		vars:'++id,var'
	});	
}

if (workbox) {
  console.log('Fino! Workbox is loaded');
  workbox.precaching.precacheAndRoute([
	'.',
    'index.html',
	'api/DCFrame.html',
	'https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js',
	'https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.0/jquery-ui.js',
	'https://cdn.jsdelivr.net/npm/signature_pad@2.3.2/dist/signature_pad.min.js',
	'https://unpkg.com/dexie@2.0.4/dist/dexie.js',
	'https://cdn.jsdelivr.net/npm/vue@2.5.13/dist/vue.js',
	'https://cdnjs.cloudflare.com/ajax/libs/vue-resource/0.7.2/vue-resource.min.js',
	'https://cdnjs.cloudflare.com/ajax/libs/date-fns/1.29.0/date_fns.js',
	'https://unpkg.com/vue-airbnb-style-datepicker@2.7.1/dist/vue-airbnb-style-datepicker.min.css',
	'https://storage.googleapis.com/workbox-cdn/releases/4.3.1/workbox-sw.js',	
	'assets/DossierSplashLogo.png',
	'assets/loading.gif',
	'assets/camara.png',
	'assets/stamp.png',
	'assets/reminder.png',
	'assets/rot-right.png',
	'assets/rot-left.png',
	'assets/noimg.png',
	'assets/flip.png',
	'assets/cargando.gif',
	'assets/FolderVert.png',
	'drawable/ic_action_camerareq.png',
	'drawable/ic_action_camera.png',
	'drawable/ic_action_cancelhl.png',
	'drawable/ic_action_accept.png',
	'drawable/ic_action_picture.png',
	'drawable/ic_fingerprint.png',
	'drawable/ic_signature24.png',
	'drawable/TeamLog Logo 60.png',
	'drawable/TeamLogLogo60White.png',
	'drawable/TeamLogLogo60Orange.png',
	'favicon.ico'
	]);
  workbox.routing.registerRoute(
	  /\.(?:png|gif|jpg|jpeg|webp|svg)$/,
	  new workbox.strategies.CacheFirst({
		cacheName: 'images',
		plugins: [
		  new workbox.expiration.Plugin({
			maxEntries: 60,
			maxAgeSeconds: 30 * 24 * 60 * 60, // 30 Days
		  }),
		],
	  })
	);
	workbox.routing.registerRoute(
	  /\.(?:js|css|json)$/,
	  new workbox.strategies.StaleWhileRevalidate({
		cacheName: 'static-resources',
	  })
	);
	workbox.routing.registerRoute(
	  /.*(?:googleapis|gstatic)\.com/,
	  new workbox.strategies.StaleWhileRevalidate(),
	);

	workbox.routing.registerRoute(
	  new RegExp('api/.*.php|api/.*.asp'),
	  new workbox.strategies.NetworkFirst({
		  cacheName: 'api-cache',
	  })
	);
	console.log('Todo se enruto sin problemas');
	
	self.onsync = function(event) {
		if(event.tag == 'sync-db') {
			console.log('syncing...');
			if (Notification.permission=='granted'){
				try{
					
					event.waitUntil(SaveDcToServer());
					
				}
				catch(e){}
			}
		}
	}
	
	
	console.log('Se está esperando por un sync');
} else {
  console.log('Chimbo! Workbox no se cargo ');
}

var Tuples = null;
	
var RexArray = [];
var DCArray = [];
var TuplasArray = [];

async function SaveDcToServer(){
	var toktok='666123';
	RexArray = [];
	DCArray = [];
	TuplasArray=[];
	
	Promise.all([db.rexs.where("repciId").equals("").toArray(function(ra){RexArray=ra;}), 
				db.DataClips.where("repciId").below(0).toArray(function(dcs){DCArray=dcs;}),
				db.Tuplas.where("idDC").below(0).toArray(function(tps){TuplasArray=tps;})]).then(values => { 
		for (var rr=0;rr<RexArray.length;rr++){
			if (RexArray[rr].Dcs="undefined")
				RexArray[rr].Dcs=[];
			for(var dd=0;dd<DCArray.length;dd++){
				if (RexArray[rr].id==-DCArray[dd].repciId){
					RexArray[rr].Dcs.push(DCArray[dd]);
					var dcIndex = RexArray[rr].Dcs.length - 1;
					if (RexArray[rr].Dcs[dcIndex].Tuplas="undefined")
						RexArray[rr].Dcs[dcIndex].Tuplas=[];
					for(var tt=0;tt<TuplasArray.length;tt++){
						if (RexArray[rr].Dcs[dcIndex].id==-(TuplasArray[tt].idDC))
							RexArray[rr].Dcs[dcIndex].Tuplas.push(TuplasArray[tt]);					
					}
				}
			}
		}
		for (var rr=0;rr<RexArray.length;rr++){
			if (RexArray[rr].syncing==undefined || RexArray[rr].syncing== false) {
				db.rexs.update(RexArray[rr].id, {syncing: true,syncDateStart: new Date()});
				fetch('api/saveRex.php', {
				  method: 'POST',
				  headers: {
					'Accept': 'application/json, text/plain, */*',
					'Content-Type': 'application/json'
				  }
				  ,body: JSON.stringify(RexArray[rr])
				}).then(res=>res.json())
						.then(res => {							
								Promise.all([
												db.rexs.where('id').equals(res.LocalRexID).modify(function(rx){
														rx.repciId = res.repciID;
														rx.syncing = false;
														rx.syncDateEnd = new Date();
														MuestraNotificacion(rx.titulo+'-'+'Registrado');
														return rx.titulo;
												}),
												res.Dcs.map(dca=> {
													db.DataClips.where('id').equals(dca.LocalDcID).modify(function(dc){
															dc.DCWebId = dca.idDC;
															dc.base64img = ""; //libera el espacio de la foto, ya está arriba.
															return "";
														});
													db.Tuplas.where('idDC').equals(-(dca.LocalDcID)).modify(function(tup) {
															tup.idDC = dca.LocalDcID;
															return "";
														});
													})												
											])
										.then(values =>
											ActualizaRexsUI('Actualiza UI')
										)
							});
			}
		}
		console.log('sync-db Listo')
	}).catch(error => console.log(`Error in promises ${error}`));
	
	function MuestraNotificacion(mensaje){
		ActualizaRexsUI('Actualiza UI');
		self.registration.showNotification("Dossier", {
													  body: mensaje,
													  icon: 'images/icons/icon-128x128.png'
													});
	}
	
	function send_message_to_client(client, msg){
    return new Promise(function(resolve, reject){
        var msg_chan = new MessageChannel();

        msg_chan.port1.onmessage = function(event){
            if(event.data.error){
                reject(event.data.error);
            }else{
                resolve(event.data);
            }
        };

        client.postMessage("SW Says: '"+msg+"'", [msg_chan.port2]);
    });
}
	
	function ActualizaRexsUI(msg){
    clients.matchAll().then(clients => {
        clients.forEach(client => {
            send_message_to_client(client, msg).then(m => console.log("SW Received Message: "+m));
        })
    })
}

}

			
			