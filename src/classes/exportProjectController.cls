global with sharing class exportProjectController {
    private Project__c recs;
    private ApexPages.standardController setting_controller;

    public exportProjectController(Apexpages.standardController stdController){
        this.setting_controller = stdController;
        this.recs = (Project__c) this.setting_controller.getRecord();
    }

    @RemoteAction
    global static projectModel.project buildJSON(String projectId){
    	   Project__c projectrec = [select id, name from Project__c where id = :projectId];
        projectModel.Project result = new projectModel.Project();
        result.projectTitle = projectrec.name;
        
        // query the Resource
        List<Resource__c> resourcesrec = [select id, name, standard_rate__c, type__c, unique_id__c
                                            from Resource__c
                                            where assignment__r.project__c = :projectId];
        List<projectModel.resource> newresources = new List<projectModel.resource>();
        for (Resource__c rec : resourcesrec){
        	   projectModel.resource newresource = new projectModel.resource();
        	   newresource.name = rec.name;
        	   newresource.type = rec.type__c;
        	   newresources.add(newresource);
        }
        result.resources = newresources;
        
        List<Task__c> tasksrec = [select id, name, milestone__c, active__c from Task__c where project__c = :projectId];
        List<projectModel.task> newtasks = new List<projectModel.task>();
        for (Task__c rec : tasksrec){
        	   projectModel.task newtask = new projectModel.task();
        	   newtask.name = rec.name;
        	   newtask.milestone = rec.milestone__c;
        	   newtask.active = rec.active__c;
        	   newtasks.add(newtask);
        }
        result.tasks = newtasks;
        return result;
    }

    @isTest
    static void testController(){
        Project__c newproject = new Project__c(name='new project');
        insert(newproject);
    
        Task__c newtask = new Task__c(name='task 1', active__c = true, milestone__c = true, project__c = newproject.id);
        insert(newtask);
        
        Assignment__c newassignment = new Assignment__c(project__c = newproject.id);
        insert(newassignment);
        
        Resource__c newresource = new Resource__c(name='resource-1', assignment__c = newassignment.id);
        insert(newresource);
    
        Apexpages.standardController ast = new Apexpages.standardController(newproject);
        Test.startTest();
        exportProjectController epc = new exportProjectController(ast);

        projectModel.project temp = exportProjectController.buildJSON(newproject.id);
        system.assert(temp != null);
        
        Test.stopTest();
    }
}