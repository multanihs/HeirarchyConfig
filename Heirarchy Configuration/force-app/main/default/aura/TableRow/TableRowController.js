({
	doInit : function(component, event, helper) {
		var sobject = component.get("v.record");
		var config = component.get("v.config");
		//console.log( config );
		var fieldStr = config.fields__c;
		var fieldArray = fieldStr.split(',');
		//console.log( fieldArray.length + 'types ' + config.fieldTypes__c );
		var fieldTypeArray = config.fieldTypes__c.split(',');
		var dataArray = [];  
		for( var i=0; i< fieldArray.length;i++) {
			//console.log( fieldArray[ i ] + ' : ' + sobject[ fieldArray[ i ] ] );
			dataArray.push( { value : helper.getData( fieldArray[ i ] , sobject  ), type : fieldTypeArray[i] }  );			
		}		
		component.set('v.colValueArray', dataArray);
	}
})