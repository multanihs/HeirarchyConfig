public with sharing class HierarchyConfigValidator {

    public static void validateConfigs( List< HierarchyConfig__c>  configList ) {
    	Set< String > objectSet = new Set< String >();
    	List< String > objTypes = new List< String >();    	
    	Schema.DescribeSobjectResult sobjResult;   
    	 	      	
    	for( HierarchyConfig__c config : configList ) {    		
    		objTypes.clear();
    		objTypes.add( config.Object__c );
    		    		
            if(config.RelatedObject__c != null){ 
    			objTypes.add(config.RelatedObject__c);
    		}
    		Schema.DescribeSobjectResult[] results = Schema.describeSObjects( objTypes );
    		if(results.size() != objTypes.size()){
    			config.addError( 'Object types need to be corrected' );
    			continue;
    		}
    		validateFields(  config ,results  );    		
    		validateQuery( config , '\'' + results[ 0 ].getKeyPrefix() + '000000000000000\'' ); 
    	}    	
    }
    private static void validateFields( HierarchyConfig__c config , Schema.DescribeSobjectResult[] results  ) {
    	Set< String > fieldNameSet = new Set< String >();
    	Schema.DescribeSobjectResult sobjResult;
		Set< String > tempFieldNameSet = new Set< String>();
		
		fieldNameSet.clear();
		sobjResult =  results[ 0 ] ;
		
		if(!config.DisplayField__c.contains( '.' )){
			fieldNameSet.add( config.DisplayField__c.toLowerCase() );	
		}						   		
		if(config.RelatedObject__c != null){			  
			for( String fieldName :  config.fields__c.toLowerCase().split(  ',')){
				if( !fieldName.contains('.')) {
					fieldNameSet.add(  fieldName );		
				}
				tempFieldNameSet.add( fieldName );
			}							
			sobjResult =  results[ 1 ] ;    		
		}  
		Map< String ,Schema.SObjectField > fieldMap  = sobjResult.fields.getMap();		
		if( !fieldMap.keySet().containsAll(  fieldNameSet ) ) {
			config.addError( 'fields not found.' );
			return;
		}
		if( config.RelatedObject__c != null ) {
			setFieldTypes( config , fieldMap , tempFieldNameSet );
		}				     		  		    	
    }       
    private static void setFieldTypes( HierarchyConfig__c config , Map< String ,Schema.SObjectField > fieldMap  ,  Set< String > fieldNameSet ) {
    	Schema.DescribeFieldResult fieldResult;
    	
    	config.fieldTypes__c = '';
    	for( String fieldName : fieldNameSet ) {
    		if( !fieldName.contains('.')) {
    			fieldResult = fieldMap.get( fieldName ).getDescribe();
    			config.fieldTypes__c = config.fieldTypes__c  + fieldResult.getType() + ',';
    		} else {
    			config.fieldTypes__c = config.fieldTypes__c  +  'LOOKUP,';
    		}	
    	}
    	config.fieldTypes__c = config.fieldTypes__c.removeEnd(',');    	
    }
    private static void validateQuery( HierarchyConfig__c configRec , String id ) {
        String objectName;
        String query;
        
        if( ( configRec.RelatedObject__c != null ) && ( configRec.RelatedObject__c != '' ) ) {
            objectName = configRec.RelatedObject__c;
            String fieldsStr = configRec.fields__c ;
            query = 'SELECT '+ fieldsStr + ' FROM ' + configRec.RelatedObject__c+ ' WHERE ';
    		query = query + configRec.filterCondition__c;
    		String[] placeHolderArray = new String[ 1 ];
			placeHolderArray[ 0 ] = id ;
    		query = Util.format( query , placeHolderArray );   
                        
        } else {
            objectName = configRec.Object__c;
            query = 'SELECT id,' + configRec.DisplayField__c  + ' FROM ' + objectName  + ' LIMIT 1';
        }        
        try {
			Database.query(query);            
        } catch(QueryException e) {            
            String errorMessage = e.getMessage();
            if(errorMessage .containsIgnoreCase('unexpected token')) {
                configRec.addError('Please use \',\' for separating fields');
            } else if(errorMessage.containsIgnoreCase('sObject type')) {
                configRec.addError('Please input valid Object API Name');
            } else if(errorMessage.containsIgnoreCase('no such column')) {
                configRec.addError('Please input valid field API Name: '+e.getMessage());
            } else {
                configRec.addError('Error: '+e.getMessage());
            }            
        }                   
    }    
}