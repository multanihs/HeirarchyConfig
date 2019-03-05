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
public class TestDataFactory {

    public static List< Account > createAccounts( Integer accountCount , Integer seq) {
        List<Account> accList = new List<Account>();
        RecordType rt = [ SELECT Id FROM RecordType WHERE DeveloperName = 'HCS_ServiceLocation' AND SobjectType = 'Account' ];
        
        for(Integer i=0;i < accountCount ;i++) {
            Account a = new Account(Name='Account' + ( i + seq ) , ShippingStreet = 100 + (10*seq ) + ' St' , ShippingCountry = 'United States',ShippingState = 'Florida' , recordTypeId = rt.Id );
            accList.add(a);
        }
        insert accList;   
        return accList;                           
    }
	public static List< Account > createPracticeAccounts( Integer accountCount ) {
        List<Account> accList = new List<Account>();
        RecordType rt = [ SELECT Id FROM RecordType WHERE DeveloperName = 'Practice' AND SobjectType = 'Account' ];
        for(Integer i=0;i < accountCount ;i++) {
            Account a = new Account(Name='Account' + i , ShippingCountry = 'United States', ShippingState = 'Florida' , recordTypeId =  rt.Id , Solutions__c = 'Anesthesiology');
            accList.add(a);
        }
        insert accList;   
        return accList;                           
    }
    public static void createContacts( List< Account > accList , Integer contactsPerAccount ) {
        Integer accountCount = accList.size();
        Account acct;
        
        List<Contact> conList = new List<Contact>();
        for ( Integer j=0 ; j <  accountCount ; j++ ) {
            acct = accList[ j ];                                    
            
            for (Integer k = contactsPerAccount * j ; k < contactsPerAccount *(j+1) ; k++) {
                conList.add(new Contact(firstname='FN' + k , lastname='LN' + k , AccountId= acct.Id));
            }
        }        
        insert conList;     
    }
    public static List< Contact > createCustomerContacts( String recordType , List< Account > accList , Integer contactsPerAccount , Integer seq , Boolean isKeyContact ) {
        Integer accountCount = accList.size();
        Account acct;
        RecordType rt = [ SELECT Id FROM RecordType WHERE DeveloperName = :recordType AND SobjectType = 'Contact' ];
        
        List<Contact> conList = new List<Contact>();
        for ( Integer j=0 ; j <  accountCount ; j++ ) {
            acct = accList[ j ];                                    
            
            for (Integer k = contactsPerAccount * j ; k < contactsPerAccount *(j+1) ; k++) {
                conList.add(new Contact(firstname='FN' + (seq + k ) , lastname='LN' + ( seq + k ) , AccountId= acct.Id , recordTypeId = rt.id  , isKeyContact__c = isKeyContact , isContactActive__c = false));
            }
        }        
        insert conList;     
        return conList;
    }    
    
    public static void createOpportunities( List< Account > accList , Integer oppsPerAccount ) {
        Integer accountCount = accList.size();
        Account acct;
        
        List<Opportunity> oppList = new List<Opportunity>();
        for ( Integer j=0 ; j <  accountCount ; j++ ) {
            acct = accList[ j ];                                    
            
            for (Integer k = oppsPerAccount * j ; k < oppsPerAccount *(j+1) ; k++) {
                oppList.add(new Opportunity( name='Opp' + k , amount= 1000 + k , AccountId= acct.Id ,StageName = 'Unqualified Lead' , CloseDate = System.today() ));
            }
        }        
        insert oppList;     
    }
    public static void createBDOpportunities( List< Account > accList , Integer oppsPerAccount ) {
        Integer accountCount = accList.size();
        Account acct;
        RecordType rt = [ SELECT Id FROM RecordType WHERE DeveloperName = 'BD_Opportunity' ];
        List<Opportunity> oppList = new List<Opportunity>();
        for ( Integer j=0 ; j <  accountCount ; j++ ) {
            acct = accList[ j ];                                    
            
            for (Integer k = oppsPerAccount * j ; k < oppsPerAccount *(j+1) ; k++) {
                oppList.add(new Opportunity( name='Opp' + k , amount= 1000 + k , AccountId= acct.Id  , Initiative__c = 'Other' , 
                                            	StageName = 'Unqualified Lead' , CloseDate = System.today() , RecordTypeId = rt.id ));
            }
        }        
        insert oppList;     
    }    
    public static List< HierarchyConfig__c > createConfigs() {
    	List< StaticResource > resourceList = [ SELECT Body FROM StaticResource WHERE Name = 'HierarchyConfig' ];
    	StaticResource resource ;
        String fileData;
        String[] dataList, columnHeaderList , fileDataList; 
        List< SObject > objectConfigList = new List< HierarchyConfig__c >();        
        SObject config  ;
        
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects( new String[]{ 'HierarchyConfig__c' } ); 
        Map< String ,Schema.SObjectField > fieldMap  = results[0].fields.getMap();
        Schema.DescribeFieldResult fieldResult;                 
    	if( !resourceList.isEmpty() ) {    		
    		resource = resourceList.get( 0 );
    		fileData = resource.body.toString();
                
			fileDataList = fileData.split('\n') ;                
			columnHeaderList = fileDataList.get( 0 ).split(',');
                
			for( Integer i = 1; i< fileDataList.size() ; i++ ) {
				
            	dataList =  fileDataList[ i ].split(',');	   	
				config = new HierarchyConfig__c();				
				for( Integer j=0;j<columnHeaderList.size(); j++ ) {
					if( !columnHeaderList[ j ].equals( 'ParentId__r.ExternalId__c' )  ) {
						fieldResult = fieldMap.get( columnHeaderList[ j ].trim() ).getDescribe();
						if( fieldResult.getType().name() == 'BOOLEAN' ) {
							if( dataList[j] != '' ) {
							   config.put( columnHeaderList[ j ] , Boolean.valueOf( dataList[j] )) ;
							}	
						} else  {	 				
							config.put( columnHeaderList[ j ].trim() , dataList[j].replaceAll('[$]', ',') );
						}
					}					
				}
				objectConfigList.add( config );				
			}
			insert objectConfigList;																		                
    	}
    	createRelationships();
    	return ( List< HierarchyConfig__c > ) objectConfigList;     
    }
    public static void createRelationships() {
    	List< StaticResource > resourceList = [ SELECT Body FROM StaticResource WHERE Name = 'HierarchyConfig' ];
    	StaticResource resource ;
        String fileData;
        String[] dataList, columnHeaderList , fileDataList;                 
        SObject config , parentConfig;        
        List< SObject > objectConfigList = new List< HierarchyConfig__c >();
                
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects( new String[]{ 'HierarchyConfig__c' } ); 
        Map< String ,Schema.SObjectField > fieldMap  = results[0].fields.getMap();
        Schema.DescribeFieldResult fieldResult;
        
         
    	if( !resourceList.isEmpty() ) {
    		
    		resource = resourceList.get( 0 );
    		fileData = resource.body.toString();
                
			fileDataList = fileData.split('\n') ;                
			columnHeaderList = fileDataList.get( 0 ).split(',');
                
			for( Integer i = 1; i< fileDataList.size() ; i++ ) {				
            	dataList =  fileDataList[ i ].split(',');	   	
				config = new HierarchyConfig__c();				
				for( Integer j=0;j<columnHeaderList.size(); j++ ) {
					if( columnHeaderList[ j ].equals( 'ParentId__r.ExternalId__c' )  ) {
						if( dataList[j] != '' ) {
							parentConfig = new HierarchyConfig__c();
							parentConfig.put( 'ExternalId__c' , dataList[j].trim() );
							config.putSObject( 'ParentId__r' , parentConfig );							
							objectConfigList.add( config );
						}																	
					} else if( columnHeaderList[ j ].equals( 'ExternalId__c' ) ) {
						config.put( columnHeaderList[ j ].trim() , dataList[j] );
					} else {
                        fieldResult = fieldMap.get( columnHeaderList[ j ].trim() ).getDescribe();
						if( fieldResult.getType().name() == 'BOOLEAN' ) {
							if( dataList[j] != '' ) {
							   config.put( columnHeaderList[ j ] , Boolean.valueOf( dataList[j] )) ;
							}	
						} else  {	 				
							config.put( columnHeaderList[ j ].trim() , dataList[j].replaceAll('[$]', ',') );
						}                        
                    }					
				}								
			}
			Database.upsert( ( List<HierarchyConfig__c>) objectConfigList, fieldMap.get('ExternalId__c'),true) ;																		                
    	}    	
    }         
}