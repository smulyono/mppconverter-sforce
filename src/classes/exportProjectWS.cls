@RestResource(urlmapping='/exportproject')
global class exportProjectWS {
    @HttpGet
    global static projectModel.project convertProjectToJSON(){
        String projectId = RestContext.request.params.get('projectid');
        if (projectId != null){
            return exportProjectController.buildJSON(projectId);
        } else {
            return null;
        }
    }
}
