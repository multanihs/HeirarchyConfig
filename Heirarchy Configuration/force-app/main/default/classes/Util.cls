public with sharing class Util {
	
    public static String format( String str , String[] valueArray ) {
    	String pattern;
    	if( ( str == null ) || ( valueArray == null ) ) {
    		return '';
    	}
    	pattern = '([{][index][}])';
    	Integer length = valueArray.size();
    	for( Integer i=0;i<length;i++){
    		str = str.replaceAll( pattern.replace( 'index', ''+i ) ,  valueArray[ i ] );
    	}
    	return str;
    }
    public static Boolean isFieldPresent( String fieldName , String fieldList ) {
    	List< String > fields = new List< String >();    	    	
    	if( ( fieldList == null ) || ( fieldName == null )  ) {    			
    		return false;
    	}
    	fields = fieldList.split(',');
    	for( String fieldStr : fields ) {
    		if( fieldStr != null ) {
    			if( fieldStr.equals( fieldName)) 
    				return true;
    		}
    	}
    	return false;
    }
}