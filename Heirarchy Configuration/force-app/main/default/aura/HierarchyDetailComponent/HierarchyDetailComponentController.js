({
	doInit : function(component, event, helper) {
		var config = component.get("v.config");
		var titleStr = config.fieldTitleList__c;
		var titleArray = titleStr.split(',');        
		component.set('v.titleArray', titleArray);
		helper.getData( component , event , helper );	
	},
	showMoreData : function( component , event , helper ) {
		
        helper.getData( component , event , helper );
	}	
})