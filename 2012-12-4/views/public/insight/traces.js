var grid=null;
showGrid=function(index){
    /*set up data store*/
    //var uri="http://10.1.60.102:11115/webinsight-dashboard/InsightDashboardServlet?kind=tracelist&index="+index
	var uri = traceList+index;
    $.get(uri,null,function(resp,stat){
	//alert("show grid");
	if(resp){
    var data_list = eval(resp);
    if (data_list==" ")  return;
    document.getElementById("trace-time").innerHTML=data_list[0].TIMESTR;
    var data = {
      identifier: 'id',
      items: []
    };
    var store;
    if(data_list){
    	var rows=data_list.length;
    	for(var i=1; i<rows; i++){
      		data.items.push(dojo.mixin({ id: i+1 }, data_list[i]));
    	}
    	store = new dojo.data.ItemFileWriteStore({data: data});
    }
    /*set up layout*/
    var layout = [[
      {name: 'DURATION(ns)', field: 'DURATION',width:"300px"},
      {name: 'LABEL', field: 'LABEL',width:"500px"},
      {name: 'START', field: 'START', width: "430px"},
      {name: 'ERROR', field: 'ERROR',width:"auto"}
    ]];

    /*create a new grid:*/
    if(!grid)
    {
		grid = new dojox.grid.EnhancedGrid({
			id: 'grid',
			store: store,
			structure: layout,
			autoHeight:true,
			rowSelector: '0px',
			plugins: {
				pagination: {
					pageSizes: ["25", "50", "100", "All"],
					description: true,
					sizeSwitch: true,
					pageStepper: true,
					gotoButton: true,
						/*page step to be displayed*/
					maxPageStep: 4,
                      /*position of the pagination bar*/
					position: "bottom"
				}
			}
		}, document.createElement('div'));
		grid.canSort=function(col){return Math.abs(col)==1;}
		dojo.connect(grid, "onRowClick",grid, function(evt){
			var idx = evt.rowIndex;
			var item=this.getItem(idx);
			var value = this.store.getValue(item, "TRACEID");
			console.log(value);
			showTraceInfo(value);
			var div=document.getElementById("trace");
            div.style.visibility='';
		});
		dojo.byId("gridDiv").appendChild(grid.domNode);
		grid.startup();
    }
    else
    {
        grid.setStore(store);
    }
    /*append the new grid to the div*/
   // dojo.byId("gridDiv").appendChild(grid.domNode);

    /*Call startup() to render the grid*/
   // grid.startup();
}
});
};
