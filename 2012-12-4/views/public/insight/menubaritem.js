dojo.require("dijit.MenuBar");
dojo.require("dijit.MenuBarItem");
var pMenuBar;
function fClickItem(){
    window.location.href="/traces/"+userid;
};
function fClickAnotherItem(){
    window.location.href="/all_traces/"+userid;
};
dojo.ready(function(){
    pMenuBar = new dijit.MenuBar({id:"nav-menu"});
    pMenuBar.addChild(new dijit.MenuBarItem({label:"Recent Activity",onClick:fClickItem}));
    pMenuBar.addChild(new dijit.MenuBarItem({label:"History Traces", onClick:fClickAnotherItem}));
    pMenuBar.placeAt("navigation");
    pMenuBar.startup();
});
