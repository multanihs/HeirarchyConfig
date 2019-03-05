declare module "@salesforce/apex/HierarchyController.getRelatedConfiguration" {
  export default function getRelatedConfiguration(param: {id: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/HierarchyController.getDetailRecord" {
  export default function getDetailRecord(param: {sobjType: any, id: any}): Promise<any>;
}
declare module "@salesforce/apex/HierarchyController.getSObjects" {
  export default function getSObjects(param: {configId: any, parentId: any, pageNum: any}): Promise<any>;
}
declare module "@salesforce/apex/HierarchyController.getParentConfigList" {
  export default function getParentConfigList(param: {pageNum: any}): Promise<any>;
}
