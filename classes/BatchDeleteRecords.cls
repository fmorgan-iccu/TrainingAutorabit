global class BatchDeleteRecords implements Database.Batchable<sObject>{

    private String query;
    
    global BatchDeleteRecords(String query) {
        this.query = query;    
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(this.query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        delete scope;
        DataBase.emptyRecycleBin(scope);
    }
    
    global void finish(Database.BatchableContext BC){
        
    }

}