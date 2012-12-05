dojo.require("dijit.layout.TabContainer");
dojo.require("dijit.layout.ContentPane");
var imagetype=["png","jpeg","gif"];
var audiotype=["mpeg"];
createContent=function(map){
	var _content='<table class="dl"><tbody>';
	for(var k in map)
		_content+='<tr><td>'+k.bold()+'</td><td>'+map[k]+'</td></tr>';
    _content += '</tbody></table>';
	return _content;
}
	//var __data={"start_time":1353501579210039000,"start_time_str":"20:39:39 ( 4.86 ms)","duration":4860000,"http_response":{"headers":{"Date":"Wed, 21 Nov 2012 12:39:39 GMT","Content-Type":"image/png","Last-Modified":"Wed, 21 Nov 2012 02:13:52 GMT","Content-Length":"5103","Accept-Ranges":"bytes","ETag":"W/\"5103-1353464032000\""},"statusCode":"200","contentLength":"5103","body":"data:image/png;base64,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\nsIjbVYyeY48LspOce5NiNPHnHpNkp7qVDvxH/y0E+gdQNdffvctXjD8c/i92\nXI5SFpLrZedPL7kYuY6ePpMyEvBgzZnTYcely1czhvi+vl7J5janw46h3UWi\nDMNnJ270psxOT87j3HApBpKMdnnsI8ZSaoyUVADg+OAgVje2FAn98I0AkqYl\n2yRPEY3NZGQgZzgcZmq9K5j2zt9wXAvfvURjM/jw8xWiGuedjmLOe8YmQri/\n4J9UHcuqqvtsJf5EcFxxO4hQqE7aUsg5lVdUaAYRHSF6PW40NjRYGOZGgv8w\nrUYiOqnAejsOQFedRKIxWkg7HXa83vSopA6S0j789/xx31qOO+S/Rsxl0MdD\nJy6VdDCGpm6iyX+GZaGWplK2d0gpKwm1q8i1qTzlehyjY19YTMtIDHMjQX7p\ndOtFuiy0qmYJB0R7Ni/D0O4iFkSEIYZ2F2HP5mXsBfxt99eyrELYSUywSpnT\nYWe/i9Yhcq2sicQstvd8i6p1f2KTlKf6q7G+zolT/dX44761uBi5jqp1f8L2\nnm9VsZ3WXidTMRLRL3o1ttGfxUZp+36GJ4rlLyxhEpq15F6fLJOoc1HXbhWi\ncftf2Zv35cfySUqiYaRYJ5GY5WSl5T6X/3qx5jWLZZHN9K6Nnwbw+5o1hZli\nq3IBiLogqRutFhxqTa3wJi2wSpKZR0eibKQnZd0HTrHHcHxwMCvlEN1cG3Fv\npMoc6B9QLbrnVuXGxYZFkH5npZZpEBEXSVx6sh4WlXy9zVaouMwh1iDHBxsN\nZLOAKC0gAcArrz6o63zwXpcqV0bv7OP1uDmaB8jO2iwl1rXpDnucL20f0lSY\n1Zo+oKO0twMjRWa6LppdGz+npFQr8ece7dm8jKNtOt+fzybelOoko42vl6Qy\n0npYIjGL5Wv+zPZIfXxyxHR98mmP/nvl1U72F9qxtUVSD9V6VzD0HCE+iMgv\nnrBTKPKDKVnpieJZ7Nm8jI2emvxnNOeXlIBoQ9tnnEWoZlxskTaQKisrLaR1\nYWwiJLj9FAnt6ZrQOx3FolEWCdfF2ODDz1fg/K2ns3rhVlXd54BpQ9tnGQET\nidBIzs5MukhX18aP4PghaTgcZtasruPoobam7zW7LDpyMoPro49HaVpAqZEh\nXkRcG1WAzQojkQhuf+Bd9te5zV8XFwNR16Y7ad18UqF3Ouym0E98Zlq+5s9p\n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\nNjK2aYfYAAAAAElFTkSuQmCC\n","body_encode":"png"},"operation_signature":"GET /tomcat.png","id":"445a8d22-e5aa-4257-a8f6-875898942dda","http_request":{"headers":{"user-agent":"curl/7.15.5 (x86_64-redhat-linux-gnu) libcurl/7.15.5 OpenSSL/0.9.8b zlib/1.2.3 libidn/0.6.5","host":"10.1.60.102:11119","accept":"*/*"},"method":"GET","remoteAddr":"10.1.60.102","uri":"/tomcat.png","protocol":"HTTP/1.1","remotePort":"-1","localPort":"11119"},"frames":[{"start_time":1353501579210039000,"duration":4860000,"operation_signature":"GET /tomcat.png","id":"45192c12-49a8-422c-b724-86830fc96b95","desc":[{"title":"ExtraTraceData","params":{"mandatory":"false"}},{"title":"properties","params":{"returnValue":"void","type":"OperationType[http]","statusCode":"200","label":"GET /tomcat.png","contentLength":"5103","ExtraTraceData":""}}]}]};

showTab = function(data){
    //var data={""};
	//var data={"start_time":1353501579210039000,"start_time_str":"20:39:39 ( 4.86 ms)","duration":4860000,"http_response":{"headers":{"Date":"Wed, 21 Nov 2012 12:39:39 GMT","Content-Type":"image/png","Last-Modified":"Wed, 21 Nov 2012 02:13:52 GMT","Content-Length":"5103","Accept-Ranges":"bytes","ETag":"W/\"5103-1353464032000\""},"statusCode":"200","contentLength":"5103","body_encode":"png"},"operation_signature":"GET /tomcat.png","id":"445a8d22-e5aa-4257-a8f6-875898942dda","http_request":{"headers":{"user-agent":"curl/7.15.5 (x86_64-redhat-linux-gnu) libcurl/7.15.5 OpenSSL/0.9.8b zlib/1.2.3 libidn/0.6.5","host":"10.1.60.102:11119","accept":"*/*"},"method":"GET","remoteAddr":"10.1.60.102","uri":"/tomcat.png","protocol":"HTTP/1.1","remotePort":"-1","localPort":"11119"},"frames":[{"start_time":1353501579210039000,"duration":4860000,"operation_signature":"GET /tomcat.png","id":"45192c12-49a8-422c-b724-86830fc96b95","desc":[{"title":"ExtraTraceData","params":{"mandatory":"false"}},{"title":"properties","params":{"returnValue":"void","type":"OperationType[http]","statusCode":"200","label":"GET /tomcat.png","contentLength":"5103","ExtraTraceData":""}}]}]};
	var thedata = data;
	if (thedata=="") return;
	var resp= eval(thedata['http_response']);
  if (null == resp)
    return null;
	console.log(resp);
	var resp_headers=eval(resp['headers']);
	var resp_cookies=eval(resp['cookies']);
    var req= eval(thedata['http_request']);
	var req_headers=eval(req['headers']);
	var req_cookies = eval(req['cookies']);
	var tc ;//dijit.byId("tc1-prog");
	if(!tc)
	{
		console.log("create tc");
		tc = new dijit.layout.TabContainer({
			style: "height: 100%; width: 100%;"
		}, document.createElement("div")/*"tc1-prog"*/);
	}

	tc.domNode.id="new";
	tc.domNode.style.width="1000px";
	tc.domNode.style.height="300px";
	console.log("tc "+tc);
	var _content='<table class="dl"><tbody>';
  var cp1 = new dijit.layout.ContentPane({
          title: "Headers",
		      content:"<h3 class='webjoinh2'><hr>Response</h3><hr>"+createContent(resp_headers)+"<h3 class='webjoinh2'><hr>Request</h3><hr>"+createContent(req_headers)
          });
  tc.addChild(cp1);
	
  var cp2 = new dijit.layout.ContentPane({
         title: "Preview",
	    	 onHide: function(){  
            if(document.getElementById("innerCanvas"))
              this.domNode.removeChild(document.getElementById("innerCanvas"));
         }, 
	      onShow:function(){
		  var isimage = false;
		  console.log(resp["body_encode"]);
		  for(var k in imagetype)
			if((resp["body_encode"] == ("image/"+imagetype[k]))
				||(resp["body_encode"] == ("audio/"+audiotype[k])))
			{
				isimage = true;break;
			}
		  if (!isimage) return;

          var canvas = document.createElement("canvas");
		 // canvas.width="1500";
		 // canvas.height="1000";
		  canvas.width ='100%';
		    canvas.height='100%';
          var ctx = canvas.getContext("2d");
          canvas.id='innerCanvas';
          var image = new Image();
		  console.log(resp["body_encode"]);
		  image.src="data:"+resp["body_encode"]+";base64,"+resp["body"];

		  console.log("height "+image.naturalWidth);
          image.onload = function() {
			console.log("height "+this.height+' width '+this.width);
			canvas.width=this.width;
			canvas.height=this.height;
            ctx.drawImage(this, 0, 0,this.width,this.height);
          };
          console.log("ctx "+canvas); 
          this.domNode.appendChild(canvas);
				},         
    });
  tc.addChild(cp2);

	var cp4 = new dijit.layout.ContentPane({
         title: "Cookies",
         content: "<h3 class='webjoinh2'><hr>Response</h3><hr>"+createContent(resp_cookies)+"<h3 class='webjoinh2'><hr>Request</h3><hr>"+createContent(req_cookies)

    });
    tc.addChild(cp4);
	console.log("body " +thedata["body"]);
	var _content=resp["body"];
/*	alert(_content.class);
	if(resp["body_encode"]=="abnormal")
	{
		_content ="";
		for(var k in resp["body"])
			_content += Base64.decode(k);
		console.log(_content);
	}*/
  var	cp5 = new dijit.layout.ContentPane({
        title: "Response",
		    content:_content
    });
	tc.addChild(cp5);
	return tc;
};
