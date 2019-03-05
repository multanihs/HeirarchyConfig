public with sharing class SObjectReader {
	
    public static ApexPages.StandardSetController getSObjectList( HierarchyConfig__c configSObj , String parentId , Integer pageNum , Integer pageSize ) {    	    	
    	return getSObjectListByStandardSetController(configSObj, parentId, pageNum, pageSize, null, null);
    }
    
    public static ApexPages.StandardSetController getSObjectList(HierarchyConfig__c configSObj, String parentId, Integer pageNum, Integer pageSize, String sortField, Boolean sortOrder){    	    	
    	return getSObjectListByStandardSetController(configSObj, parentId, pageNum, pageSize, sortField, sortOrder);
    }
    
    public static ApexPages.StandardSetController getSObjectListByStandardSetController(HierarchyConfig__c configSObj, String parentId, Integer pageNum, Integer pageSize, String sortField, Boolean sortOrder){
        String query;
    	String fieldsStr;
    	String placeHolderValue  = '\'' + parentId + '\'';
    	List< String > placeHolderArray = new String[]{ placeHolderValue };
    	
    	fieldsStr = configSObj.fields__c; 
    	if( !Util.isFieldPresent( configSObj.DisplayField__c ,fieldsStr ) ) {
    		fieldsStr = fieldsStr + ',' + configSObj.DisplayField__c;
    	}
    	query = 'SELECT '+ fieldsStr + ' FROM ' + configSObj.RelatedObject__c+ ' WHERE ';
    	query = query + configSObj.filterCondition__c;
        
        //Added for Custom Sorting
       	if(String.isNotBlank(sortField)){
            
            //If query contains ORDER BY clause, remove the clause and add the clause along with the given 'sortField'
            if(query.contains('ORDER BY') || query.contains('order by')){
                Integer index = (query.indexOf('ORDER BY') != -1) ? query.indexOf('ORDER BY') : query.indexOf('order by');
                query = query.substring(0, index);          
            }
            if(sortOrder){
                 query = query + ' ORDER BY ' + sortField + ' ASC';
            }else{
                query = query + ' ORDER BY ' + sortField + ' DESC';
            }
        }
    	query = Util.format( query , placeHolderArray );
    	
    	ApexPages.StandardSetController stdCon = new ApexPages.StandardSetController( Database.getQueryLocator( query ));
        pageSize = Integer.valueOf(pageSize);
    	stdCon.setPageSize(pageSize);
        Integer firstPageNum = 1;    	
    	//[ GJ ] Looks like some issues in platform. When I call this method from aura enabled method, integer comparison throws error.
    	// Platfrom is also not letting set pageNUmber directly on standard controller. That's why, here is workaround.    	
    	pageNum = Integer.valueOf( pageNum );
    	while( firstPageNum < pageNum ) {    		
    		firstPageNum++;
    		stdCon.next();    		
    	}
    	return stdCon;    		    	    	    	    
    }
    
    public static Integer getRecordCount( String parentId , HierarchyConfig__c configSObj ) {
    	String query;
		String placeHolderValue  = '\'' + parentId + '\'';
    	List< String > placeHolderArray = new String[]{ placeHolderValue };
    	    	    	    	    	
    	query = 'SELECT count() FROM ' + configSObj.RelatedObject__c + ' WHERE ' ;    	    	  
    	query = query + configSObj.filterCondition__c;    	
    	query = Util.format( query , placeHolderArray );    	    	
		return Database.countQuery( query );    	
    }
    public static List<SObject> getSObjectListBySOQL( HierarchyConfig__c configSObj , String parentId , Integer pageNum , Integer pageSize ) {
    	String query;
    	String fieldsStr;
    	Integer offsetVal;
    	String placeHolderValue  = '\'' + parentId + '\'';
    	List< String > placeHolderArray = new String[]{ placeHolderValue };

    	pageNum = Integer.valueOf( pageNum );
        pageSize = Integer.valueOf(pageSize);
    	offsetVal = ( pageNum - 1 ) * pageSize;    	
    	
    	fieldsStr = configSObj.fields__c; 
    	if( !Util.isFieldPresent( configSObj.DisplayField__c ,fieldsStr ) ) {
    		fieldsStr = fieldsStr + ',' + configSObj.DisplayField__c;
    	}

    	query = 'SELECT '+ fieldsStr + ' FROM ' + configSObj.RelatedObject__c+ ' WHERE ';
    	query = query + configSObj.filterCondition__c;
    	query = Util.format( query , placeHolderArray );
        query = query + ' LIMIT ' + pageSize + ' OFFSET ' +  offsetVal ;  
		return Database.query( query );    	
    }     
    public static List<SObject> getSObjectDetail( String id , HierarchyConfig__c configSObj ) {
    	String query;
	    
    	query = 'SELECT '+ configSObj.DisplayField__c + ' ,id  FROM ' + configSObj.Object__c + ' WHERE ID =\'' + id + '\'';
		return  Database.query( query );
    } 
    public static ApexPages.StandardSetController  getParentConfigList( Integer pageNum ) {
    	String query = 'SELECT id , Object__c , DisplayField__c FROM HierarchyConfig__c WHERE isRelated__c = false';
    	
        ApexPages.StandardSetController stdCon = new ApexPages.StandardSetController( Database.getQueryLocator( query ));    	    
    	Integer firstPageNum = 1;    	
    	//[ GJ ] Looks like some issues in platform.. When I call this method from aura enabled method , integer comparison throws error.
    	// PLatfrom is also not letting set pageNUmber directly on standard controller. That's why , here is workaround.    	
    	pageNum = Integer.valueOf( pageNum );
    	while( firstPageNum < pageNum ) {    		
    		firstPageNum++;
    		stdCon.next();    		
    	} 
    	return stdCon;    		    	    	    	        	
    }
    public static Boolean isRecordTypeSupported( String sobjectName ) {
    	return Database.countQuery( 'SELECT count() FROM RecordType WHERE IsActive = true AND SobjectType =  \'' + sobjectName +  '\'' ) > 0 ;
    }
    public static String getRecordType( String id , String objectName ) {
    	SObject[] sobjList = Database.query( 'SELECT id , RecordType.Name FROM ' + objectName + ' WHERE id = \'' + id + '\'' );
    	SObject sobj;
    	
    	if( sobjList.isEmpty() ) {
    		return '';
    	}
    	sobj = sobjList[ 0 ];
    	//System.debug( sobj );
    	//System.debug( sobj.getSObject( 'RecordType') );
    	return ( String ) sobj.getSObject( 'RecordType').get( 'Name');
    }
    
    public static Map<Id, SObject> getUpdatedRecords(Set<Id> updatedRecordsIdSet, SObject configSObj){
        HierarchyConfig__c config = (HierarchyConfig__c)configSObj;
        
        String fieldsStr = config.fields__c; 
    	if( !Util.isFieldPresent(config.DisplayField__c, fieldsStr ) ) {
    		fieldsStr = fieldsStr + ',' + config.DisplayField__c;
    	}
        
        String whereClause = ' WHERE Id IN: updatedRecordsIdSet';
        String soqlQuery = 'SELECT ' + fieldsStr + ' FROM ' + config.RelatedObject__c + whereClause;
        Map<Id, SObject> sobjMap = new Map<Id, SObject>(Database.query(soqlQuery));
        
        return sobjMap;
    }
}