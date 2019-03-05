/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class HierarchyControllerTest {

    @testSetup static void createTestData() {
        TestDataFactory.createConfigs(); 
        List<Account> accountList = TestDataFactory.createPracticeAccounts( 1 );
		TestDataFactory.createCustomerContacts( 'Practice_Contact' , accountList , 5 , 1 , false );
        TestDataFactory.createBDOpportunities( accountList , 1 );
    }
    
    static testMethod void getRelatedConfiguration() {
        Id acctId = [SELECT Id FROM Account LIMIT 1].Id;
        
        Test.startTest();
        List< HierarchyConfig__c >  hierarchyConfigList = HierarchyConfigListController.getConfigList( '' );          
        String configId;
        
        for( HierarchyConfig__c config : hierarchyConfigList ) {
        	if( config.Object__c == 'Account' && config.RelatedObject__c == null ) {
        		configId = config.Id;
        		break;
        	}	
        }
		System.assert( configId != null );        
        HierarchyController.HierarchyBean bean = HierarchyController.getRelatedConfiguration(configId, acctId);        
        Test.stopTest();
        System.assert( bean != null );
        System.assert( bean.recordList.size() > 0 );        
    }

    static testMethod void testSObjectList() {
        String configId ,parentConfigId ;
        Account acc;                
        Test.startTest();
		acc = [ SELECT id FROM Account WHERE name like 'Account0'];
        HierarchyController.HierarchyBean bean  = HierarchyController.getDetailRecord( 'Account', acc.id);
        parentConfigId = bean.config.Id;
        
        System.assertEquals( 1  , bean.recordList.size() );
        System.assertEquals( acc.id  , bean.recordList.get( 0 ).id );
        
        bean   = HierarchyController.getRelatedConfiguration(parentConfigId, acc.Id);
        System.assert( bean != null );
        System.assert( bean.recordList.size() > 0 );        
        
        for( SObject config : bean.recordList ) {
            //System.debug( config.get('RelatedObject__c')  );
            if( config.get('RelatedObject__c').equals('Contact') ) {
                configId = config.id;       
            }
        }                
        bean = HierarchyController.getSObjects( configId , acc.id ,  1 );
        Test.stopTest();
        System.assert( bean != null );
        System.assertEquals( 5 , bean.recordList.size() );           
    }
    static testMethod void testSObjectListByOffset() {
        String configId ,parentConfigId ;
		Account acc;     
        
        Test.startTest();
		acc = [ SELECT id FROM Account WHERE name like 'Account0'];
        HierarchyController.HierarchyBean bean  = HierarchyController.getDetailRecord( 'Account' , acc.id );
        parentConfigId = bean.config.Id;
        
        System.assertEquals( 1  , bean.recordList.size() );
        System.assertEquals( acc.id  , bean.recordList.get( 0 ).id );
        
        bean = HierarchyController.getRelatedConfiguration(parentConfigId, acc.Id);
        System.assert( bean != null );
        System.assert( bean.recordList.size() > 0 );        
        
        for( SObject config : bean.recordList ) {
            //System.debug( config.get('RelatedObject__c')  );
            if( config.get('RelatedObject__c').equals('Opportunity') ) {
                configId = config.id;       
            }
        }                                
        bean = HierarchyController.getSObjects( configId , acc.id ,  1 );
        
        System.assert( bean != null );
        System.assertEquals( 1 , bean.recordList.size() );       
    	parentConfigId = bean.config.Id; // Opportunity config id 
    	
		bean = HierarchyController.getRelatedConfiguration(parentConfigId, acc.Id);
        for( SObject config : bean.recordList ) {            
            if( config.get('RelatedObject__c').equals('OpportunityTeam') ) {
                configId = config.id;       
            }
        }
        bean = HierarchyController.getSObjects( configId , acc.id ,  1 );
        Test.stopTest();
        System.assert( bean != null );
        System.assert( !bean.recordList.isEmpty() );    	
    }    
    static testMethod void testNoConfig() {
    	try {
    		Test.startTest();
            HierarchyController.getDetailRecord(  'dummy', '001000000000000000' );
            
    		System.assert( false );
            Test.stopTest();
    	} catch( Exception e ) {
    		System.assertEquals(  'No Configuration Found' , e.getMessage() );
    	}    	
    }
    static testMethod void testObjectConfig() {
        Test.startTest();
    	HierarchyController.HierarchyBean bean = HierarchyController.getParentConfigList( 1 ) ;    	
        Test.stopTest();
    	System.assert( bean != null );
    	System.assert( !bean.recordList.isEmpty() );    	
    	
    }
    
    static testMethod void testObjectConfigRead() {    	    		
    	List< HierarchyConfig__c >  hierarchyConfigReadList; 
		Test.startTest();	
    	hierarchyConfigReadList = HierarchyConfigListController.getConfigList( '' ); 
    	System.assertEquals( hierarchyConfigReadList.isEmpty() , false );
    	for( HierarchyConfig__c config : hierarchyConfigReadList ) {
    		System.assertEquals( config.RelatedObject__c , null );	
    	}    	    
        Test.stopTest();
    }
    static testMethod void testRelatedConfigRead() {
    	HierarchyConfig__c configSObj;
    	List< HierarchyConfig__c > relatedConfigList;    	    	
    	Test.startTest();
    	configSObj = getObjectConfig( 'Account');
    	System.assert(  configSObj != null );
    	    	     	
    	relatedConfigList = HierarchyConfigListController.getConfigList( configSObj.id );	  
        Test.stopTest();
    	System.assert( relatedConfigList.size() != 0 );
    	System.assertEquals( configSObj.id,relatedConfigList.get( 0 ).parentId__c );	    	
    }
    static testMethod void testDeleteConfigRecords() {
    	HierarchyConfig__c configSObj , parentConfigSObj;
    	List< HierarchyConfig__c > relatedConfigList;
    	    	    	
    	Test.startTest();
    	configSObj = getObjectConfig( 'Account');
    	System.assert(  configSObj != null );
    	    	        	
    	parentConfigSObj = getRelatedConfig( configSObj , 'Opportunity');
    	System.assert(  parentConfigSObj != null );
    	
		relatedConfigList = HierarchyConfigListController.getConfigList( parentConfigSObj.Id );
				
		System.assertEquals(  3 , relatedConfigList.size() );
		
		HierarchyConfigListController.deleteConfigRecord( relatedConfigList.get( 0 ).id );
		parentConfigSObj =  getRelatedConfig( configSObj , 'Opportunity');
		System.assertEquals( true ,parentConfigSObj.hasSubRelatedConfig__c  );
		
		HierarchyConfigListController.deleteConfigRecord( relatedConfigList.get( 1 ).id );
		parentConfigSObj = getRelatedConfig( configSObj , 'Opportunity');
		System.assertEquals( true , parentConfigSObj.hasSubRelatedConfig__c  );
		
		HierarchyConfigListController.deleteConfigRecord( relatedConfigList.get( 2 ).id );
		parentConfigSObj = getRelatedConfig( configSObj , 'Opportunity' );
		System.assertEquals(  false , parentConfigSObj.hasSubRelatedConfig__c );
		Test.stopTest();		     	
    }
    static testMethod void testSaveConfigRecords() {
    	HierarchyConfig__c configSObj , parentConfigSObj;
    	    	
    	Test.startTest();
    	configSObj = getObjectConfig( 'Account');
    	System.assert(  configSObj != null );
		System.assertEquals( configSObj.DisplayField__c , 'Name');
		configSObj.DisplayField__c = 'BillingCity';
		
    	HierarchyConfigListController.saveConfigRecord( new List< HierarchyConfig__c> { configSObj } );
    	configSObj = getObjectConfig( 'Account');
    	System.assert(  configSObj != null );
    	System.assertEquals( configSObj.DisplayField__c , 'BillingCity');
    	Test.stopTest();
    }
    
    private static HierarchyConfig__c getObjectConfig( String objName ) {
    	List< HierarchyConfig__c >  hierarchyConfigList;    	
    	hierarchyConfigList = HierarchyConfigListController.getConfigList( '' );
    	
    	for( HierarchyConfig__c config : hierarchyConfigList ) {
    		if( config.Object__c == objName && config.RelatedObject__c == null ) {
    			return config;    			
    		}	
    	}
    	return null;    	    	
    } 
    private static HierarchyConfig__c getRelatedConfig( HierarchyConfig__c parentConfig   , String relatedObjName ) {    	
    	List< HierarchyConfig__c > relatedConfigList;
    	
    	relatedConfigList = HierarchyConfigListController.getConfigList( parentConfig.id  );
    	for( HierarchyConfig__c config : relatedConfigList ) {
    		if( config.Object__c == parentConfig.Object__c && config.RelatedObject__c == relatedObjName ) {
    			return config;    			
    		}	
    	}    	
    	return null; 
    }
}