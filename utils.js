module.exports = {
  /*
  
    grab a container id from a url like:

      /v1.16/containers/123456/start
    
  */
  extractStartID:function(url){
    var id = url.replace(/^.*?\/containers\//, '');
    id = id.replace(/\/.*$/, '');
    return id;
  },


  /*
  
    extract the WEAVE_CIDR environment variable
    from the JSON response from `docker inspect 1234`
    
  */
  extractWeaveEnv:function(envVars){
    envVars = envVars || []

    var weaveVars = envVars.filter(function(envVar){
      return envVar.indexOf('WEAVE_CIDR=')==0;
    }).map(function(envVar){
      return envVar.split('=')[1];
    })

    return weaveVars[0];
  }
}