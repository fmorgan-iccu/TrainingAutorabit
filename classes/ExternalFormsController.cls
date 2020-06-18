public with sharing class ExternalFormsController {

    private static final List<Map<String, Object>> FORM_DEFINITIONS = new List<Map<String, Object>> {
        new Map<String, Object> {
            'id' => 'ach-dispute',
            'faIcon' => 'fa-comments-alt',
            'name' => 'ACH Dispute',
            'permission' => 'Form_ACH_Dispute',
            'tabAltText' => 'ACH Dispute Form',
            'tabIcon' => 'utility:edit_form',
            'tabLabel' => 'ACH Dispute',
            'tabComponentName' => 'c__CRMAchDisputeFormWrapper'
        },
        new Map<String, Object> {
            'id' => 'auto-payoff',
            'faIcon' => 'fa-car',
            'name' => 'Auto Payoff',
            'permission' => 'Form_Auto_Payoff',
            'tabAltText' => 'Auto Payoff Form',
            'tabIcon' => 'utility:edit_form',
            'tabLabel' => 'Auto Payoff',
            'tabComponentName' => 'c__CRMAutoPayoffFormWrapper'
        },
        new Map<String, Object> {
            'id' => 'gap-cancellation',
            'icon' => 'icon-gap-cancellation',
            'name' => 'GAP Cancellation',
            'permission' => 'Form_Gap_Cancellation',
            'tabAltText' => 'GAP Cancellation Form',
            'tabComponentName' => 'c__CRMGapCancellationFormWrapper',
            'tabIcon' => 'utility:edit_form',
            'tabLabel' => 'GAP Cancellation'
        },
        new Map<String, Object> {
            'id' => 'hot-card',
            'faIcon' => 'fa-credit-card',
            'name' => 'Hot Card',
            'permission' => 'Form_Hot_Card',
            'tabAltText' => 'Card Management',
            'tabIcon' => 'utility:edit_form',
            'tabLabel' => 'Card Management',
            'tabComponentName' => 'c__CRMHotCardFormWrapper'
        },
        new Map<String, Object> {
            'id' =>'skip-a-pay' ,
            'icon' => 'icon-skip-a-pay',
            'name' => 'Skip-a-Pay',
            'permission' => 'Form_Skip_A_Pay',
            'tabAltText' => 'Skip-a-Pay Form',
            'tabIcon' => 'utility:edit_form',
            'tabLabel' => 'Skip-a-Pay',
            'tabComponentName' => 'c__CRMSkipAPayFormWrapper'
        },
        new Map<String, Object> {
            'id' =>'subsequent-action' ,
            'icon' => 'icon-subsequent-action',
            'name' => 'Subsequent Action',
            'permission' => 'Form_Subsequent_Action',
            'tabAltText' => 'Subsequent Action',
            'tabIcon' => 'utility:edit_form',
            'tabLabel' => 'Subsequent Action',
            'tabComponentName' => 'c__CRMSubsequentActionFormWrapper'
        },
        new Map<String, Object> {
            'id' => 'title-release',
            'faIcon' => 'fa-file-export',
            'name' => 'Title Release',
            'permission' => 'Form_Title_Release',
            'tabAltText' => 'Title Release Form',
            'tabIcon' => 'utility:edit_form',
            'tabLabel' => 'Title Release',
            'tabComponentName' => 'c__CRMTitleReleaseFormWrapper'
        },
        new Map<String, Object> {
            'id' => 'travel-form',
            'faIcon' => 'fa-plane',
            'name' => 'Travel Form',
            'permission' => 'Form_Travel_Form',
            'tabAltText' => 'Travel Form',
            'tabIcon' => 'utility:edit_form',
            'tabLabel' => 'Travel Form',
            'tabComponentName' => 'c__CRMTravelFormWrapper'
        },
        new Map<String, Object> {
            'id' => 'visa-dispute',
            'icon' => 'icon-visa-dispute',
            'name' => 'VISA Dispute',
            'permission' => 'Form_Visa_Dispute',
            'tabAltText' => 'VISA Dispute',
            'tabIcon' => 'utility:edit_form',
            'tabLabel' => 'VISA Dispute',
            'tabComponentName' => 'c__CRMVisaDisputeWrapper'
        }
    };

    @AuraEnabled
    public static List<Map<String, Object>> getFormDefinitions(String formsToInclude) {
        // The forms to include argument is a CSV list of the requested forms.
        List<String> listOfFormsToInclude = formsToInclude.split(',');
        Set<String> formFilter = new Set<String>();
        formFilter.addAll(listOfFormsToInclude);
        if (formFilter.size() == 1 && formFilter.contains('all')) {
            formFilter.clear();
        }

        // Determine what forms the user has access to.
        Map<String, Boolean> permissions = ExternalFormsController.getFormPermissions();

        // Create a map that contains only the form defintions that the user has access to.
        List<Map<String, Object>> enabledForms = new List<Map<String, Object>>();
        for (Map<String, Object> formDef : ExternalFormsController.FORM_DEFINITIONS) {
            String formId = (String)formDef.get('id');
            Boolean isAllowed = permissions.get(formId);
            if (isAllowed && (formFilter.size() == 0 || formFilter.contains(formId))) {
                enabledForms.add(formDef);
            }
        }

        return enabledForms;
    }

    public static Boolean hasAccessToForms() {
        List<Map<String, Object>> formDefinitions = (List<Map<String, Object>>)ExternalFormsController.getFormDefinitions('all');
        Boolean hasAccess = formDefinitions.size() > 0;
        return hasAccess;
    }

    private static Map<String, Boolean> getFormPermissions() {
        Map<String, Boolean> permissions = new Map<String, Boolean>();
        for (Map<String, Object> formDef : ExternalFormsController.FORM_DEFINITIONS) {
            String formId = (String)formDef.get('id');
            String permissionName = (String)formDef.get('permission');
            Boolean isFormAllowed = AccessUtils.checkPermission(permissionName);
            permissions.put(formId, isFormAllowed);
        }

        return permissions;
    }

}