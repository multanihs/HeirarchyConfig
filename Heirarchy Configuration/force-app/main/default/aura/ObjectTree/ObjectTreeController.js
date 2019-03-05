({
	showComponent : function( cmp , event , helper ) {
		var node = event.getParam( 'node');        
        var divCmp = cmp.find('detailDiv');
		if( node.nodeType == 'data' ) {
				$A.createComponent("force:recordView" ,{ recordId : node.sObject.Id } , function( rv , status , error ) { 
                if( status === 'SUCCESS' ) {                    
                    divCmp.set("v.body", [ rv ]);                       
                } else  {
                    var errors = response.getError();
					if (errors) {
						if (errors[0] && errors[0].message) {
							helper.showToast(cmp,errors[0].message);
						}
					} else {
							helper.showToast(cmp,'Unknown Message');
					}
					console.log( state  );
					console.log( response.getReturnValue()  );
                }	
            });
		} else {			
	        $A.createComponent( "c:HierarchyDetailComponent" , { config : node.config , parentSObject : node.sObject } , 
			function( tableCmp  , status , errormsg ) {
				if( status == "SUCCESS" ) {
					divCmp.set("v.body" , [ tableCmp ] );
				} else {
					helper.showToast( errormsg );
					console.log( state  );
				}
			});																			
		}		
    },
	navigateSobject : function( component , event , helper ) {        
        window.location.href = '/one/one.app?id='+ event.getParam( 'recordId') +'#/sObject/'+ event.getParam( 'recordId')+'/view';
    },
    expandHandler : function( cmp , event , helper ) {								
		var tableCmp = cmp.find("hierarchyGrid");
		var node = event.getParam('node');		                
        if( node.nodeType == 'config' && node.config.hasSubRelatedConfig__c == false ) {
            helper.getSObjectList( cmp , tableCmp , event , helper , 1 );
        } else { 
            helper.getConfiguration( cmp , tableCmp ,event , helper );
        }
	},
	collapseHandler : function( cmp , event , helper ) {
		helper.collapseAction( cmp , event , helper );
	},
	getDetail :  function( cmp , event , helper ) {
		var detailAction = cmp.get( "c.getDetailRecord");
		var type = cmp.get( "v.sObjectName");
		var id = cmp.get("v.recordId");
		
        helper.toggleLoadingWindow( cmp , event , helper );        
		detailAction.setParams( { "sobjType" : type , "id" :  id });
		detailAction.setCallback( this , function( response ) {
			//console.log( response );
			var state = response.getState();
			if (cmp.isValid() && state === "SUCCESS") {
				helper.addToHierarchy( cmp , response , event , helper );
			} else if (cmp.isValid() && state === "INCOMPLETE") {
				console.log( response );
			} else {
				var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast(cmp,errors[0].message);
                    }
                } else {
                    	helper.showToast(cmp,'Unknown Message');
                }
				console.log( state  );
				console.log( response.getReturnValue()  );
			}
		});
		$A.enqueueAction( detailAction );
	},
	showMoreChildren : function( cmp , event , helper ) {
        var tableCmp = cmp.find("hierarchyGrid");
        var tableBody = tableCmp.get('v.body')[1];        
        var node  = event.getSource().get( "v.node");		        
        helper.getSObjectList( cmp , tableCmp , event , helper , node.children.length /20 + 1 );
	},
    showAll : function( cmp , event , helper ) {
		var rowCmp;                
        var rows = cmp.find('hierarchyGrid').get('v.body')[1].get( 'v.body');
        var rowExpanded;    
        var eventQueue;
        
        eventQueue = cmp.get('v.eventQueue');
        for( var i=0;i<rows.length;i++) {
        	rowCmp = rows[ i ];                
			rowExpanded = rowCmp.getElement().getAttribute( 'aria-expanded');
            if( rowExpanded == 'false') {
                if( i > 5 ) {
                	eventQueue.push( { value : JSON.stringify( rowCmp.get( 'v.node' )) });                
                } else {
            		var expandEvent = cmp.getEvent("expandEvent");
                	expandEvent.setParams( { "node" : rowCmp.get( 'v.node' ) } );				
					expandEvent.fire();
            	}
        	}		
        }
        cmp.set( 'v.eventQueue' , eventQueue );
        //helper.processEvents( cmp , event ,helper );
    }
})