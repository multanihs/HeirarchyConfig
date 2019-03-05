public class HierarchyController {
    @AuraEnabled 
    public static HierarchyBean getRelatedConfiguration(String id, String recordId) {
        //Get list of Related Configs for child objects
        List<HierarchyConfig__c> listRelatedConfigs = HierarchyConfigurationReader.getRelatedConfigsByParent(id);
        Map<String, Boolean> mapConfigLabelRecordExist = new Map<String, Boolean>();							//Map<ConfigLabel, ChildRecordExist?>
        
		//Changes for User Story W-1283 Continuation to W-000772 - Colour coding for Hierarchy Component. 
        if(listRelatedConfigs != null && !listRelatedConfigs.isEmpty()){
            String placeHolderValue = '\'' + recordId + '\'';
            List<String> listPlaceHolder = new List<String>{placeHolderValue};
                
			//Since the code was getting to complex, added SOQL query inside for loop and checked for Limits. Refer comments in story.
			for(HierarchyConfig__c objHierarchyConfig : listRelatedConfigs){
				if(Limits.getQueries() < Limits.getLimitQueries()){
					String query = 'SELECT Id FROM ' + objHierarchyConfig.RelatedObject__c + ' WHERE '; 
					String whereClause = objHierarchyConfig.filterCondition__c != null ? Util.format(objHierarchyConfig.filterCondition__c, listPlaceHolder) + ' LIMIT 1': '';
					query = query + whereClause;
					
					List<SObject> listSObj = Database.query(query);
					Boolean isChildRecordPresent = listSObj != null && !listSObj.isEmpty() ? true : false;
					mapConfigLabelRecordExist.put(objHierarchyConfig.Label__c, isChildRecordPresent);
				}
			}
		}
        /*return new HierarchyBean( HierarchyConfigurationReader.getConfigById( id )[0] , 
			HierarchyConfigurationReader.getRelatedConfigsByParent( id ) , 'config');*/
        return new HierarchyBean(HierarchyConfigurationReader.getConfigById(id)[0], listRelatedConfigs, mapConfigLabelRecordExist, 'config');
    }
    @AuraEnabled
    public static  HierarchyBean getDetailRecord( String sobjType , String id ) {
    	List< HierarchyConfig__c > configList;
    	
    	if ( SObjectReader.isRecordTypeSupported( sobjType ) ) {
    		configList = HierarchyConfigurationReader.getConfig( sobjType , SObjectReader.getRecordType( id , sobjType ));
    	} else {
    		configList = HierarchyConfigurationReader.getConfig( sobjType );
    	}    	    	
    	if( !configList.isEmpty() ) {
    		return new HierarchyBean( configList.get( 0 ) , SObjectReader.getSObjectDetail( id , configList.get( 0 ) ) , 'data');	
    	}
        AuraHandledException e = new AuraHandledException('No Configuration Found');
        e.setMessage('No Configuration Found');
        throw e;
        return null;    	    	
    } 
    
    @RemoteAction
    @AuraEnabled
    public static HierarchyBean getSObjects( String configId , String parentId , Integer pageNum ) {
        List< HierarchyConfig__c > configList = HierarchyConfigurationReader.getConfigById( configId );
    	HierarchyConfig__c relatedObjConfig , config;
    	ApexPages.StandardSetController con;
    	HierarchyController.HierarchyBean bean;
    	List< sobject > sobjList;
    	Integer recordCount; 
    	    	
    	if( !configList.isEmpty() ) {    		
    		config  = configList.get( 0 );
    		relatedObjConfig = HierarchyConfigurationReader.getConfig( configList.get( 0 ).RelatedObject__c )[0];    		
    		if( config.haveSetSupport__c ) {
    			con = SObjectReader.getSObjectList( config , parentId , pageNum , 20 );
    			bean = new HierarchyBean( config  , con.getRecords() , con.getResultSize() , 'data');    			
    		} else {
    			sobjList = SObjectReader.getSObjectListBySOQL( config , parentId , pageNum , 20 );
    			recordCount = SObjectReader.getRecordCount( parentId , config );
    			// Offset in SOQL doesn't support more than 2000 records.
    			bean = new HierarchyBean( config  , sobjList , ( recordCount > 2000 ? 2000 : recordCount ) , 'data' );    				
    		}    		    		    		
    		return bean;
		}
    	AuraHandledException e = new AuraHandledException('No Configuration Found');
        e.setMessage('No Configuration Found');
        throw e;
        return null;  
    }    
    @AuraEnabled 
    public static HierarchyBean getParentConfigList( Integer pageNum ) {
    	ApexPages.StandardSetController con;
    	con = SObjectReader.getParentConfigList( pageNum );    	
    	return new HierarchyBean( null  , con.getRecords() , con.getResultSize() , 'config');
    }
      
    public class HierarchyBean {
    	@AuraEnabled public HierarchyConfig__c config { get;set; }
    	@AuraEnabled public List<SObject> recordList{ get;set;}
    	@AuraEnabled public Integer recordCount{ get;set;}
    	@AuraEnabled public String nodeType{ get;set;}
    	@AuraEnabled public Map<String, Boolean> mapConfigLabelRecordExist{get;set;}				//Map<ConfigLabel, ChildRecordExist?>
        
    	HierarchyBean( HierarchyConfig__c config , List<SObject> recordList , String nodeType ) {
    		this.config = config;
    		this.recordList = recordList;
    		this.nodeType = nodeType;    		
    	}
        
        HierarchyBean(HierarchyConfig__c config, List<SObject> recordList, Map<String, Boolean> mapConfigLabelRecordExist, String nodeType){
    		this.config = config;
    		this.recordList = recordList;														//List of Related Config
    		this.mapConfigLabelRecordExist = mapConfigLabelRecordExist;
            this.nodeType = nodeType;    		
    	}
        
    	HierarchyBean( HierarchyConfig__c config , List<SObject> recordList , Integer rCount , String nodeType ) {
    		this.config = config;
    		this.recordList = recordList; 
    		this.recordCount = rCount;
    		this.nodeType = nodeType;   		
    	}
    }   
}