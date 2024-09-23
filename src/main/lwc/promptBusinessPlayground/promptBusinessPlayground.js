import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getModelResponse from '@salesforce/apex/PromptBusinessPlaygroundController.getModelResponse';


export default class PromptBusinessPlayground extends LightningElement {
    caseId;
    @track userPrompt;
    contextType;
    contextOptions;
    modelResponse;
    showSpinner = false;


    connectedCallback() {
        this.contextType = 'Full';
        this.contextOptions = [
            { label: 'Case with all Emails', value: 'Full' },
            { label: 'Case with today\'s Emails', value: 'Today' }
        ];
    }

    handleCaseIdChange(event) {
        this.caseId = event.target.value;
    }

    handleUserPromptChange(event) {
        this.userPrompt = event.target.value;
    }

    handleContextChange(event) {
        this.contextType = event.detail.value;
    }

    async getResponse() {
        this.showSpinner = true;
        try {
            this.modelResponse = await getModelResponse(
                {caseId: this.caseId, contextType: this.contextType, userPrompt: this.userPrompt});
        } catch (error) {
            this.showSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
        this.showSpinner = false;
    }

    get disableButton() {
        return !this.userPrompt || !this.caseId;
    }
}