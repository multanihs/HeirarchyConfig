({
	getConfigList : function(component,event , helper , isRelated ) {
        var action = component.get('c.getConfigList'); 
        var configArray =component.get('v.selectedConfigs');
        //console.log( configArray );
        helper.toggleLoadingWindow( component, event , helper );
        action.setParams( { "configId":( isRelated ? configArray[ configArray.length -1 ].Id : null )});
        // Set up the callback
        action.setCallback(this, function(actionResult) {
            if( isRelated == true ) {
				helper.createdRelatedView(component,actionResult.getReturnValue());
        	} else {
            	component.set('v.configs', actionResult.getReturnValue());
            }
			helper.toggleLoadingWindow( component, event , helper );            
        });
        $A.enqueueAction(action);	
	},
    createdRelatedView : function(component,configList){        
        component.set( 'v.showRelated' , true );
        component.set( 'v.relatedConfigs', configList );
    },
    closeModal  : function(component,helper){
         component.set('v.isOpen', false);
         var overlay = component.find("overlay");
         $A.util.toggleClass(overlay, 'slds-backdrop');
    },
    openModal : function(component, event, helper) {        
        if( component.get('v.isOpen') == true ) { 
        	helper.closeModal( component , helper );
        } else {
        	component.set('v.isOpen', true);
			helper.openNewModal( component, helper , event.getParam("config") , true );            
        }
    },
    newRecord : function(component, helper,isRelated) {               
        component.set('v.isOpen', true);
		var configRec = {};
        
        if( isRelated  ) {
            var parent = component.get( 'v.selectedConfigs').pop();
            component.get('v.selectedConfigs').push( parent );
            configRec.ParentId__c = parent.Id;
			configRec.haveSetSupport__c = true;
            configRec.Object__c = ( parent.RelatedObject__c != undefined ? parent.RelatedObject__c : parent.Object__c );
        }
        helper.openNewModal(component, helper, configRec , isRelated );
    },
    openNewModal : function(component, helper, configRec , isRelated) {        
        var divCmp = component.find("editDetail"); 
        var selectedConfigs = component.get('v.selectedConfigs');
        var parent ;
        
        if( selectedConfigs.length > 0 ) {            
            parent = component.get( 'v.selectedConfigs').pop();
            component.get('v.selectedConfigs').push( parent );            
        }
        
        $A.createComponent("c:HierarchyConfig" ,{ "configRec" : configRec , "isRelated" : isRelated , "parentConfig" : parent },function( rv , status , error ) { 
            if( status === 'SUCCESS' ) {                    
                divCmp.set("v.body", [ rv ]);                       
            } else  {
                console.log( error );
            }	
		});        
        var modal = component.find("editDialog");
        $A.util.toggleClass(modal, 'slds-fade-in-open');
        var overlay = component.find("overlay");
        $A.util.toggleClass(overlay, 'slds-backdrop--open');
    },    
    delete: function(component, event, helper,configId , isRelated ) {    	
		var action = component.get('c.deleteConfigRecord');
        action.setParams( { "configId" : configId});
        // Set up the callback
        action.setCallback(this, function(actionResult) {
            if( !isRelated ) {
                component.set( 'v.showRelated' , false );
                component.set( 'v.selectedConfigs' , []);
                component.set( 'v.relatedConfigs' , []);
                if( configId == component.get('v.selectedObjConfig').Id ){
                    component.set('v.selectedObjConfig', {} );
                }
            }            
            helper.getConfigList(component,event , helper , isRelated );
        });
        $A.enqueueAction(action);
	},	        
	toggleLoadingWindow : function( component , event , helper ) {
    	var loadingCmp = component.find('loading');    	
		$A.util.toggleClass( loadingCmp , 'loading');
		$A.util.toggleClass( loadingCmp , 'hide');		
	}
})