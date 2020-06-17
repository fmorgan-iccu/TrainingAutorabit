({  
    // call on load, check if user has active DNA ticket
    doInit: function(component, event, helper) {
        var isAuthenticatedAction = component.get("c.processIsAuthenticated");      
        $A.enqueueAction(isAuthenticatedAction);         
    },
    
    // pop the login modal
	openLogin: function(component, event, helper) {        
      	component.set("v.openLogin", true);
   	},
    
    // pop the offline modal
    openOffline: function(component, event, helper) {
        component.set("v.openOffline", true);
    },
    
    // show opted offline info
    optedOffline: function(component, event, helper) {
        helper.showError(component, '');

        var setOfflineAction = component.get("c.setOfflineMode");
        setOfflineAction.setParams({
            "isOffline": true
        });  
        setOfflineAction.setCallback(this, function(response) {            
            var state = response.getState();     

            if (component.isValid() && state === "SUCCESS") { 
                
                component.set("v.useOfflineMode", true);
                component.set("v.offlineMode", true);
                
            } else {
                console.log('Failed to set offline mode.');
            }                    
        });                
        $A.enqueueAction(setOfflineAction); 
                              
    },        
    
    // back to login
    backToLogin: function(component, event, helper) {
        component.set("v.useOfflineMode", false);
        component.set("v.offlineMode", false);
    },
    
    // close all modal windows
    closeModal: function(component, event, helper) {
        helper.showError(component, '');
        
        var offlineOpen = component.get("v.openOffline");
        if (offlineOpen === true) {
            component.set("v.offlineMode", true);
            component.set("v.openOffline", false);
        }
        component.set("v.openLogin", false);
        component.set("v.useOfflineMode", false);
    },
    
    // close on escape
    formPress: function(component, event, helper) {
        if (event.keyCode === 27) {
            var closeAction = component.get("c.closeModal");
            $A.enqueueAction(closeAction); 
        }
    },
    
    // destroy the DNA ticket
    processLogout: function(component, event, helper) {
        
    	var logoutAction = component.get("c.logout");
        
        logoutAction.setCallback(this, function(response) {            
            var state = response.getState();     

            if (component.isValid() && state === "SUCCESS") { 
                
                // check if user is authenticated to update the widget
        		var isAuthenticatedAction = component.get("c.processIsAuthenticated");      
                $A.enqueueAction(isAuthenticatedAction); 

                
            } else {
                console.log('Failed to logout?');
            }                    
        }); 

        $A.enqueueAction(logoutAction); 
    },
   
    // obtain a DNA ticket
   	processLogin: function(component, event, helper) {
        // clear out any old errors
        helper.showError(component, '');
        
        // get the credentials from the form
		var usernameInput = component.find("username");       
        var username = usernameInput.get("v.value");
                
		var passwordInput = component.find("password");
    	var password = passwordInput.get("v.value");
        
        var isMissingUsername = !username || username.length == 0;
        var isMissingPassword = !password || password.length == 0;
        
        if (isMissingUsername || isMissingPassword) {
            helper.showError(component, 'Please enter your username and password.');
            return;
        }

        helper.setIsLoading(component, true);
        
        var loginAction = component.get("c.authenticate");

        loginAction.setParams({
            "username": username,
            "password": password
        });        

        // call method async
        loginAction.setCallback(this, function(response) {
            helper.setIsLoading(component, false);
            var state = response.getState();     

            if (component.isValid() && state === "SUCCESS") { 

            	if (response.getReturnValue().didAuthenticate === true ) {
                        
            		// close modal
            		var closeModalAction = component.get("c.closeModal");      
                    $A.enqueueAction(closeModalAction); 
                                            			
            		// update component to show userAutheticated
            		var isAuthenticatedAction = component.get("c.processIsAuthenticated");      
			        $A.enqueueAction(isAuthenticatedAction); 
                    
                    // broadcast system login succesful
                    var myEvent = $A.get("e.c:DNACoreLogin");
                    myEvent.fire();               
                    
                    // setOfflineMode to false
                    var setOfflineAction = component.get("c.setOfflineMode");
                    setOfflineAction.setParams({
                        "isOffline": false
                    });  
                    setOfflineAction.setCallback(this, function(response) {            
                        var state = response.getState();     
            
                        if (component.isValid() && state === "SUCCESS") {                             
                            component.set("v.useOfflineMode", false);
                            component.set("v.offlineMode", false);
                            
                        } else {
                            console.log('Failed to set offline mode.');
                        }                    
                    });                
                    $A.enqueueAction(setOfflineAction); 
                    
            		 
            	} else {
                    helper.showError(component, response.getReturnValue().error); 
            	}                
            } else {
                helper.showError(component, 'Failed to connect to salesforce connector.'); 
            }                                  
        });       
 		
        // fire off the action
        $A.enqueueAction(loginAction);         
   	},
   
    // check if the user has a valid ticket for DNA calls
   	processIsAuthenticated: function(component, event, helper) {
		var isAuthenticatedAction = component.get("c.isAuthenticated"); 
        
        // call method async
        isAuthenticatedAction.setCallback(this, function(response) {            
            var state = response.getState();     

            if (component.isValid() && state === "SUCCESS") { 
              	component.set("v.isAuthenticated", response.getReturnValue());            			
            }                    
        });          
                
        $A.enqueueAction(isAuthenticatedAction);                
   	},  
    
    // on enterkey submit login 
    submitForm: function(component, event, helper) {
      	if(event.getParams().keyCode == 13){
        	var loginAction = component.get("c.processLogin");      
        	$A.enqueueAction(loginAction);   			                        			            
      	}        
    },
    
    // fire on event of authentication required
    handleRequireSystemOfRecordLogin: function(component, event, helper) {
       
       	// find out if the user has opted in to offline mode
        var isOptedOffline = null;
        var getOfflineStatusAction = component.get("c.isOfflineMode");
        getOfflineStatusAction.setCallback(this, function(response) {            
            var state = response.getState();     

            if (component.isValid() && state === "SUCCESS") { 
                
				isOptedOffline = response.getReturnValue();                              
                console.log('Offline mode is: ' + isOptedOffline);
            } else {
                console.log('Failed to get offline mode status.');
            }
            
            if (isOptedOffline === false) {
                var openModalAction = component.get("c.openLogin");      
                $A.enqueueAction(openModalAction);   
            }
            
        });                
        $A.enqueueAction(getOfflineStatusAction);        
                                      
    }
        
    
})