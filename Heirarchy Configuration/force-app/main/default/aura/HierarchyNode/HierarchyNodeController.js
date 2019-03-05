({
	showAction : function( cmp , event , helper ) {		
        //var rowLevel =  cmp.getElement().getAttribute( 'aria-level');				
		var expanded = cmp.getElement().getAttribute( 'aria-expanded');
        var node =  cmp.get( 'v.node');
                
		if( expanded === 'false' ) {
			var expandEvent = cmp.getEvent("expandEvent");
			expandEvent.setParams( { "node" : node } );				
			expandEvent.fire();
		} else {
			var collapseEvent = cmp.getEvent("collapseEvent");			
			collapseEvent.setParams( { "node" : node } );				
			collapseEvent.fire();
		}
	},
	showComponent : function( cmp , event , helper ) {
		var node =  cmp.get( 'v.node');
		var showEvent = cmp.getEvent("showEvent");
		showEvent.setParams({ "node" : node });
		showEvent.fire();								
	},
    showMoreChildren : function( cmp , event , helper ) {
		var node =  cmp.get( 'v.node');		
        var showMoreEvent = cmp.getEvent("showMoreEvent");
        showMoreEvent.setParams({ "node" : node } );
		showMoreEvent.fire();								
	},
    goToRecord: function( cmp , event , helper ) {
        var node =  cmp.get('v.node');
		window.open('/one/one.app?id='+ node.sObject.Id +'#/sObject/'+ node.sObject.Id+'/view','_blank');
    }
})