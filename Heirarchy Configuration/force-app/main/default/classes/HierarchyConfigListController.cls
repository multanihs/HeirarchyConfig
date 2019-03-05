public class HierarchyConfigListController{
    
    @AuraEnabled
    public static List<HierarchyConfig__c> getConfigList( string configId ){ 
		if(!String.isEmpty( configId )){
			return  [ SELECT id,Object__c,fields__c,Label__c,fieldTypes__c,DisplayField__c,Icon__c,parentId__c,fieldTitleList__c,RelatedObject__c,filterCondition__c,hasSubRelatedConfig__c,haveSetSupport__c FROM HierarchyConfig__c
                            WHERE parentId__c = :configId ];    
            
        }
        return  [ SELECT id , Object__c , RecordType__c ,DisplayField__c , RelatedObject__c  FROM HierarchyConfig__c
                            WHERE RelatedObject__c = null  ORDER BY Object__c ];    
    }
    
    @AuraEnabled
    public static boolean deleteConfigRecord(string configId){        
        try{
            String id = String.valueOf( configId );
            List< HierarchyConfig__c > configList = [ SELECT id,Object__c,RelatedObject__c,hasSubRelatedConfig__c,parentId__c FROM HierarchyConfig__c WHERE id=:id];
            List< HierarchyConfig__c > relatedConfigList; 
            List< HierarchyConfig__c > parentConfigList; 
            
            if( !configList.isEmpty() ) {
            	HierarchyConfig__c config = configList.get( 0 );
                delete configList;    
                if( config.parentId__c != null ) {
                    relatedConfigList = getConfigList( config.parentId__c );
                	if( relatedConfigList.isEmpty() ){                    	
                        HierarchyConfig__c parentConfig = new HierarchyConfig__c( id = config.parentId__c  , hasSubRelatedConfig__c = false );
						parentConfigList = new List< HierarchyConfig__c >();
                        parentConfigList.add( parentConfig );
                        update parentConfigList;
                    }
                }
            }
            return true;
        }catch(Exception e){
            throw new AuraException('Error occured: '+ e); 
            return false;
        }
    }
    @AuraEnabled
    public static void saveConfigRecord( List< HierarchyConfig__c >  configList ) {    	    	   
		try {	
            // GJ : Platform issue here...  Aura is treating configList as generic SObjectList
            List< HierarchyConfig__c > hierarchyConfigList = new List< HierarchyConfig__c > ();
            hierarchyConfigList.addAll( configList );
			upsert hierarchyConfigList;  
			//upsert configList;  
		} catch(DMLException e ) {            
			throw e;
            //throw new AuraHandledException('Error occurred:'+e.getMessage());
		}                   
    }
}