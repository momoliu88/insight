dojo.require("dojo.ready");
dojo.require("dijit.layout.ContentPane");
dojo.require("dijit.Tree");
dojo.require("dojo._base.window");
dojo.require("dojo.data.ItemFileReadStore");
dojo.require("dijit.tree.ForestStoreModel");

var content;
var global_duration;
var global_end_time;
var global_start_time;
var tree=null;
var tc;
//alert("111");
dijit._TreeNode.prototype._setLabelAttr = {node: "labelNode", type: "innerHTML"};
var _traceid;//="ac5554f9-9623-4ea5-bbdf-93c5a3dbdfe3";
//alert("traceid:"+traceid);
function parseDom(arg) {
	var objE = document.createElement("div");
	objE.setAttribute("dojoattachpoint","ganttNode");
	objE.setAttribute("class","insightGanttContainer");
	objE.innerHTML = arg;
	return objE;
};
//alert("222");
computeLeft=function(start,globalstart,duration)
{
	return 100*(start-globalstart)/duration;
};
computeRight=function(end,globalend,duration)
{
	return 100*(globalend-end)/duration;
};
/**
createDiv=function()
{
	var test = document.createElement("div");
	test.id="abc";
	test.style.width="1000px";
	test.style.height="300px";
	var test1 = document.createElement("div");
	test1.id="tc1-prog";
	test1.style.left="10px";
	var test2 = document.createElement("div");
	test2.id="tc";
	console.log(test);
	test1.appendChild(test2);
	test.appendChild(test1);
	test.style.visibility = "hidden";
	document.body.appendChild(test);
}
**/


clearTree=function(tree)
{
	//	tree.model.setStore(archiveNames);	
	tree.dndController.selectNone();
    tree.model.store.clearOnClose = true;
    tree.model.store.close();

    // Completely delete every node from the dijit.Tree     
    tree._itemNodesMap = {};
    tree.rootNode.state = "UNCHECKED";
	tree.model.root.children = null;

    // Destroy the widget
    tree.rootNode.destroyRecursive();

//	var _tcprog = dijit.byId("tc1-prog");
//	if(_tcprog)
//	{
//		for(var k in cps)
//			_tcprog.removeChild(k);
//	}
/*
    var abc=document.createElement("div");
	abc.id = "abc";
    abc.class="page-module-body";
	abc.style.width="1000px";
	abc.style.height="300px";
	abc.style.visibility="hidden";
	var tcprog = document.createElement("div");
	tcprog.id = "tc1-prog";
	var tc = document.createElement("div");
	tc.id = "tc";
	tcprog.appendChild(tc);
	abc.appendChild(tcprog);
	document.body.appendChild(abc);
	*/
};

expandAllNode=function()
{
	var treeObj = dijit.byId('trace_detail');                
    var children = treeObj.rootNode.getChildren();
    expandChildNode(children, treeObj);
};

expandChildNode=function(children, treeObj)
{
    for (var i = 0; i < children.length; i++)
    {
        var node = children[i];
		//console.log("node "+node.item.expanded);
		//console.log("node== true? "+(node.item.expanded==true));
		//console.log("node.class "+(node.item.expanded.class));
		if(node.item.expanded==0)
		{
					//console.log("continue");
			continue;
		}
        if (node.isExpandable && !node.isExpanded)
        {
						//console.log("opened");
            treeObj._expandNode(node);
			var childNodes = node.getChildren();
			//console.log("childNodes");
			if (childNodes.length > 0)
			{
				expandChildNode(childNodes, treeObj);
			}
         }
    }
}

formatter=function(treeNode)
{
	//alert("333");
	var item=treeNode.item;//this.grid.getItem(rowIndex);
	var frames=item.frames;
	var duration=parseFloat(item.duration);
	var starttime=parseFloat(item.start_time);
	var end_time=starttime+duration;	
	var divstr="<div class=\"insightGanttDuration\" dojoattachpoint=\"durationNode\">"+parseFloat(duration/1000000).toFixed(2)+" ms";
		
	divstr+="</div>&nbsp;<div class=\"insightGanttBarMaster\"  style=\"position: absolute; top: 2px; bottom: 2px; left:"+computeLeft(starttime,global_start_time,global_duration)+"%; right:"+computeRight(end_time,global_end_time,global_duration)+"%;\"></div>";
	var begin = starttime;
	if(null != frames){
		for(var i = 0 ;i < frames.length;i++)
		{
			var start=parseFloat(frames[i].start_time);
			var end=start+parseFloat(frames[i].duration);
			divstr+="<div class=\"insightGanttBar\" style=\"position: absolute; top: 2px; bottom: 2px; left: "+computeLeft(begin,global_start_time,global_duration)+"%; right: "+computeRight(start,global_end_time,global_duration)+"%;\"></div>";
			begin =end ;
		}
	}
	divstr+="<div class=\"insightGanttBar\" style=\"position: absolute; top: 2px; bottom: 2px; left: "+computeLeft(begin,global_start_time,global_duration)+"%; right: "+computeRight(end_time,global_end_time,global_duration)+"%;\"></div>";
	var obj=parseDom(divstr);
	var first=treeNode.domNode.firstChild.firstChild;
    treeNode.domNode.firstChild.insertBefore(obj,first);
	return treeNode;
};
showTree=function (data_uri)
{

	global_config=Array();
	var dataform=eval(data_uri);
	if (dataform=="") return;
    var http ={};
	http["http_request"] = dataform[0]["http_request"];
	http["http_response"] = dataform[0]["http_response"];
  _traceid = dataform[0]["id"];
  console.log(_traceid);
	delete dataform[0]["http_response"];
	delete dataform[0]["http_request"];
		var data={
			identifier: 'id',
			label: 'operation_signature',
			items: dataform
			}
		var archiveNames = new dojo.data.ItemFileReadStore({
    	data: data
    	});
		document.getElementById("trace-detail-time").innerHTML=dataform[0].start_time_str;
		global_duration=parseFloat(dataform[0].duration);
		global_start_time=parseFloat(dataform[0].start_time);
		global_end_time=global_start_time+global_duration;
    	var treeModel = new dijit.tree.ForestStoreModel({
        	    store: archiveNames,
            	childrenAttrs: ["frames"]
        });

		tc = showTab(http);
		if(!tree)
		{   //alert("!tree");
         	tree=new dijit.Tree({
				showRoot:false,
    	        model: treeModel,
				persist:false,
				_createTreeNode: function(args) {
					var treeNode=new dijit._TreeNode(args);
					var idx=treeNode.indent+1;	
					if(idx > 0)
					{
						treeNode=formatter(treeNode);		
					}
					return treeNode;
		        },
				getIconClass: function(/*dojo.store.Item*/ item, /*Boolean*/ opened){
    				return (!item || this.model.mayHaveChildren(item)) ? (opened ? "noimage" : "noimage") : "dijitLeaf"
				},
        	}, "trace_detail");

			dojo.connect( tree,"onDblClick", function(/*dojo.data*/ item, /*TreeNode*/ nodeWidget){
			//as root is hidden
				var idx = nodeWidget.indent+1;
				console.log(idx);

				if(!global_config[idx])
				{   
					console.log("click1");
					global_config[idx]=1;
					var margin=5+(10*nodeWidget.indent);
					if (idx==1)
					{
						tc.domNode.style.width="1000px";
						tc.domNode.style.height="300px";
						tc.domNode.style.visibility="visible";
						
						tc.domNode.style.left="10px";
						nodeWidget.domNode.firstChild.lastChild.appendChild(tc.domNode);
						tc.startup();
					}
					else 
					{		
						var content = new dijit.layout.ContentPane({
                	    content:item.desc,
						style:"margin-left:"+margin+"px",
                		},document.createElement("div"));
						
						content.domNode.id="insight_traces_FrameTreeNode_"+idx+"_operation";
						nodeWidget.domNode.firstChild.lastChild.appendChild(content.domNode);
					}

					
				}
				else
				{
					console.log("click2");
					global_config[idx]=0;
					var id="dijit__TreeNode_"+idx;
					if(idx==1){
					//var content1=document.getElementById("abc");
					//console.log(content1);
				//	nodeWidget.domNode.firstChild.lastChild.removeChild(content1);
				//	createDiv();
					console.log("id "+tc.domNode.id);
					tc.domNode.style.visibility="hidden";
					tc.domNode.style.width="0px";
					tc.domNode.style.height="0px";

				/*var test=document.getElementById(tc.domNode.id);
						test.style.visibility="hidden";
						test.style.width="0px";
						test.style.height="0px";
				var baiju=document.getElementById("tc1-prog");
						baiju.style.left="10px";*/
					}
					else {
					var content=document.getElementById("insight_traces_FrameTreeNode_"+idx+"_operation");
					nodeWidget.domNode.firstChild.lastChild.removeChild(content);
					var widget = dijit.byId("insight_traces_FrameTreeNode_"+idx+"_operation");
					if(widget)widget.destory();
				//	content.style.visibility="hidden";
				//	dijit.byId("insight_traces_FrameTreeNode_"+idx+"_operation").domNode.style.visibility="none";
					}
				}
			});
		tree.startup();
		//tree.collapseAll();
		expandAllNode();
	    }
		else
		{
			clearTree(tree)
    // Recreate the model, (with the model again)
			tree.model.constructor(treeModel);
    // Rebuild the tree
			tree.postMixInProperties();
			tree._load();
	//tree.expandAll();
			expandAllNode();
		}
	//})

};
showTraceInfo=function(traceid){
//showTraceInfo=function(){
	console.log("id "+traceid);
	var uri = traceDetailUrl(traceid);
    $.get(uri,null,function(data_uri,stat){
		//alert("123");
		showTree(data_uri);
	});
};


var tree1=null;
function showList(data_uri)
{
	var dataform=eval(data_uri);
		var data={
			identifier: 'id',
			label: 'operation_signature',
			items: dataform
			}
		var archiveNames = new dojo.data.ItemFileReadStore({
    	data: data
    	});
		document.getElementById("trace-detail-time").innerHTML=dataform[0].start_time_str;
		global_duration=parseFloat(dataform[0].duration);
		global_start_time=parseFloat(dataform[0].start_time);
		global_end_time=global_start_time+global_duration;
    	var treeModel = new dijit.tree.ForestStoreModel({
        	    store: archiveNames,
            	childrenAttrs: ["frames"]
        });

		if(!tree1)
		{   //alert("!tree");
         	tree1=new dijit.Tree({
				showRoot:false,
    	        model: treeModel,
				persist:false,
				_createTreeNode: function(args) {
					var treeNode=new dijit._TreeNode(args);
					var idx=treeNode.indent+1;	
					if(idx > 0)
					{
						treeNode=formatter(treeNode);		
					}
					return treeNode;
		        },
				getIconClass: function(/*dojo.store.Item*/ item, /*Boolean*/ opened){
    				return (!item || this.model.mayHaveChildren(item)) ? (opened ? "noimage" : "noimage") : "dijitLeaf"
				},
        	}, "trace_detaillist");
			//showTab(__data);
		tree1.startup();
		tree1.collapseAll();
		//expandAllNode();
	    }
		else
		{
			clearTree(tree1)
    // Recreate the model, (with the model again)
			tree1.model.constructor(treeModel);
    // Rebuild the tree
			tree1.postMixInProperties();
			tree1._load();
			tree1.expandAll();
		}
}
