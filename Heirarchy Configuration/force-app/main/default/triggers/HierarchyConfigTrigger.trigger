trigger HierarchyConfigTrigger on HierarchyConfig__c ( before insert , before update ) {
    
    if( Trigger.isBefore ) {
    	if( Trigger.isInsert ) {
    		HierarchyConfigValidator.validateConfigs( Trigger.New );
    	} else if( Trigger.isUpdate ) {
			HierarchyConfigValidator.validateConfigs( Trigger.New );    		
    	}
    }	
}