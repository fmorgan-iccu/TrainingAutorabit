({
   identifyMember: function(component, event, helper) {
      // for Display Modal,set the "isOpen" attribute to "true"
      component.set("v.identifyMember", true);
       // TODO: Set either identifyingQuestions to true only if they don't have a passphrase
       // 		otherwise set passphraseIdentification to true
      component.set("v.passphraseIdentification", true);
   },
    
   identifyingQuestions: function(component, event, helper) {
      component.set("v.identifyingQuestions", true);
      component.set("v.passphraseIdentification", false);
   },
 
   walletQuestions: function(component, event, helper) {
      // for Display Modal,set the "isOpen" attribute to "true"
      component.set("v.walletQuestions", true);
      component.set("v.identifyingQuestions", false);
   },
    
   passphraseSetup: function(component, event, helper) {
      // for Display Modal,set the "isOpen" attribute to "true"
      component.set("v.walletQuestions", false);
      component.set("v.passphraseSetup", true);
   },
    
   closeModal: function(component, event, helper) {
      // for Hide/Close Modal,set the "isOpen" attribute to "Fasle"  
      component.set("v.identifyMember", false);
      // set all other variables set to false
      component.set("v.passphraseSetup", false);
      component.set("v.walletQuestions", false);
      component.set("v.identifyingQuestions", false);
   },
    
})