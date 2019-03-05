({
	handleClick : function(component, event, helper) {
		console.log(component);
        console.log(event);
        var errorBlock = component.find("errorId");
        console.log(errorBlock);
        $A.util.toggleClass(errorBlock, "slds-hide");
	}
})