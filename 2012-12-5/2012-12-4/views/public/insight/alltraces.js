dojo.require("dojo.ready");
dojo.require("dijit.layout.ContentPane");
dojo.require("dijit.Tree");
dojo.require("dojo._base.window");
dojo.require("dojo.data.ItemFileReadStore");
dojo.require("dijit.tree.ForestStoreModel");
var alltree=null;
dijit._TreeNode.prototype._setLabelAttr = {node: "labelNode", type: "innerHTML"};

createTree=function(treeModel){
	var _tree=new dijit.Tree({
				showRoot:true,
				autoExpand: false,
				persist:false,
    	        model: treeModel,
				getIconClass: function(item, opened)
				              {return (!item || this.model.mayHaveChildren(item)) ? (opened ? "noimage" : "noimage") : "dijitLeaf"},
        	}, "historytraces");
	dojo.connect(_tree,"onClick",function(item,nodeWidget){
						console.log(item.signature);
						showTraceInfo(item.traceid);
					    var div=document.getElementById("trace");
						div.style.visibility='visible';
					});	
	_tree.startup();
	return _tree;
}
destoryTree=function(tree){
	tree.dndController.selectNone();
	tree.model.store.clearOnClose = true;
    tree.model.store.close();

    // Completely delete every node from the dijit.Tree     
    tree._itemNodesMap = {};
    tree.rootNode.state = "UNCHECKED";
	tree.model.root.children = null;

    // Destroy the widget
    tree.rootNode.destroyRecursive();
}
showAll=function(groupBy){
	var uri = alltraces_uri;
	if(groupBy)
		uri = groupby_uri(groupBy);
	getAllTree(uri);
    };
getAllTree=function(uri){
	$.get(uri,null,function(data_uri,stat){
        if(!data_uri) return;         
		var dataform=eval(data_uri);
		var data={
			identifier: 'id',
			label: 'signature',
			items: dataform
			}
		var archiveNames = new dojo.data.ItemFileReadStore({
    	data: data
    	})
    	var treeModel = new dijit.tree.ForestStoreModel({
			 rootId:'continentRoot', 
			 rootLabel:userid,
        	    store: archiveNames,
            	childrenAttrs: ["traces"]
        	});
		if(!alltree)
		{   
         	alltree=createTree(treeModel);
			alltree.expandAll();
		}
		else
		{
			destoryTree(alltree);
		    alltree.model.constructor(treeModel);
		    // Rebuild the alltree
			alltree.postMixInProperties();
			alltree._load();
			alltree.expandAll();
		}
	});

};
dojo.addOnLoad(showAll);
