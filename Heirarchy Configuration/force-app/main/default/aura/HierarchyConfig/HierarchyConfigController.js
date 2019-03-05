({
    cancel : function(component, event, helper) {
		var toggleEvent = component.getEvent("toggleModal");
		toggleEvent.fire(); 
	},
    save : function(component, event, helper) {
        helper.saveRecord(component,event,helper);	
	}
})