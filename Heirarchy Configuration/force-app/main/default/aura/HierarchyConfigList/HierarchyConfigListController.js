({
	doInit : function(component, event, helper) {
		helper.getConfigList(component , event , helper , false );	
	},
    handleDeleteEvent : function(component, event, helper ){      	
        var confirmVar = confirm("Are you sure you want to delete?");
		if(confirmVar) {
            var config = event.getParam("config");
            if( !config ) {;
                 config = event.getSource().get("v.value"); 
            }
            helper.delete(component, event, helper, config.Id , config.RelatedObject__c != undefined );
        }
    },   
    closeModal : function(component, event, helper){
        helper.closeModal(component, event, helper);
    },
    openModal : function(component, event, helper){        
        helper.openModal(component, event, helper);
    },
    newRecord : function(component, event, helper){
        helper.newRecord(component, helper,false);       
    },
    newRelatedRecord : function(component, event, helper){
        console.log( component.get( 'v.selectedConfigs') );
        helper.newRecord(component, helper,true);       
    },
    handleClick : function(component, event, helper) {
        component.set('v.isOpen', true);
        var config = event.getSource().get("v.value");                 
        helper.openNewModal( component, helper , config , false );        
	},
    handleRelatedRecords  : function(component, event, helper){                  		
        var configArray = [] ;
        var config = event.getSource().get("v.text");            
        configArray.push( config );
        component.set('v.selectedObjConfig', config );        
        component.set('v.selectedConfigs', configArray );        
        helper.getConfigList(component,event , helper , true );  
    },
    getRelatedConfig : function( component , event , helper ) {
		var config = event.getParam( 'config');
        console.log(  config );
        var configArray =component.get('v.selectedConfigs');
        configArray.push( config );
        component.set( 'v.selectedConfigs' , configArray );
        helper.getConfigList(component,event , helper , true );  
    },
    changeConfig : function( component, event , helper ) {
        var index  = event.target.dataset['index'];        
        var configArray =component.get('v.selectedConfigs');        
        configArray = configArray.slice( 0 , parseInt(index) + 1);        
        component.set( 'v.selectedConfigs' , configArray );
        helper.getConfigList(component,event , helper , true );  
    },
    refreshEvent : function( component , event , helper ) {                
        helper.closeModal(component,helper);
        helper.getConfigList(component,event , helper , event.getParam('isRelated'));  
    }
})