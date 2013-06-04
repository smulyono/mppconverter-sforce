global with sharing class projectModel {
	public projectModel() {}

    /*
     * Holds the Project Model
     * @see me.smulyono.mppconverter.model.Project
     */
    global class Project {
        public String projectTitle {get;set;}
        public String publisher {get;set;}
        public List<projectModel.Resource> resources {get;set;}
        public List<projectModel.Task> tasks {get;set;}
        public List<projectModel.Assignment> assignments {get;set;}
        // custom field only in SFDC, to support UI feedback
        public Id generatedId {get;set;}

        public Project(){}
    }

    /*
     * Holds the Resource Model
     * @see me.smulyono.mppconverter.model.Resource
     */
    global class Resource {
        public String name {get;set;}
        public String type {get;set;}
        public Double stdRate {get;set;}
        public Integer id {get;set;}
        public Integer uniqueId {get;set;}
        public Resource(){}
    }

    /*
     * Holds the Task Model
     * @see me.smulyono.mppconverter.model.Task
     */
    global class Task {
        public String name {get;set;}
        public Integer id {get;set;}
        public Integer uniqueId {get;set;}
        public Boolean milestone {get;set;}
        public Boolean active {get;set;}
        public Decimal percentageComplete {get;set;}
        public Task(){}
    }

    /*
     * Holds the Assignment Model
     * @see me.smulyono.mppconverter.model.Assignment
     */
    global class Assignment {
        public Integer taskUniqueId {get;set;}
        public Integer taskId {get;set;}

        public Integer resourceUniqueId {get;set;}
        public Integer resourceId {get;set;}

        public Assignment(){}
    }
}