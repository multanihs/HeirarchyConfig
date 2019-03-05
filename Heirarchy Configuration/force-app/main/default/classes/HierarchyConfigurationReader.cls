public with sharing class HierarchyConfigurationReader {
    /*public static List<HierarchyConfig__c> getRelatedConfig( String objectName ) {
    	return [ SELECT hasSubRelatedConfig__c,ParentId__c,RecordType__c , DisplayField__c,fields__c,fieldTypes__c,fieldTitleList__c,filterCondition__c,Id,isRelated__c,Label__c,Object__c,ParentField__c,RelatedObject__c,Icon__c,Class_Name__c,Custom_Sorting__c FROM HierarchyConfig__c WHERE  Object__c like :objectName AND isRelated__C = true ];
    }*/
    public static  List<HierarchyConfig__c> getConfig( String objectName ) {
    	return [ SELECT hasSubRelatedConfig__c,ParentId__c,RecordType__c , DisplayField__c,fields__c,fieldTypes__c,haveSetSupport__c,fieldTitleList__c,filterCondition__c,Id,isRelated__c,Label__c,Object__c,ParentField__c,RelatedObject__c,Icon__c,Class_Name__c,Custom_Sorting__c FROM HierarchyConfig__c WHERE  Object__c like :objectName AND RecordType__c = '']; 	
    }
    public static  List<HierarchyConfig__c> getConfig( String objectName , String recordType ) {
    	return [ SELECT hasSubRelatedConfig__c,ParentId__c,RecordType__c , DisplayField__c,fields__c,fieldTypes__c,haveSetSupport__c,fieldTitleList__c,filterCondition__c,Id,isRelated__c,Label__c,Object__c,ParentField__c,RelatedObject__c,Icon__c,Class_Name__c,Custom_Sorting__c FROM HierarchyConfig__c WHERE  RelatedObject__c='' AND Object__c like :objectName AND RecordType__c  like :recordType ]; 	
    }

    public static List<HierarchyConfig__c> getConfigById( String id ) {
    	return [ SELECT hasSubRelatedConfig__c,ParentId__c,RecordType__c , DisplayField__c,fields__c,fieldTypes__c,fieldTitleList__c,haveSetSupport__c,filterCondition__c,Id,isRelated__c,Label__c,Object__c,ParentField__c,RelatedObject__c,Icon__c,Class_Name__c,Custom_Sorting__c FROM HierarchyConfig__c WHERE  id = :id ];
    }
    public static List<HierarchyConfig__c> getRelatedConfigsByParent( String id ) {
    	return [ SELECT hasSubRelatedConfig__c,ParentId__c,RecordType__c,DisplayField__c,fields__c,fieldTypes__c,fieldTitleList__c,filterCondition__c,Id,isRelated__c,Label__c,Object__c,ParentField__c,RelatedObject__c,Icon__c,Class_Name__c,Custom_Sorting__c FROM HierarchyConfig__c WHERE  ParentId__c = :id ];
    }
	public static List<HierarchyConfig__c> getRelatedConfigsByParent( String parentId , String relatedObject ) {
    	return [ SELECT hasSubRelatedConfig__c,ParentId__c,RecordType__c,DisplayField__c,fields__c,fieldTypes__c,fieldTitleList__c,filterCondition__c,Id,isRelated__c,Label__c,Object__c,ParentField__c,RelatedObject__c,Icon__c,Class_Name__c,Custom_Sorting__c FROM HierarchyConfig__c WHERE  ParentId__c = :parentId  AND RelatedObject__c = :relatedObject];    
    }
}