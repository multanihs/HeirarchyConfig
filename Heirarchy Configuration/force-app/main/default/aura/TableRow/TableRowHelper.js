({
	getData : function( fieldName , sobject ) {
		var fieldArray = fieldName.split('.');
        var length = fieldArray.length;
        //console.log( sobject  );
        //console.log(fieldArray.length + ' ' + fieldName);
        if( fieldArray.length == 1 ) {
            return sobject[ fieldName ];
        }
        for( var i=0;i<length;i++){
            sobject = sobject[ fieldArray[ i ] ];
            if(sobject == undefined){
            	return '';
            }
        }
        return sobject;
	}
})