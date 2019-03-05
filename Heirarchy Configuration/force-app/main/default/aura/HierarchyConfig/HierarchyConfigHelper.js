({
    saveRecord : function(component, event, helper) {        
		var configRec = component.get("v.configRec");
        var isRelated = component.get("v.isRelated");
        
        configRec.sobjectType = 'HierarchyConfig__c';
		        
        if(!isRelated ){
            if(!configRec.Object__c){
                        helper.showToast(component,'Please enter Object name');
                		return;
            }
            if(!configRec.DisplayField__c){
                        helper.showToast(component,'Please enter Display Field');
                		return;
            }
            
        }
        else{
            if(!configRec.RelatedObject__c){
                        helper.showToast(component,'Please enter Related object');
                		return;
            }
            if(!configRec.Label__c){
                        helper.showToast(component,'Please enter Label');
                		return;
            }
            if(!configRec.fields__c){
                        helper.showToast(component,'Please enter \',\' separated field API names');
                		return;
            }
            if(!configRec.fieldTitleList__c){
                        helper.showToast(component,'Please enter \',\' separated field labels');
                		return;
            }
            if(!configRec.Icon__c){
                        helper.showToast(component,'Please enter icon value');
                		return;
            }
        }
		//helper.toggleLoadingWindow( component, event , helper );             
        var action = component.get("c.saveConfigRecord");       	
        var parentConfig = component.get( 'v.parentConfig' );        
        var configArray = [ configRec ];
        if( isRelated == true ) {
            parentConfig.hasSubRelatedConfig__c = true;
            parentConfig.sobjectType = 'HierarchyConfig__c';
        	configArray.push( parentConfig );
        }                
		action.setParams( { "configList" : configArray });             
		action.setCallback( this , function( response ) {			
            var state = response.getState();            
			if ( component.isValid() && state === "SUCCESS" ) {	
                var refreshEvent = component.getEvent("refreshEvent");
                refreshEvent.setParams( {"isRelated": component.get( "v.isRelated")} );
				refreshEvent.fire();                
			} else if (component.isValid() && state === "INCOMPLETE" ) {
				console.log( response );
			} else {                
                console.log( state  );
				console.log( response.getReturnValue()  );
                var errors = response.getError();
                if (errors) {
                    if ( errors[0] && Array.isArray( errors[0].pageErrors ) )  {
                        helper.showToast(component , 'Code : ' +  errors[0].pageErrors[0].statusCode + ' \n ' + errors[0].pageErrors[0].message );
                    } else if( errors[0] && Array.isArray( errors[0].fieldErrors ) ) {
                        helper.showToast(component , errors[0].fieldErrors[0].message );
                    }
                } else {
                    	helper.showToast(cmp,'Unknown Message');
                }                
			}
            //helper.toggleLoadingWindow( component, event , helper );
		});
		$A.enqueueAction( action );		        
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
	toggleLoadingWindow : function( component , event , helper ) {
    	var loadingCmp = component.find('loading');    	
		$A.util.toggleClass( loadingCmp , 'loading');
		$A.util.toggleClass( loadingCmp , 'hide');		
	}
})