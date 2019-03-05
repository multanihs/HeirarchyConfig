({
	handleClick : function(component, event, helper) {        
        //console.log( 'onclick ' + component.get("v.config") );
        var showRelatedConfig = component.getEvent("showRelatedConfig");
        console.log( component.getElement());
        showRelatedConfig.setParams({
            config: component.get("v.config"),
            level:"2",
            index: component.getElement().rowIndex
        }).fire();
	},
    handleDelete : function(component, event, helper) {
    	var deleteConfig = component.getEvent("deleteConfig");
        deleteConfig.setParams({
            config: component.get("v.config")
        }).fire();
    },
    handleEdit : function(component, event, helper) {
        var toggleModal = component.getEvent("toggleModal");
        toggleModal.setParams({
            config: component.get("v.config")            
        }).fire();        
	},
    setConfig : function(component, event, helper) {
        console.log('child');
        var configRec = event.getParam("config");
        var configRowGlobalId = event.getParam("configRowGlobalId");
        if(configRowGlobalId == component.getGlobalId()){
        	component.set("v.config",configRec);
        }    
	}
})