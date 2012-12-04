function search(){
	var keyword = escape(document.getElementById('txtSearch').value);
	//console.log(keyword);
  if(null != tree1)
  {
    clearTree(tree1);
    tree1 = null;
  }
	var uri = searchUrl(_traceid,keyword);
    $.get(uri,null,function(data_uri,stat){
      console.log(data_uri);
	    showTree(data_uri);
	});
}
function searchInTime(){
	var keyword = escape(document.getElementById('txtSearch').value);
	console.log(keyword);
	var uri = searchInTimeUrl(_traceid,keyword);
    $.get(uri,null,function(data_uri,stat){
	    showList(data_uri);

	});
}
function searchEndPoint()
{
	var keyword = escape(document.getElementById('txtSearchEndPoint').value);
	console.log(keyword);
	if(keyword == '') 
		return showAll(_groupby);
	var uri = searchEndPointUrl(keyword,_groupby);
    getAllTree(uri);
}
