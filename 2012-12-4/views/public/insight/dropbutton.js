var _groupby=null;
showGrops=function(){
        var menu = new dijit.DropDownMenu({ style: "display: none;"});
        var menuItem1 = new dijit.MenuItem({
			label: "<b>&radic;    cookie</b>",
            onClick: function(){ _groupby="cookie";showAll(_groupby); },
			id:"cookiebutton"
        });
        menu.addChild(menuItem1);

        var menuItem2 = new dijit.MenuItem({
            label: "<b>&radic;    remoteAddr<b>",
            onClick: function(){ _groupby="remoteAddr";showAll(_groupby); },
			id:"remoteAddrButton"
        });
        menu.addChild(menuItem2);
        var menuItem3 = new dijit.MenuItem({
            label: "<b>&radic;    date<b>",
            onClick: function(){ _groupby=null;showAll(_groupby); },
			id: ""
        });
        menu.addChild(menuItem3);
        var button = new dijit.form.DropDownButton({
            label: "<h2>GroupBy</h2>",
            name: "programmatic2",
            dropDown: menu,
            id: "progButton"
        });
        menuItem1.iconNode.style.cssText = "background-image: url(); width: 16px, height: 16px";
        dojo.dom.byId("alt_navigation").appendChild(button.domNode);
    };
dojo.addOnLoad(showGrops);
