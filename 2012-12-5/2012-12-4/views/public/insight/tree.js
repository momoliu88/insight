dojo.require("dojo.ready");
dojo.require("dijit.layout.ContentPane");
dojo.require("dijit.Tree");
dojo.require("dojo._base.window");
dojo.require("dojo.data.ItemFileReadStore");
dojo.require("dijit.tree.ForestStoreModel");

var global_config=Array();
var content;
var global_duration;
var global_end_time;
var global_start_time;
var tree=null;
function parseDom(arg) {
	var objE = document.createElement("div");
	objE.setAttribute("dojoattachpoint","ganttNode");
	objE.setAttribute("class","insightGanttContainer");
	objE.innerHTML = arg;
	return objE;
};
computeLeft=function(start,globalstart,duration)
{
	return 100*(start-globalstart)/duration;
}
computeRight=function(end,globalend,duration)
{
	return 100*(globalend-end)/duration;
}
formatter=function(treeNode)
{
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
}
showTraceInfo=function(traceid){
	var uri = traceDetailUrl(traceid);
    $.get(uri,null,function(data_uri,stat){
	//	alert(data_uri);
	//	var data_uri=[{"frames":[{"start_time": 1353731062321046000,"operation_signature": "GET /","id": "8fd051dd-7313-441c-a359-f93c9f39f981","duration": 112045000}],"operation_signature": "GET /","start_time": 1353731062321046000,"start_time_str": "12:24:22 ( 112.045 ms)","id": "1e77f4fb-ab56-41c0-aeba-a34355c388ed","duration": 112045000}];
		var data_uri=[
		    {"frames": [{"start_time": 1353730985504713000, "operation_signature": "GET /","id": "a6218a45-b7f2-47a9-ad03-8e9fa7b2147a" ,"duration": 6629460000}],
				        "operation_signature": "GET /",
						        "start_time": 1353730985504713000,
								        "start_time_str": "12:23:05 ( 6629.46 ms)",
										        
										        "id": "4cd073b3-2077-48cb-af6e-47c025c49aa9",
												        "http_request": {
															            "headers": {
																			                "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
																							                "accept-encoding": "gzip,deflate,sdch",
																											                "user-agent": "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11",
																															                "connection": "keep-alive",
																																			                "host": "10.1.60.102:11116",
																																							                "accept-charset": "ISO-8859-1,utf-8;q=0.7,*;q=0.3",
																																											                "accept-language": "en-US,en;q=0.8"
																																																            },
																		            "remotePort": "-1",
																					            "localPort": "11116",
																								            "remoteAddr": "10.1.92.179",
																											            "uri": "/",
																														            "method": "GET",
																																	            "protocol": "HTTP/1.1"
																																					        },
														        "duration": 6629460000
																	    }]
	;
		delete data_uri[0]["http_request"];
		console.log("start");
			console.log(Object.keys(data_uri[0]));
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
		if(!tree)
		{
			console.log("create tree");
         	tree=new dijit.Tree({
				showRoot:false,
    	        model: treeModel,
				_createTreeNode: function(args) {
					var treeNode=new dijit._TreeNode(args);
					var idx=treeNode.indent+1;	
					if(idx > 0)
					{
						console.log("idx "+idx);
						treeNode=formatter(treeNode);		
		//			var div = document.createElement("div");
		//			div.innerHTML="122222";
		//			var first=treeNode.domNode.firstChild.firstChild;
		//			treeNode.domNode.firstChild.insertBefore(div,first);
					}
					return treeNode;
			
				},
				getIconClass: function(/*dojo.store.Item*/ item, /*Boolean*/ opened){
    				return (!item || this.model.mayHaveChildren(item)) ? (opened ? "noimage" : "noimage") : "dijitLeaf"
				},
        	}, "trace_detail");
	
			dojo.connect( tree,"onClick", function(/*dojo.data*/ item, /*TreeNode*/ nodeWidget){
			//as root is hidden
				var idx = nodeWidget.indent+1;
				if(!global_config[idx])
				{
					global_config[idx]=1;
					var margin=5+(10*nodeWidget.indent);
					var content = new dijit.layout.ContentPane({
                	    	content:"test"/*item.desc*/,
							style:"margin-left:"+margin+"px",
                			},document.createElement("div"));

					content.domNode.id="insight_traces_FrameTreeNode_"+idx+"_operation";
					nodeWidget.domNode.firstChild.lastChild.appendChild(content.domNode);
				}
				else
				{
					global_config[idx]=0;
					var id="dijit__TreeNode_"+idx;
					var content=document.getElementById("insight_traces_FrameTreeNode_"+idx+"_operation");
					nodeWidget.domNode.firstChild.lastChild.removeChild(content);
				}
			});
		tree.startup();
		tree.expandAll();
	}
	else
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

    // Recreate the model, (with the model again)
    tree.model.constructor(treeModel);

    // Rebuild the tree
    tree.postMixInProperties();
    tree._load();
	tree.expandAll();
	}
	})
};
