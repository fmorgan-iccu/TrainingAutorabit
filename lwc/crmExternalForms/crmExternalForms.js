import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { deepClone } from 'c/crmObjectUtils';

import FONT_AWESOME_PRO from '@salesforce/resourceUrl/fontAwesomeProFont';
import ICCU_ICON_FONT from '@salesforce/resourceUrl/iccuIconFont';

import getFormDefinitions from '@salesforce/apex/ExternalFormsController.getFormDefinitions';

export default class CrmExternalForms extends LightningElement {

    @api contactId = null;
    @track error = null;
    @api forms = null;
    @track isLoaded = false;
    @track formDefinitions = [];

    connectedCallback() {
        loadStyle(this, FONT_AWESOME_PRO + '/css/all.min.css');
        loadStyle(this, ICCU_ICON_FONT + '/style.css');

        this.retrieveFormDefinitions();
    }

    @api refresh() {
        this.retrieveFormDefinitions();
    }

    retrieveFormDefinitions() {
        getFormDefinitions({ formsToInclude: this.forms }).then(result => {
            this.formDefinitions = deepClone(result);

            for (let formDef of this.formDefinitions) {
                formDef.useResouceIcon = !!formDef.icon;
                if (formDef.icon) {
                    formDef.classes = 'icon ' + formDef.icon;
                } else {
                    formDef.classes = 'icon fas ' + formDef.faIcon;
                }
            }
        }).catch(error => {
            if (error.body) {
                this.error = error.body.message;
            } else if (error.message) {
                this.error = error.message;
            } else {
                this.error = 'An unknown error occurred while trying to retrieve the available forms.';
            }
        }).finally(() => {
            this.isLoaded = true;
        });
    }

    get showComingSoon() {
        // Only show the coming soon section if all forms are requested.
        return this.forms === 'all';
    }

    get showError() {
        return !!this.error;
    }

    get showNoFormsAvaialble() {
        return this.formDefinitions.length == 0;
    }

    openForm(event) {
        // Identify the Id of the form that was clicked.
        let formId = null;
        let el = event.target;
        while (el != null) {
            if (el.hasAttribute('data-form-id')) {
                formId = el.getAttribute('data-form-id');
                break;
            }
            el = el.parentElement;
        }

        // Open the tab to the form.
        this.openNewTab(formId);
    }

    /**
     * Helper function to dispatch an event to the parent component.  This is needed until LWC gets the workspace API.
     */
    openNewTab(formId) {
        // Find the form definition...
        let targetFormTabDefinition = null;
        for (let formDef of this.formDefinitions) {
            if (formDef.id === formId) {
                targetFormTabDefinition = {
                    name: formDef.tabComponentName,
                    label: formDef.tabLabel,
                    icon: formDef.tabIcon,
                    altText: formDef.tabAltText
                };
                break;
            }
        }
        if (targetFormTabDefinition === null) {
            this.error = 'Unable to open the requested form. (not found)';
            return;
        }

        // Fire the even to the Aura wrapper to open the sub-tab.
        const openNewSubTabEvent = new CustomEvent('showsubtab', {
            detail: { 'tabDefinition': targetFormTabDefinition },
        });
        this.dispatchEvent(openNewSubTabEvent);
    }

}