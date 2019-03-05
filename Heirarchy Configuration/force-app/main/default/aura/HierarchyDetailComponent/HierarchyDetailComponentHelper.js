({
	getData : function( cmp , event , helper ) {
		var parentSObject  = cmp.get( 'v.parentSObject');
		var parentConfig = cmp.get('v.config');
		var listCount = cmp.get('v.sobjectList').length;
		var recordCount = cmp.get( 'v.serverRecCount');
		var pageNum = 1; 
		
		if( listCount < recordCount ){
            //console.log( 'listCount' +  listCount + ' recordCount : ' + recordCount );
			pageNum =  listCount / 20  + 1;
            //console.log( 'pageNum ' + pageNum );
		}
		
		var listAction = cmp.get("c.getSObjects");
		listAction.setParams( { "configId" : parentConfig.Id , "parentId" : parentSObject.Id , "pageNum" : pageNum } );                       				
		listAction.setCallback( this , function( response ) {
			var state = response.getState();
			var hierarchyBean = response.getReturnValue();
			var config = hierarchyBean.config;								
			config.fieldTitleList__c = parentConfig.fieldTitleList__c;
            config.fields__c = parentConfig.fields__c;
            config.Label__c = parentConfig.Label__c;
            //console.log( 'hierarchyBean');
            //console.log( hierarchyBean);
            if (cmp.isValid() && state === "SUCCESS") {
            	var row2DArray = [];
            	            	
            	cmp.set( 'v.sobjectList' , cmp.get('v.sobjectList').concat( hierarchyBean.recordList ));
            	cmp.set( 'v.serverRecCount' , hierarchyBean.recordCount );
            	
            	for( var i=0;i<hierarchyBean.recordList.length;i++) {
            		//console.log( config );
                    row2DArray.push( [ 'c:TableRow',{ "config" : parentConfig , "record" : hierarchyBean.recordList[ i ] } ] );
            	}	
                
            	$A.createComponents( row2DArray , function( cmps , status , errorMessage ) { 
            		if( status == 'SUCCESS') {
            			var tableBody = cmp.find('recordTable').get('v.body')[1];
            			var rowList = tableBody.get("v.body"); 		            			
                        cmps = rowList.slice( 0 , rowList.length ).concat( cmps ).concat( rowList.slice( rowList.length   ));            			
                        tableBody.set("v.body" , cmps );            		            			            			
            		} else {
            			console.log( errorMessage );
            		}
            	});	
            }
		});
		$A.enqueueAction( listAction ); 
    }
})