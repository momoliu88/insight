var traceHistory = null;
var mytheme;
initChart=function()
{
	mytheme= dojox.charting.themes.PlotKit.green.clone();
	mytheme.axis.majorTick = {
		color : "white",
		style: "solid"
	}; 
	showChart();
	setInterval(function(){showChart();}, 5000);
}
var count=0;
var previousStat=false;
var maxDuration = 0;
var step=0;
clear_env = function()
{
      dojo.empty("traceHistory");
  traceHistory=null;
}
showChart = function()
{
  var url = tracesUrl;
	maxDuration=0;
 // clear_env();
	$.ajax({method: 'GET',type:"get",url:url,async : true,error : function(){clear_env();return;}, success : function(data)
	{	                  	      
		var thedata = eval(data);
    if(thedata==""||thedata==null) return
		clear_env();
    for(var i=0;i<thedata.length;i++)
		{
			var _y=parseInt(thedata[i].y);
			if(_y !=0 )
				existdata=true;
			if(maxDuration < _y)
				maxDuration = _y;
		}	
			maxDuration=maxDuration*1.1;
			step=Math.ceil(maxDuration/4);
			maxDuration=step*4;
			traceHistory = new dojox.charting.Chart2D("traceHistory",{fill:"white"});
			traceHistory.setTheme(dojox.charting.themes.PlotKit.green); 
			traceHistory.addAxis("x", {fixLower: "minor", fixUpper: "major", includeZero: true,leftBottom: true,stroke:"gray",majorLabels:false,minorLabels:false,majorTicks:true,minorTicks:true,majorTickStep:1,majorTick: {color: "gray", length: 6},max:61});
			traceHistory.addAxis("y", {vertical: true, fixLower: "0", fixUpper: "major",stroke:"gray",natural: false,leftBottom: true,majorTickStep:step,labelFunc:function(value){return (parseFloat((value.replace(/,/ig, ""))/1000000).toFixed(2))+" ms";},font: "normal normal bold 7pt Tahoma"});
			traceHistory.addPlot("Grid", {type: "Grid",
				hAxis: "x",
				vAxis: "y",
				font: "normal normal bold 24pt Tahoma",
				hMajorLines: true,
				hMinorLines: false,
				vMajorLines: true,
				vMinorLines: false,
				areas:false,markers:false,});
			traceHistory.addPlot("default", {type: "Columns",gap:1.5,fill:"rgb(240,240,240,0)"});
			traceHistory.addSeries("Series", thedata, {stroke: {color: "white",width:1},fill:new dojo.Color([113,166,59,0.8])});
			traceHistory.movePlotToBack("Grid");
			traceHistory.connectToPlot("default",function(evt){
				var type = evt.type;
				if(type == "onclick")
				{	
					showGrid(evt.index);
					var div=document.getElementById("traces-window");
			        div.style.visibility='';
				}		
			});
			var highlight = new dojox.charting.action2d.Highlight(traceHistory, "default");
			var anim6c = new dojox.charting.action2d.Tooltip(traceHistory, "default");
			traceHistory.updateSeries("Series", thedata);
			traceHistory.render();
	}});
    
};
dojo.addOnLoad(initChart);
//initChart();
