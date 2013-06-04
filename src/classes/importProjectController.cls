/*
 * Controller ImportProject Page
 *
 * Unit Test : Test_Project (83%)
 * @author : Sanny Mulyono <smulyono@me.com -- http://smulyono.github.io/>
 */
global with sharing class importProjectController {
    private ApexPages.StandardSetController setting_controller;

    public importProjectController(ApexPages.StandardSetController controller){
        this.setting_controller = controller;
    }

    @RemoteAction
    global static projectModel.project operateJSON(String rawJSON){
        projectModel.Project result = (projectModel.Project)JSON.deserialize(rawJSON, projectModel.Project.class);
        // do some synchronized result :: 4 DML call
        if (!Schema.SobjectType.Project__c.isCreateable() ||
            !Schema.Sobjecttype.Resource__c.isCreateable() ||
            !Schema.Sobjecttype.Task__c.isCreateable() ||
            !Schema.Sobjecttype.Milestone__c.isCreateable()){
            // just return the JSON without doing any DML call
            return result;
        }
        // Mark the savepoint here, since any failure in DML
        // it will have to rollback everything
        Savepoint sp = Database.setsavepoint();
        // Taking care the project
        Project__c newproject = new Project__c(
            name = result.projectTitle,
            author__c = result.publisher,
            raw_json__c =rawJSON
            );

        try {
            insert(newproject);
        } catch (DMLException ev){
            Database.rollback(sp);
            return result;
        }

        // Deal with Assignments
        // NOTE :: From the requirement, it requested that the assignments
        //      have one to many with project and one-to-one with Resource.
        //      This is different with the Project Schema in MPXJ
        //      (http://mpxj.sourceforge.net/howto-start.html).
        //      Also in microsoft project, we are allowed to assign multiple
        //      resources into one task; which the current requirement are not
        //      supported.
        List<Assignment__c> newassignments = new List<Assignment__c>();
        // Create the map to match task with resources, because of the different
        // project schmea in MPXJ, so for this requirement we only consider
        // one task can be assigned to only maximum one resource
        Map<Integer, Integer> map_taskuniqueid_resourceid = new Map<Integer, Integer>();
        // Create the map to match one assignment to one resource, based on the
        // schema given on the requirement then one resource relate to one assignment
        Map<Decimal, Id> map_resourceuniqueid_assignmentid = new Map<Decimal, Id>();
        for (projectModel.Assignment rec : result.assignments){
            Assignment__c newassignment = new Assignment__c(
                project__c = newproject.id,
                Resource_unique_ID__c = rec.resourceUniqueId
                );
            newassignments.add(newassignment);
            if (rec.taskUniqueId != null && rec.resourceUniqueId != null){
                map_taskuniqueid_resourceid.put(rec.taskUniqueId, rec.resourceUniqueId);
            }
        }
        if (newassignments.size() > 0){
            try {
                insert(newassignments);
                for (Assignment__c record : newassignments){
                    if (record.Resource_unique_ID__c != null){
                        map_resourceuniqueid_assignmentid.put(record.Resource_unique_ID__c, record.id);
                    }
                }
            } catch (DMLException ev){
                Database.rollback(sp);
                return result;
            }
        }

        // Deal with the resources
        List<Resource__c> newresources = new List<Resource__c>();
        for (projectModel.Resource rec : result.resources){
            if (map_resourceuniqueid_assignmentid.containsKey(rec.uniqueId)){
                Id assignmentid = map_resourceuniqueid_assignmentid.get(rec.uniqueId);
                Resource__c newresource = new Resource__c(
                    name = rec.name,
                    type__c = rec.type,
                    id__c = rec.id,
                    Unique_ID__c = rec.uniqueId,
                    Standard_Rate__c = rec.stdRate,
                    Assignment__c = assignmentid
                );
                newresources.add(newresource);
            }
        }

        if (newresources.size() > 0){
            try {
                insert(newresources);
            }catch (DMLException ev){
                Database.rollback(sp);
                return result;
            }
        }

        // Create map to hold the generated ID
        Map<Decimal, Id> mapresource_extid_id = new Map<Decimal, ID>();
        for (Resource__c record : newresources){
            mapresource_extid_id.put(record.Unique_ID__c,record.id);
        }

        // Deal with Tasks
        List<Task__c> newtasks = new List<Task__c>();
        // also deal with milestones
        // Assumptions :: put all task which is part of milestones into
        //                this custom object. There are no further description
        //                in the requirement.
        Boolean milestone_exists = false;
        for (projectModel.Task record : result.tasks){
            Task__c newtask = new Task__c(
                name = record.name,
                active__c = record.active,
                id__c = record.id,
                milestone__c = record.milestone,
                percentage_complete__c = record.percentageComplete,
                project__c = newproject.id,
                unique_id__c = record.uniqueId
                );
            if (map_taskuniqueid_resourceid.containsKey(record.uniqueId)){
                Integer resourceuniqueid = map_taskuniqueid_resourceid.get(record.uniqueId);
                if (mapresource_extid_id.containsKey(resourceUniqueId)){
                    newtask.resource__c = mapresource_extid_id.get(resourceUniqueId);
                }
            }
            newtasks.add(newtask);
            if (record.milestone != null && record.milestone){
                milestone_exists = true;
            }
        }

        // Do the Milestone and Task
        if (newtasks.size() > 0){
            try {
                insert(newtasks);
            } catch (DMLException ev){
                Database.rollback(sp);
                return result;
            }
            List<Milestone__c> newmilestones = new List<Milestone__c>();
            if (milestone_exists){
                for (Task__c record : newtasks){
                    if (record.milestone__c){
                        Milestone__c newmilestone = new Milestone__c(
                            name = record.name,
                            task__c = record.id,
                            project__c = newproject.id
                            );
                        newmilestones.add(newmilestone);
                    }
                }
            }
            if (newmilestones.size() > 0){
                try {
                    insert(newmilestones);
                } catch(DMLException ev){
                    Database.rollback(sp);
                    return result;
                }
            }
        }

        // Mark the complete process by passing the generated Project ID
        result.generatedId = newproject.id;
        return result;
    }

}