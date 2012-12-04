	dojo.require("dijit.Tree");
  dojo.require("dijit.form.DropDownButton");
  dojo.require("dijit.DropDownMenu");
  dojo.require("dijit.MenuItem");
  
  dojo.require("dojo.dom");
	dojo.require("dojo.data.ItemFileReadStore");
	dojo.require("dojox.grid.LazyTreeGrid");
	dojo.require("dojo._base.window");
    dojo.require("dijit.tree.ForestStoreModel");
    dojo.require("dojo.data.ItemFileWriteStore");
    dojo.require("dojox.charting.DataChart");
    dojo.require("dojo.data.ItemFileWriteStore");
    dojo.require("dojox.charting.plot2d.Grid");
    dojo.require("dojox.charting.themes.PlotKit.green");
    dojo.require("dijit.form.HorizontalSlider");
    dojo.require("dijit.form.HorizontalRule");
    dojo.require("dojox.grid.EnhancedGrid");
    dojo.require("dojox.grid.enhanced.plugins.Pagination");
    dojo.require("dojo.data.ItemFileWriteStore");

    dojo.require("dijit.form.HorizontalRuleLabels");
    dojo.require("dojox.charting.Chart2D");
    dojo.require("dojox.charting.action2d.Highlight");
    dojo.require("dojox.charting.themes.Claro");
    dojo.require("dojox.charting.action2d.Shake");
    dojo.require("dojox.charting.action2d.Tooltip");
	dojo.require("dijit.layout.ContentPane");
    dojo.require("dojox.lang.functional.object");
	dojo.require("insight.charting.action2d.StrokeHighlight");
	$.ajaxSetup({
	  async: false,
	  });
	
	var baseUrl="http://10.1.60.102:4568/";
	//var traceUrl = function(index){return baseUrl+"kind=tracelist&index="+index};
	var tracesUrl = baseUrl+"traces_real_time/"+userid;
	var traceList = baseUrl+"user/"+userid+"/index/";
	var traceDetailUrl=function(traceid){return baseUrl+"user/"+userid+"/traceid/"+traceid};
	var alltraces_uri=baseUrl+"alltraces/"+userid;
	var groupby_uri=function(keyword){return baseUrl+"user/"+userid+"/groupby/"+keyword;}
  var searchUrl=function(traceid,keyword){
    return baseUrl+"user/"+userid+"/traceid/"+traceid+"/keyword/"+keyword;
};
  var searchInTimeUrl=function(traceid,keyword)
{
    return baseUrl+"user/"+userid+"/traceid/"+traceid+"/intime/keyword/"+keyword;
};
  var searchEndPointUrl=function(keyword,groupbykeyword)
  {
	if(groupbykeyword)
		return baseUrl+"/user/"+userid+"/groupby/"+groupbykeyword+"/search/"+keyword;
	else
		return baseUrl+"/alltraces/"+userid+"/keyword/"+keyword;
  };
