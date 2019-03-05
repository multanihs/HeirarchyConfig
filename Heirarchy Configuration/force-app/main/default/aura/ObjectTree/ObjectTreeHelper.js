({
	collapseAction : function( cmp , event , helper ) {
        helper.toggleLoadingWindow( cmp , event , helper );
		var tableCmp = cmp.find( 'hierarchyGrid');		
      	var rootNode = cmp.get('v.rootNode');
		var node = helper.getNode( rootNode , event.getSource().get( 'v.nodeLevel'));      	
		node.children = [];		        
		node.isExpanded = false;  
      	node.recordCount = 0;
      	cmp.set('v.rootNode', rootNode );
		helper.addConfToHierarchy( cmp , tableCmp , event , helper );        
	},
	getSObjectList : function( cmp , tableCmp , event , helper  , pageNum ) {
		var node = event.getParam('node');		
		var confAction = cmp.get("c.getSObjects");
		var rootNode = cmp.get('v.rootNode');
        helper.toggleLoadingWindow( cmp , event , helper );
		confAction.setParams( { "configId" : node.config.Id , "parentId" : node.sObject.Id , "pageNum" : pageNum });
		confAction.setCallback( this , function( response ) {			
			var state = response.getState();
			if (cmp.isValid() && state === "SUCCESS") {
				node.isExpanded = true;      
                helper.processResponse( response.getReturnValue() , helper.getNode( rootNode , node.nodeLevel )  , event );
				cmp.set("v.rootNode" , rootNode );
                helper.addConfToHierarchy( cmp , tableCmp , event , helper );				
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
		$A.enqueueAction( confAction );				
	},
    addToHierarchy : function( cmp , response , event , helper) {
		var detailBean = response.getReturnValue();
        var rootNode = {};
		var tableCmp = cmp.find('hierarchyGrid');	
					
        rootNode.config = detailBean.config;
        rootNode.sObject = detailBean.recordList[0];
        rootNode.isExpanded = false;
        rootNode.children = [];
        rootNode.nodeType = detailBean.nodeType;
        rootNode.nodeLevel = 1;
        cmp.set("v.rootNode" , rootNode );
        
        helper.addConfToHierarchy( cmp , tableCmp , event , helper );
	},
	getConfiguration : function( cmp , tableCmp , event , helper ) {
		var node = event.getParam('node');
		var confAction = cmp.get("c.getRelatedConfiguration");
		helper.toggleLoadingWindow( cmp , event , helper );
		confAction.setParams( { "id" : node.config.Id, "recordId": node.sObject.Id});
		confAction.setCallback( this , function( response ) {
			var state = response.getState();
			if (cmp.isValid() && state === "SUCCESS") {				
				var rootNode = cmp.get( 'v.rootNode');                
                helper.processResponse( response.getReturnValue() , helper.getNode( rootNode , node.nodeLevel ) , event );
				cmp.set('v.rootNode', rootNode);
                helper.addConfToHierarchy( cmp , tableCmp , event , helper );				
			
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
		$A.enqueueAction( confAction );				
	},
    getNode : function( rootNode , nodeLevel ) {
    	//console.log('nodeLevel ' + nodeLevel );
        var str = ''+ nodeLevel;
        var levelArray = str.split(".");
        var node;        
        node = rootNode;        
        for( var i= 1 ;i<levelArray.length;i++) {
            node = node.children[ levelArray[i] - 1 ];
        }        
        return node;
    },
    processResponse : function( response , rootNode , event ) {                        
        var children = [];
        var childrenCount = rootNode.children.length;
        var mapConfigLabelRecordExist = response.mapConfigLabelRecordExist;
        
        for( var i=0;i<response.recordList.length;i++) {
            children.push({ "config" : ( response.nodeType == 'config' ? response.recordList[i] : response.config ), 
                           "nodeLevel" : rootNode.nodeLevel + '.' + ( childrenCount + i+1) , 
                           "sObject" : ( response.nodeType == 'data' ? response.recordList[i] : rootNode.sObject )  , 
                           "children" : [] , "recordCount" : 0  , "isExpanded" : false , "nodeType" : response.nodeType,
                           "isChildRecordPresent": !$A.util.isUndefinedOrNull(mapConfigLabelRecordExist) && mapConfigLabelRecordExist.hasOwnProperty(response.recordList[i].Label__c) ? mapConfigLabelRecordExist[response.recordList[i].Label__c] : true	
                           });
		}
        rootNode.isExpanded = true;
        rootNode.recordCount = response.recordCount;        
        rootNode.children = rootNode.children.concat( children );                
    },
	createRow : function( rootNode , parentNode , helper , level, nodeLevel ) {		
		var row2DArray = [];		
		var config;
        if( rootNode == undefined ) {
            return [];
        }
        config = rootNode.config; 
       	 
        // This is a special case to update parent record and related config.
        /*if( parentNode != undefined && rootNode.nodeType == 'config' ) {
            rootNode.config = rootNode.sObject;            
            rootNode.sObject = parentNode.sObject;
        }*/
        //console.log( rootNode.config );
        row2DArray.push( [ "c:HierarchyNode" , { "node" : rootNode ,"nodeLevel" : rootNode.nodeLevel, "nodeType" : rootNode.nodeType,
				"label" : ( ( rootNode.nodeType == 'data' ) ? 
                           		helper.getData( config.DisplayField__c , rootNode.sObject ) 
								: rootNode.config.Label__c ), 
				"expanded" : rootNode.isExpanded , "role" : "row" , "level" : level ,				
				"icon" : ( rootNode.isExpanded ?  "utility:chevrondown" : "utility:chevronright") , "node" : rootNode , 
				"hasMoreChildren" : (rootNode.children.length < rootNode.recordCount), "isRecordPresent": rootNode.isChildRecordPresent
                                                
			} ]);        
        var length = rootNode.children.length;	
        //console.log( 'createRow children ' + length );
		for( var i=0; i<length ; i++ ) {
			row2DArray = row2DArray.concat( helper.createRow( rootNode.children[i] , rootNode , helper , level + 1 , i+1 ) );                        
		}
		return row2DArray;
	},
	addRowList : function( newRowList , tableCmp , event ,cmp , helper) {
		var tableBody = tableCmp.get("v.body")[1];		
        tableBody.set("v.body" , newRowList );
        helper.processEvents( cmp , event , helper );
	}, 
    addConfToHierarchy : function( cmp , tableCmp , event , helper ) {				        
        var row2DArray = helper.createRow( cmp.get('v.rootNode') , null , helper , 1 );				
		$A.createComponents( row2DArray , function( components , status , errorMessage ) {
			if( status === 'SUCCESS' ) {
				helper.addRowList( components , tableCmp ,  event  , cmp , helper);
			} else {
                helper.showToast( cmp , errorMessage );
				console.log( errorMessage );
			}
		 });		
	},
   	getData : function( fieldName , sobject ) {
		var fieldArray = fieldName.split('.');        
        var length = fieldArray.length;
        //console.log(fieldArray.length + ' ' + fieldName);
        if( fieldArray.length == 1 ) {
            return sobject[ fieldName ];
        }
        for( var i=0;i<length;i++){
            sobject = sobject[ fieldArray[ i ] ];
            if( sobject == undefined ) {
                return '';
            }
            console.log( sobject );
        }
        return sobject;
	},
    showToast : function(cmp,error) {
        $A.createComponent( "c:ErrorHandler",{"message":error}, function( newToast , status , errorMessage ) {
			if( status === 'SUCCESS' ) {
				console.log("Component created successfully");
                var body = cmp.find("errorBlock");
                var bodyCmp =cmp.get("v.body");
                bodyCmp.push(newToast);
                cmp.set("v.body", bodyCmp);
			} else {
                console.log("Error Handler Component creation error: ",errorMessage);
			}
		 });
	},
    processEvents : function( cmp , event , helper) {
        var count =0;
        var eventQueue = cmp.get('v.eventQueue');
        var node;
        
        if( eventQueue.length > 0 ) {
        	node  = eventQueue.shift();            
            var expandEvent = cmp.getEvent("expandEvent");			
			expandEvent.setParams( { "node" : JSON.parse(node.value) } );				
			expandEvent.fire();
            cmp.set('v.eventQueue' , eventQueue );
        }
        helper.toggleLoadingWindow( cmp , event , helper );
	},
    toggleLoadingWindow : function( component , event , helper , isShow ) {
    	console.log( 'toggleLoadingWindow');
        var loadingCmp = component.find('loading');    	
		$A.util.toggleClass( loadingCmp , 'loading');
		$A.util.toggleClass( loadingCmp , 'hide');		
	}
})