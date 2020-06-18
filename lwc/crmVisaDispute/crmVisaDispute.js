import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';

import fetchContact from '@salesforce/apex/ContactController.fetchContact';
import getAuthenticationInfo from '@salesforce/apex/AuthController.getAuthenticationInfo';
import getAccountWithTransactions from '@salesforce/apex/MemberAccountsController.getAccountWithTransactions';
import sendVisaUnauthorizedTransaction from '@salesforce/apex/ESignComponentController.sendVisaUnauthorizedTransaction';
import sendVisaRefundForSignature from '@salesforce/apex/ESignComponentController.sendVisaRefundForSignature';
import sendVisaPaidByOtherMeansForSignature from '@salesforce/apex/ESignComponentController.sendVisaPaidByOtherMeansForSignature';
import sendVisaOverchargeForSignature from '@salesforce/apex/ESignComponentController.sendVisaOverchargeForSignature';
import sendVisaMerchNotReceivedForSignature from '@salesforce/apex/ESignComponentController.sendVisaMerchNotReceivedForSignature';
import sendVisaMerchNotAsDescribedForSignature from '@salesforce/apex/ESignComponentController.sendVisaMerchNotAsDescribedForSignature';
import sendVisaMembershipCancelledForSignature from '@salesforce/apex/ESignComponentController.sendVisaMembershipCancelledForSignature';
import sendVisaFundsNotReceivedForSignature from '@salesforce/apex/ESignComponentController.sendVisaFundsNotReceivedForSignature';
import sendVisaDuplicateProcessingForSignature from '@salesforce/apex/ESignComponentController.sendVisaDuplicateProcessingForSignature';
import fetchCardData from '@salesforce/apex/MemberCardController.fetchCardData';
import updateCardStatuses from '@salesforce/apex/MemberCardController.updateCardStatuses';

import momentJs from '@salesforce/resourceUrl/MomentJS';
import numeralJs from '@salesforce/resourceUrl/NumeralJS';
import Illustrations from '@salesforce/resourceUrl/Illustrations';


const transactionsPerPage = 15;
const USER_FRIENDLY_STATUS_WAITING_ACTIVATION  = 'Waiting Activation';

export default class CrmVisaDispute extends LightningElement {
    @track accountSelected = false;
    certifications = [
        {'certification' : 'Member has been provided the ‘Understanding Your Visa Dispute’ flyer'},
        {'certification' : 'Member acknowledges that provisional credit may be received within 10 business days subject to the result/or length of the investigation'},
    ];
    @track complete = false;
    contact = {};
    @track contactedCompany = null;
    @track showMerchantContactError = false;
    @api contactid = null;
    @track disableNext = true;
    @track disputeReason;
    @track disputeReasonError = false;
    disputeReasonErrorTitle = 'Cannot Select Multiple Transactions';
    disputeReasonErrorMessage = 'You can only dispute one transaction at a time. Please go back to transaction selection and choose only one.';
    @track disputeDueTo;
    @track error = '';
    @track filterTransactions = true; // filter transactions that can be disputed via Visa dispute but allow user to look through all transactions
    @track isDisabled = false;
    @track isLoading = true;
    @track isSaving = false;
    merchDescription = 'Provide a description of the merchandise/services ordered.';
    @track numberSelectedTransactions = 0;
    @track policeReport = false;
    @track returnRequired = false;
    @track selectedTransactions = [];
    @track showPaymentInfoLabel = false;
    successImage = Illustrations + '/card-off-and-form-to-docusign.png';
    successMessage = "The VISA dispute form was created successfully and is on its way to docusign to collect the members signature.";
    @track transactionSelected = false;
    @track transactions = [];
    cards = [];
    account = {};
    @track hideBack = true;
    @track hideNext = false;
    @track hideNextTransaction = false;
    @track hideBackTransaction = true;
    successImage = Illustrations + '/form-to-docusign.png';
    @track displayTransactions = [];
    @track startDate = null;
    @track endDate = null;
    @track currentPage = 0;
    @track numberOfPages = 1;
    @track pages = [];
    @track minAmount = null;
    @track maxAmount = null;
    @track filterDescription = null;
    @track disableSubmit = true;
    @track missingEmail = false;
    @track hasSelectedCard = false;
    @track stateOfResidency;
    @track cardStatus = '';
    @track selectedCard = {};
    @track transList = [];
    @track lossDiscoveredDate;
    @track today = new Date();
    @track authorityName = '';
    @track reportNumber;
    @track authorityPhone;
    @track unauthorizedUserName = '';
    @track unauthorizedUserLine1Address;
    @track unauthorizedUserLine2Address;
    @track selectedCardLastFour = '';
    @track amountRequested = '';
    @track amountReceived = '';
    @track refundAcknowledged;
    @track merchantDate;
    @track merchantRepName = '';
    @track merchantContactMethod = '';
    @track merchantResponse = '';
    @track refundReturnDate;
    @track returnMethod;
    @track expectedDeliveryDate;
    @track insuranceScheme;
    @track shippedWrong;
    @track returnedMerchandise;
    @track merchReason = '';
    @track negotiations;
    @track negotiationDescription = '';
    @track merchReturn;
    @track returnMethod = '';
    @track overchargedAmount;
    @track paymentType = '';
    @track paymentTypeCheck = '';
    @track paymentTypeACH = '';
    @track paymentTypeCard = '';
    @track cancellationType = '';
    @track recurringTransaction;
    @track cancellationDate;
    @track cancellationNumber = '';
    @track cancellationReason = '';
    @track cardUniqueId;
    @track refundNotes = '';

    connectedCallback() {
        this.getContact(this.contactid);
        Promise.all([
            loadScript(this, momentJs),
            loadScript(this, numeralJs)
        ]);
    }

    checkAuthenticationRequired(requiredSystem) {
        // If authentication is required, dispatch the necessary events for the login
        // component to be displayed.
        if (requiredSystem === 'DNA') {
            let systems = ['cCRMDnaLogin'];
            const requireLoginEvent = new CustomEvent('requirelogin', {
                detail: { systems },
            });
            this.dispatchEvent(requireLoginEvent);
        }
        if (requiredSystem === 'CCM') {
            let systems = ['cCRMCcmLogin'];
            const requireLoginEvent = new CustomEvent('requirelogin', {
                detail: { systems },
            });
            this.dispatchEvent(requireLoginEvent);
        }
    }

    get atmFundsDispute() {
        return this.disputeReason === 'atm funds';
    }

    get cardStatusOptions() {
        return [
            { label: 'Lost', value: 'LOST'},
            { label: 'Stolen', value: 'STLN'},
            { label: 'In Possession', value: 'CCLS'}
        ];
    }

    get cancellationTypeRadio() {
        return [
            { label: 'Merchandise', value: 'merchandise'},
            { label: 'Service', value: 'service'},
            { label: 'Membership', value: 'membership'}
        ];
    }

    get yesNoRadio() {
        return [
            { label: 'Yes', value: 'yes' },
            { label: 'No', value: 'no' }
        ];
    }

    cancelAction() {
        let cardSelectComponent = this.template.querySelector('c-crm-card-select');
        if (cardSelectComponent) {
            cardSelectComponent.handleDeselectCard();
        }
    }

    handleStateOfResidency(event) {
        if (event.detail.value === 'yes') {
            this.stateOfResidency = true;
        } else {
            this.stateOfResidency = false;
        }
    }

    handleRecurringTransaction(event) {
        if (event.detail.value === 'yes') {
            this.recurringTransaction = true;
        } else {
            this.recurringTransaction = false;
        }
    }

    handleVoucher(event) {
        if (event.detail.value === 'yes') {
            this.refundAcknowledged = true;
        } else {
            this.refundAcknowledged = false;
        }
    }

    handleInsuranceScheme(event) {
        if (event.detail.value === 'yes') {
            this.insuranceScheme = true;
        } else {
            this.insuranceScheme = false;
        }
    }

    handleMerchReturn(event) {
        if (event.detail.value === 'yes') {
            this.merchReturn = true;
        } else {
            this.merchReturn = false;
        }
    }

    handleShippedWrong(event) {
        if (event.detail.value === 'yes') {
            this.shippedWrong = true;
        } else {
            this.shippedWrong = false;
        }
    }

    handleReturnedMerchandise(event) {
        if (event.detail.value === 'yes') {
            this.returnedMerchandise = true;
        } else {
            this.returnedMerchandise = false;
        }
    }

    handleNegotiations(event) {
        if (event.detail.value === 'yes') {
            this.negotiations = true;
        } else {
            this.negotiations = false;
        }
    }

    handleCancellationReason(event) {
        this.cancellationReason = event.detail.value;
    }
    handleCancellationType(event) {
        this.cancellationType = event.detail.value;
    }

    handleCancellationNumber(event) {
        this.cancellationNumber = event.detail.value;
    }

    handleCancellationDate(event) {
        this.cancellationDate = event.detail.value;
    }

    handlePaymentCheck(event) {
        this.paymentTypeCheck = event.detail.value;
    }

    handleRefundNotes(event) {
        this.refundNotes = event.detail.value;
    }

    handlePaymentACH(event) {
        this.paymentTypeACH = event.detail.value;
    }

    handlePaymentCard(event) {
        this.paymentTypeCard = event.detail.value;
    }

    handleOverchargedAmount(event) {
        this.overchargedAmount = event.detail.value;
    }

    handleNegotiationsDescription(event) {
        this.negotiationDescription = event.detail.value;
    }

    handleReturnMethod(event) {
        this.returnMethod = event.detail.value;
    }

    handleMerchReason(event) {
        this.merchReason = event.detail.value;
    }

    handleExpectedDeliveryDate(event) {
        this.expectedDeliveryDate = event.detail.value;
    }

    handleProductDescription(event) {
        this.productDescription = event.detail.value;
    }

    handleMerchantDate(event) {
        this.merchantDate = event.detail.value;
    }

    handleMerchantRepName(event) {
        this.merchantRepName = event.detail.value;
    }

    handleMerchantContactMethod(event) {
        this.merchantContactMethod = event.detail.value;
    }

    handleMerchantResponse(event) {
        this.merchantResponse = event.detail.value;
    }

    handleRefundReturnDate(event) {
        this.refundReturnDate = event.detail.value;
    }

    handleReturnMethod(event) {
        this.returnMethod = event.detail.value;
    }

    handleLossDiscoveredDate(event) {
        this.lossDiscoveredDate = event.detail.value;
    }

    handleAuthorityName(event) {
        this.authorityName = event.detail.value;
    }

    handleReportNumber(event) {
        this.reportNumber = event.detail.value;
    }

    handleAuthorityPhone(event) {
        this.authorityPhone = event.detail.value;
    }

    handleUnauthorizedUserName(event) {
        this.unauthorizedUserName = event.detail.value;
    }

    handleUnauthorizedUserLine1Address(event) {
        this.unauthorizedUserLine1Address = event.detail.value;
    }

    handleUnauthorizedUserLine2Address(event) {
        this.unauthorizedUserLine2Address = event.detail.value;
    }

    handleAmountRequested(event) {
        this.amountRequested = event.detail.value;
    }

    handleAmountReceived(event) {
        this.amountReceived = event.detail.value;
    }

    get disputeReasons() {
        if (this.selectedTransactions.every(this.isDuplicate)) {
            return [
                { label: 'Unauthorized', value: 'unauthorized'},
                { label: 'Did not receive funds from ATM', value: 'atm funds'},
                { label: 'Refund not Processed', value: 'refund'},
                { label: 'Merchandise / Services not Received', value: 'not received'},
                { label: 'Merchandise / Service not as Described', value: 'not as described'},
                { label: 'Overcharged', value: 'overcharged'},
                { label: 'Paid by Other Means', value: 'other means'},
                { label: 'Cancelled Merchandise/Services', value: 'cancelled'},
                { label: 'Duplicate Processing', value: 'duplicate'}
            ];
        } else {
            return [
                { label: 'Unauthorized', value: 'unauthorized'},
                { label: 'Did not receive funds from ATM', value: 'atm funds'},
                { label: 'Refund not Processed', value: 'refund'},
                { label: 'Merchandise / Services not Received', value: 'not received'},
                { label: 'Merchandise / Service not as Described', value: 'not as described'},
                { label: 'Overcharged', value: 'overcharged'},
                { label: 'Paid by Other Means', value: 'other means'},
                { label: 'Cancelled Merchandise/Services', value: 'cancelled'},
            ];
        }
    }

    get disputeDueToReasons() {
        return [
            { label: 'Counterfeit Merchandise', value: 'Counterfeit Merchandise'},
            { label: 'Damaged/Defective Merchandise', value: 'Damaged/Defective Merchandise'},
            { label: 'Misrepresentation/Not as Described', value: 'Misrepresentation/Not as Described'},
            { label: 'Quality Issues', value: 'Quality Issues'}
        ];
    }

    get duplicateProcessing() {
        return this.disputeReason === 'duplicate';
    }

    get membershipCancelled() {
        return this.disputeReason === 'cancelled';
    }

    get merchantContact() {
        return this.disputeReason === 'duplicate' || this.disputeReason === 'cancelled' || this.disputeReason === 'overcharged' || this.disputeReason === 'not received' || this.disputeReason === 'refund' || this.disputeReason === 'other means' || this.disputeReason ===  'not as described';
    }

    get merchNotReceived() {
        return this.disputeReason === 'not received';
    }

    get overcharged() {
        return this.disputeReason === 'overcharged';
    }

    get paidByOtherMeans() {
        return this.disputeReason === 'other means';
    }

    get paymentTypeOptions() {
        return [
            { label: 'Check', value: 'Check'},
            { label: 'ACH', value: 'ACH'},
            { label: 'Another Card', value: 'Card'},
            { label: 'Cash', value: 'Cash'}
        ];
    }

    get showCheck() {
        return this.paymentType === 'Check';
    }

    get showACH() {
        return this.paymentType === 'ACH';
    }

    get showCard() {
        return this.paymentType === 'Card';
    }

    get merchantContactOptions() {
        return [
            { label: 'Phone', value: 'Phone'},
            { label: 'Email', value: 'Email'},
            { label: 'In Person', value: 'In Person'}
        ];
    }

    get refundNotProcessed() {
        return this.disputeReason === 'refund';
    }

    get returnMethods() {
        return [
            { label: 'DHL', value: 'DHL'},
            { label: 'Face to Face', value: 'In Person'},
            { label: 'FedEx', value: 'FedEx'},
            { label: 'UPS', value: 'UPS'},
            { label: 'USPS', value: 'USPS'},
            { label: 'Attempted', value: 'Attempted'}
        ];
    }

    get returnOptions() {
        return [
            { label: 'Yes', value: 'yes'},
            { label: 'No', value: 'no'}
        ];
    }

    get showError() {
        return this.error && this.error !== '';
    }

    get notAsDescribed() {
        return this.disputeReason === 'not as described';
    }

    get transactionSelection() {
        return (this.accountSelected == true && this.transactionSelected == false);
    }

    get unauthorized() {
        return this.disputeReason === 'unauthorized';
    }

    clickBack() {
        this.transactionSelected = false;
        this.accountSelected = true;
        this.isLoading = true;
        this.error = null;
        this.disableNext = true;
        this.hideBack = true;
        this.hideNext = false;
        this.selectedTransactions = [];
        this.numberSelectedTransactions = 0;
        this.disableSubmit = true;
        this.minAmount = null;
        this.maxAmount = null;
        this.filterDescription = null;
        this.cards = [];
        this.disputeReason = '';
        this.getTransactions(this.contactid, this.account.accountNumber, null, null);
    }

    clickNext() {
        this.transactionSelected = true;
            for (let trans of this.selectedTransactions) {
                if (trans.postDate) {
                    trans.postDate = moment(trans.postDate).format('M/D/YYYY');
                }
                if (trans.amount) {
                    trans.amount = numeral(trans.amount).format('$0,000.00').toString();
                }
                let formattedTrans = {
                    "merchant": trans.shortDescription,
                    "date": trans.postDate,
                    "amount": trans.amount
                }
                this.transList.push(formattedTrans);
            }
        this.getCardData();
        this.today = moment(this.today).format('M/D/YYYY');
    }

    contactedCompanyChange(event) {
        if (event.detail.value === 'yes') {
            this.showMerchantContactError = false;
            this.contactedCompany = true;
            this.isLoading = true;
        } else {
            this.showMerchantContactError = true;
            this.contactedCompany = false;
        }
    }

    handleAccountChange() {
        // Determine who the tax owner for the account and retrieve their information.
        this.accountSelected = false;
        this.error = null;
        let accountLookupComp = this.template.querySelector('c-crm-account-lookup');
        this.account = accountLookupComp.getSelectedAccount();
        if (this.account) {
            this.isLoading = true;
            this.accountSelected = true;
            this.getTransactions(this.contactid, this.account.accountNumber, this.startDate, this.endDate);
        }
    }

    handleTransactionClick(event) {
        let transactionNumber = event.detail.transactionNumber;
        let selected = event.detail.selected;
        if (this.selectedTransactions.length > 0) {
            for (let t of this.selectedTransactions) {
                if (t.transactionNumber == transactionNumber) {
                    if (selected == false) {
                        this.selectedTransactions.splice(this.selectedTransactions.indexOf(t), 1);
                    }
                }
            }
        }
        for (let trans of this.transactions) {
            if (trans.transactionNumber == transactionNumber && selected == true) {
                this.selectedTransactions.push(trans);
                break;
            }
        }
        if (this.selectedTransactions.length > 0) {
            this.disableNext = false;
            this.numberSelectedTransactions = this.selectedTransactions.length;
        } else {
            this.disableNext = true;
            this.numberSelectedTransactions = 0;
        }
    }

    handleTransactionSearch() {
        if (this.transactions.length > 0) {
            for (let trans of this.transactions) {
                    trans.isDisabled = false;
                    continue;
            }
        }
        let transactionSearchLookupComp = this.template.querySelector('c-crm-transaction-search');
        if (transactionSearchLookupComp.getStartDate() != null || transactionSearchLookupComp.getEndDate() != null) {
            this.isLoading = true;
            this.startDate = transactionSearchLookupComp.getStartDate();
            this.endDate = transactionSearchLookupComp.getEndDate();
            this.getTransactions(this.contactid, this.account.accountNumber, this.startDate, this.endDate);
        }
        if (transactionSearchLookupComp.getAmountMin() != null) {
            this.minAmount = transactionSearchLookupComp.getAmountMin();
        }
        if (transactionSearchLookupComp.getAmountMax() != null) {
            this.maxAmount = transactionSearchLookupComp.getAmountMax();
        }
        if (transactionSearchLookupComp.getDescription() != null) {
            this.filterDescription = transactionSearchLookupComp.getDescription();
        }
        this.setDisplayTransactions();
    }

    filterByAmount(min, max) {
        if (this.transactions) {
            for (let trans of this.transactions) {
                if (Math.abs(trans.amount) < min || Math.abs(trans.amount) > max) {
                    trans.isDisabled = true;
                    continue;
                }
            }
        }
    }

    filterByDescription(description) {
        if (this.transactions) {
            for (let trans of this.transactions) {
                if (!trans.longDescription.toLowerCase().includes(description.toLowerCase())) {
                    trans.isDisabled = true;
                    continue;
                }
            }
        }
    }

    disputeReasonSelected(event) {
        this.disputeReason = event.detail.value;
        this.disableSubmit = false;
        if ((this.disputeReason === 'overcharged' || this.disputeReason === 'atm funds') && this.selectedTransactions.length != 1) {
            this.setError('Only one transaction can be selected for this dispute type.');
            this.disableSubmit = true;
        }
    }

    disputeDueToReasonChange(event) {
        this.disputeDueTo = event.detail.value;
        switch(this.disputeDueTo) {
            case 'Counterfeit Merchandise':
                this.returnRequired = false;
                break;
            case 'Damaged/Defective Merchandise':
                this.returnRequired = true;
                break;
            case 'Misrepresentation/Not as Described':
                this.returnRequired = false;
                break;
            case 'Quality Issues':
                this.returnRequired = false;
                break;
            default:
                break;
        }
    }

    getContact(id) {
        fetchContact({ contactId: id }).then(result => {
            let fetchedContact = result ? result : {};
            if (fetchedContact) {
                this.contact = fetchedContact;
                    if (!this.contact.Email) {
                        this.missingEmail = true;
                    }
            } else {
                this.setError('Unable to retrieve the contact.');
                this.isDisabled = true;
            }

            // Chain a call to get the user's information
            return getAuthenticationInfo({});
        }).catch(error => {
            if (error.body) {
                this.setError(error.body.message);
            } else if (error.message) {
                this.setError(error.message);
            } else {
                this.setError('An unknown error occurred while trying to retrieve the contacts cards.');
            }

            this.isDisabled = true;
        }).finally(() => {
            this.isLoading = false;
        });
    }

    setDisplayTransactions() {
        let startIndex = this.currentPage * transactionsPerPage;
        let endIndex = startIndex + transactionsPerPage;

        if (this.minAmount != null && this.maxAmount != null) {
            this.filterByAmount(this.minAmount, this.maxAmount);
        }
        if (this.filterDescription != null) {
            this.filterByDescription(this.filterDescription);
        }
        let filteredTransactions = [];
        for (let trans of this.transactions) {
            if (!trans.isDisabled) {
                filteredTransactions.push(trans);
            }
        }
        if (endIndex > filteredTransactions.count - 1) {
            endIndex = filteredTransactions.count - 1;
        }

        this.displayTransactions = filteredTransactions.slice(startIndex, endIndex);
        this.updatePages(filteredTransactions);
        if (this.numberOfPages == 1 || this.numberOfPages == 0) {
            this.hideNextTransaction = true;
            this.hideBackTransaction = true;
        } else {
            this.hideNextTransaction = false;
        }
    }

    handleNextClicked(event) {
        this.currentPage = this.currentPage + 1;
        this.setDisplayTransactions();
        if (this.currentPage == this.numberOfPages - 1) {
            this.hideNextTransaction = true;
        }
        if (this.currentPage != 0) {
            this.hideBackTransaction = false;
        }
    }

    handleBackClicked(event) {
        this.currentPage = this.currentPage - 1;
        this.setDisplayTransactions();
        if (this.currentPage == 0) {
            this.hideBackTransaction = true;
        }
    }

    updatePages(transactions) {
        let count = transactions.length;
        let pages = Math.ceil(count / transactionsPerPage);
        this.numberOfPages = pages;
    }

    showAllTransactions() {
        this.filterTransactions = false;

        if (this.account.accountType === 'creditcard') {
            if (this.transactions) {
                for (let trans of this.transactions) {
                    if (trans.externalDescription.substring(0, 8) !== 'Purchase') {
                        trans.isDisabled = false;
                        trans.visaDisabled = true;
                        continue;
                    } else {
                        trans.visaDisabled = false;
                    }
                }
                this.setDisplayTransactions();
            }
        }
        if (this.account.accountType === 'deposit') {
            if (this.transactions) {
                for (let trans of this.transactions) {
                    if (trans.typeCode !== 'PWTH') {
                        trans.isDisabled = false;
                        trans.visaDisabled = true;
                        continue;
                    } else {
                        trans.visaDisabled = false;
                    }
                }
                this.setDisplayTransactions();
            }
        }
    }

    showFilteredTransactions() {
        this.filterTransactions = true;
        this.currentPage = 0;

        if (this.account.accountType === 'creditcard') {
            if (this.transactions) {
                for (let trans of this.transactions) {
                    if (trans.externalDescription.substring(0, 8) !== 'Purchase') {
                        trans.isDisabled = true;
                        continue;
                    } else {
                        trans.isDisabled = false;
                    }
                }
                this.setDisplayTransactions();
            }
        }
        if (this.account.accountType === 'deposit') {
            if (this.transactions) {
                for (let trans of this.transactions) {
                    if (trans.typeCode !== 'PWTH') {
                        trans.isDisabled = true;
                        continue;
                    } else {
                        trans.isDisabled = false;
                    }
                }
                this.setDisplayTransactions();
            }
        }
    }

    getTransactions(contactId, accountNumber, startDate, endDate) {
        getAccountWithTransactions({ recordId: contactId, accountNumber: accountNumber, startDate: startDate, endDate: endDate }).then(result => {
            this.transactions = result.transactions ? result.transactions : {};
            if (this.transactions) {
                this.showFilteredTransactions();
            }
        }).catch(error => {
            if (error.body) {
                this.setError(error.body.message);
            } else if (error.message) {
                this.setError(error.message);
            } else {
                this.setError('An unknown error occurred while trying to retrieve the ach transactions.');
            }

            this.isDisabled = true;
        }).finally(() => {
            this.isLoading = false;
        });
    }

    handleCardStatus(event) {
        this.cardStatus = event.detail.value;
    }

    handleAccountError(event) {
        let message = event.detail;
        this.setError(message);
    }

    handleAccountsLoaded() {
        this.isLoading = false;
    }

    isDuplicate(el,index,arr) {
        if (index === 0){
            return true;
        }
        else {
            return ((el.amount === arr[index - 1].amount) && (el.merchant === arr[index - 1].merchant));

        }
    }

    paymentTypeChange(event) {
        this.paymentType = event.detail.value;
    }

    reportedPdChange(event) {
        if (event.detail.value === 'yes') {
            this.policeReport = true;
        } else {
            this.policeReport = false;
        }
    }

    setError(error) {
        this.error = error;
        this.isLoading = false;
        this.isSaving = false;
        if (error !== '' && error != null) {
            this.showErrorToast();
        }
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error',
            message: 'Oops! Something went wrong and an error has occured. ',
            variant: 'error'
        });
        this.dispatchEvent(event);
    }

    // get card information
    getCardData() {
        this.isLoading = true;
        fetchCardData({ contactId: this.contactid }).then(result => {
            if (result.error) {
                this.error = result.error;
            }
            if(result.debit) {
                for (let card of result.debit) {
                    if (card.accountNumber === this.account.accountNumber && card.userFriendlyStatus !== USER_FRIENDLY_STATUS_WAITING_ACTIVATION  && this.account.accountType === 'deposit') {
                        this.cards.push(card);
                    }
                }
            }
            if (result.credit) {
                for (let card of result.credit) {
                    if (card.userFriendlyStatus !== USER_FRIENDLY_STATUS_WAITING_ACTIVATION && this.account.accountType === 'creditcard') {
                        this.cards.push(card);
                    }
                }
            }
            this.renderCards();
            this.checkAuthenticationRequired(result.authRequired);
        }).catch(error => {
            if (error.body) {
                this.error = error.body.message;
            } else if (error.message) {
                this.error = error.message;
            } else {
                this.error = 'An unknown error occurred while trying to retrieve the contacts cards.';
            }
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    renderCards() {
        let cardSelectComponent = this.template.querySelector('c-crm-card-select');
        if (cardSelectComponent && this.cards) {
            cardSelectComponent.setCards(this.cards);
        }
    }

    // Resets the state of card selection and updates the various vars to update the UI.
    handleCardSelect() {
        let card = this.getSelectedCard();
        let hasSelectedCard = false;

        if (card) {
            hasSelectedCard = true;
            this.selectedCardLastFour = card.cardNumber.substr(card.cardNumber.length - 4);
            this.cardUniqueId = card.uniqueId;
        }

        this.hasSelectedCard = hasSelectedCard;
    }

    getSelectedCard() {
        let cardSelectComponent = this.template.querySelector('c-crm-card-select');
        if (cardSelectComponent) {
            let card = cardSelectComponent.getSelectedCard();
            this.selectedCard = card;
            return card;
        }

        return null;
    }

    handleSubmitForm() {
        this.error = null;
        this.isSaving = true;

        // Handle the completion screen graphics
        if (this.disputeReason === 'unauthorized') {
            this.successMessage = "The VISA dispute form was created successfully and the members card has been turned off. The documents have been sent to docusign to collect the members signature."
            this.successImage = Illustrations + '/card-off-and-form-to-docusign.png';
            this.certifications = [
                {'certification' : 'Member did not authorize the listed transactions'},
                {'certification' : 'Member has been provided the ‘Understanding Your Visa Dispute’ flyer'},
                {'certification' : 'Member acknowledges that provisional credit may be received within 10 business days subject to the result/or length of the investigation'},
            ]
        } else {
            this.successMessage = "The VISA dispute form was created successfully and is on its way to docusign to collect the members signature."
            this.successImage = Illustrations + '/form-to-docusign.png';
            switch(this.disputeReason) {
                case 'atm funds':
                    this.certifications = [
                        {'certification' : 'Member authorized the transaction(s)'},
                        {'certification' : 'Member has been provided the ‘Understanding Your Visa Dispute’ flyer'},
                        {'certification' : 'Member acknowledges that provisional credit may be received within 10 business days subject to the result/or length of the investigation'},
                    ];
                    break;
                case 'refund':
                    this.certifications = [
                        {'certification' : 'Member authorized the transaction(s)'},
                        {'certification' : 'Member certifies the refund in question was not processed'},
                        {'certification' : 'Member contacted stated merchant regarding this dispute but remains unresolved'},
                        {'certification' : 'Member has returned the merchandise to merchant'},
                        {'certification' : 'Member has been provided the ‘Understanding Your Visa Dispute’ flyer'},
                        {'certification' : 'Member acknowledges that provisional credit may be received within 10 business days subject to the result/or length of the investigation'},
                    ];
                    break;
                case 'not received':
                    this.certifications = [
                        {'certification' : 'Member authorized the transaction(s)'},
                        {'certification' : 'Member certifies merchandise/service was not received on the expected delivery date'},
                        {'certification' : 'Member contacted stated merchant regarding this dispute but remains unresolved'},
                        {'certification' : 'Member has been provided the ‘Understanding Your Visa Dispute’ flyer'},
                        {'certification' : 'Member acknowledges that provisional credit may be received within 10 business days subject to the result/or length of the investigation'},
                    ];
                    break;
                case 'not as described':
                    this.certifications = [
                        {'certification' : 'Member authorized the transaction(s)'},
                        {'certification' : 'Member contacted stated merchant regarding this dispute but remains unresolved'},
                        {'certification' : 'Member has been provided the ‘Understanding Your Visa Dispute’ flyer'},
                        {'certification' : 'Member acknowledges that provisional credit may be received within 10 business days subject to the result/or length of the investigation'},
                    ];
                    break;
                case 'overcharged':
                    this.certifications = [
                        {'certification' : 'Member authorized the transaction(s)'},
                        {'certification' : 'Member was overcharged for the purchase(s)'},
                        {'certification' : 'Member contacted stated merchant regarding this dispute but remains unresolved'},
                        {'certification' : 'Member has been provided the ‘Understanding Your Visa Dispute’ flyer'},
                        {'certification' : 'Member acknowledges that provisional credit may be received within 10 business days subject to the result/or length of the investigation'},
                    ];
                    break;
                case 'other means':
                    this.certifications = [
                        {'certification' : 'Member authorized the transaction(s)'},
                        {'certification' : 'Member contacted stated merchant regarding this dispute but remains unresolved'},
                        {'certification' : 'Member has been provided the ‘Understanding Your Visa Dispute’ flyer'},
                        {'certification' : 'Member acknowledges that provisional credit may be received within 10 business days subject to the result/or length of the investigation'},
                    ];
                    break;
                case 'cancelled':
                    this.certifications = [
                        {'certification' : 'Member authorized the transaction(s)'},
                        {'certification' : 'Member contacted stated merchant regarding this dispute but remains unresolved'},
                        {'certification' : 'Member has been provided the ‘Understanding Your Visa Dispute’ flyer'},
                        {'certification' : 'Member acknowledges that provisional credit may be received within 10 business days subject to the result/or length of the investigation'},
                    ];
                    break;
                case 'duplicate':
                    this.certifications = [
                        {'certification' : 'Member authorized the transaction(s)'},
                        {'certification' : 'Member contacted stated merchant regarding this dispute but remains unresolved'},
                        {'certification' : 'Member has been provided the ‘Understanding Your Visa Dispute’ flyer'},
                        {'certification' : 'Member acknowledges that provisional credit may be received within 10 business days subject to the result/or length of the investigation'},
                    ];
                    break;
                default:
                    break;
            }
        }

        //Check all field validity

        let stateOfResidencyComponent = this.template.querySelector('.stateOfResidency');
        let stateOfResidencyComponentValid = true;
        if (stateOfResidencyComponent) {
            stateOfResidencyComponentValid = stateOfResidencyComponent.checkValidity();
            stateOfResidencyComponent.showHelpMessageIfInvalid();
        }

        let cardStatusComponent = this.template.querySelector('.cardStatus');
        let cardStatusComponentValid = true;
        if (cardStatusComponent) {
            cardStatusComponentValid = cardStatusComponent.checkValidity();
            cardStatusComponent.showHelpMessageIfInvalid();
        }

        let reportedPDComponent = this.template.querySelector('.reportedPD');
        let reportedPDComponentValid = true;
        if (reportedPDComponent) {
            reportedPDComponentValid = reportedPDComponent.checkValidity();
            reportedPDComponent.showHelpMessageIfInvalid();
        }

        let lossDiscoveredComponent = this.template.querySelector('.lossDiscovered');
        let lossDiscoveredComponentValid = true;
        if (lossDiscoveredComponent) {
            lossDiscoveredComponentValid = lossDiscoveredComponent.checkValidity();
            lossDiscoveredComponent.showHelpMessageIfInvalid();
        }

        let authorityComponent = this.template.querySelector('.authority');
        let authorityComponentValid = true;
        if (authorityComponent) {
            authorityComponentValid = authorityComponent.checkValidity();
            authorityComponent.showHelpMessageIfInvalid();
        }

        let reportNumberComponent = this.template.querySelector('.reportNumber');
        let reportNumberComponentValid = true;
        if (reportNumberComponent) {
            reportNumberComponentValid = reportNumberComponent.checkValidity();
            reportNumberComponent.showHelpMessageIfInvalid();
        }

        if (!stateOfResidencyComponentValid ||
            !cardStatusComponentValid       ||
            !reportedPDComponentValid       ||
            !lossDiscoveredComponentValid   ||
            !authorityComponentValid        ||
            !reportNumberComponentValid) {
            this.setError('Please provide all required fields.');
            return;
        }

        // Start of Unauthorized form submit

        if (this.disputeReason === 'unauthorized') {
            // Hot card stuff
            // Create a copy of the card; DO NOT alter the existing one.
            let card = JSON.parse(JSON.stringify(this.selectedCard));

            if (card.typeCode === 'DBT') {
                card.status = 'HOT';
                card.changeReason = 'Unauthorized';
                card.changeReasonCode = this.cardStatus;
            } else {
                card.status = 'ReportedLost';
            }

            let cards = [card];

            let requestJSON = JSON.stringify(cards);

            let request = {
                contactId: this.contactid,
                requestJSON: requestJSON
            };

            // <!-- TODO: filtering needed on this component - we should only show cards that are ON and on the account-->
            //--TODO: If we can tell which card was used don't display this. Also remove this comment once we know. :)-->
            //--NOTES FOR HOT CARD
            //  Card must be selected so that we can process the hot card with the dispute form
            //  The hot card form has a few additional fields. Here is how they will be filled:
            //  DEBIT:
            //      - New Status: OFF
            //      - Reason:
            //          - Lost if user selected Lost on radio group named 'cardStatus'
            //          - Stolen if user selected Stolen on radio group named 'cardStatus'
            //          - Closed by Customer if user selected Niether on radio group
            //      - Reason for Decision:
            //          'Unauthorized transaction on card'
            //  CREDIT:
            //      - New Status: OFF

            updateCardStatuses(request)
                .then(response => {
                    if (response.error) {
                        this.setError = response.error;
                        return;
                    }

                    this.complete = true;
                })
                .catch(err => {
                    this.setError = JSON.stringify(err);
                })
                .finally(() => {
                    this.isSaving = false;
                });

            // Submit to Esign Apex
            let friendlyCardStatus = this.cardStatus == 'LOST' ? 'Lost' : this.cardStatus == 'STLN' ? 'Stolen' : this.cardStatus == 'CCLS' ? 'In Possession' : '';

            let requestJson = JSON.stringify({
            memberName: this.contact.Name,
            memberNumber: this.contact.MemberNumber__c.toString(),
            phoneNumber: this.contact.Phone,
            email: this.contact.Email,
            accountNumber: this.account.accountNumber,
            street: this.contact.MailingStreet,
            city: this.contact.MailingCity,
            state: this.contact.MailingState,
            postalCode: this.contact.MailingPostalCode,
            transactions: this.transList,

            wasAtmTransaction: false,
            wasWithinIdaho: this.stateOfResidency,
            cardStatus: friendlyCardStatus,
            isCardBlocked: true,
            wasReportedToPolice: this.policeReport,
            dateLossDiscovered: moment(this.lossDiscoveredDate).format("M/D/YYYY"),
            dateLossReported: this.today,
            dateOfFirstFraud: moment(this.lossDiscoveredDate).format("M/D/YYYY"),
            authorityName: this.authorityName ? this.authorityName : '',
            authorityPhone: this.authorityPhone ? this.authorityPhone : '',
            authorityReportNumber: this.reportNumber ? this.reportNumber : '',
            unauthorizedUser: this.unauthorizedUserName ? this.unauthorizedUserName : '',
            unauthorizedUserAddress: (this.unauthorizedUserLine1Address || this.unauthorizedUserLine2Address) ? this.unauthorizedUserLine1Address + this.unauthorizedUserLine2Address: ''
            });

            sendVisaUnauthorizedTransaction({ jsonPayload : requestJson, personNumber : this.contact.PersonNumber__c, cardUniqueId : this.cardUniqueId }).then(result => {
                let visaResult = result ? result : {};
                if (!visaResult.error) {
                    this.complete = true;
                    this.isSaving = false;
                } else {
                    this.setError('Unable to complete visa form. ' + visaResult.error);
                    this.isDisabled = true;
                }
            }).catch(error => {
                if (error.body) {
                    this.setError(error.body.message);
                } else if (error.message) {
                    this.setError(error.message);
                } else {
                    this.setError('An unknown error occurred while trying to submit the form.');
                }

                this.isDisabled = true;
            });
        }

        // Start of Refund
        if (this.disputeReason === 'refund') {
            // Submit to Esign Apex

            let requestJson = JSON.stringify({
            memberName: this.contact.Name,
            memberNumber: this.contact.MemberNumber__c.toString(),
            phoneNumber: this.contact.Phone,
            email: this.contact.Email,
            accountNumber: this.account.accountNumber,
            street: this.contact.MailingStreet,
            city: this.contact.MailingCity,
            state: this.contact.MailingState,
            postalCode: this.contact.MailingPostalCode,
            transactions: this.transList,

            refundAcknowledged: this.refundAcknowledged,
            merchantDate: moment(this.merchantDate).format("M/D/YYYY"),
            merchantRepresentative: this.merchantRepName,
            merchantContactMethod:  this.merchantContactMethod,
            returnDate: moment(this.refundReturnDate).format("M/D/YYYY"),
            returnedVia: this.returnMethod,
            merchantResponse: this.merchantResponse
            });

        // NOTE:
        //     - The domain values for `merchantContactMethod` are:
        //         - Phone
        //         - Email
        //         - In Person
        //     - The domain values for `returnedVia` are:
        //         - DHL
        //         - In Person
        //         - FedEx
        //         - UPS
        //         - USPS
        //

            sendVisaRefundForSignature({ jsonPayload : requestJson, personNumber : this.contact.PersonNumber__c, cardUniqueId : this.cardUniqueId }).then(result => {
                let visaResult = result ? result : {};
                if (!visaResult.error) {
                    this.complete = true;
                    this.isSaving = false;
                } else {
                    this.setError('Unable to complete visa form. ' + visaResult.error);
                    this.isDisabled = true;
                }
            }).catch(error => {
                if (error.body) {
                    this.setError(error.body.message);
                } else if (error.message) {
                    this.setError(error.message);
                } else {
                    this.setError('An unknown error occurred while trying to submit the form.');
                }
                this.isDisabled = true;
            });
        }

        // Start of atm funds
        if (this.disputeReason === 'atm funds') {
            // Submit to Esign Apex

            let requestJson = JSON.stringify({
            memberName: this.contact.Name,
            memberNumber: this.contact.MemberNumber__c.toString(),
            phoneNumber: this.contact.Phone,
            email: this.contact.Email,
            accountNumber: this.account.accountNumber,
            street: this.contact.MailingStreet,
            city: this.contact.MailingCity,
            state: this.contact.MailingState,
            postalCode: this.contact.MailingPostalCode,
            transactions: this.transList,
            notes: this.refundNotes,

            amountRequested: this.amountRequested,
            amountReceived: this.amountReceived,
            atmLocation: this.selectedTransactions[0].externalDescription

        });

            sendVisaFundsNotReceivedForSignature({ jsonPayload : requestJson, personNumber : this.contact.PersonNumber__c, cardUniqueId : this.cardUniqueId }).then(result => {
                let visaResult = result ? result : {};
                if (!visaResult.error) {
                    this.complete = true;
                    this.isSaving = false;
                } else {
                    this.setError('Unable to complete visa form. ' + visaResult.error);
                    this.isDisabled = true;
                }
            }).catch(error => {
                if (error.body) {
                    this.setError(error.body.message);
                } else if (error.message) {
                    this.setError(error.message);
                } else {
                    this.setError('An unknown error occurred while trying to submit the form.');
                }

                this.isDisabled = true;
            });
        }

        // Start of not recieved
        if (this.disputeReason === 'not received') {
            // Submit to Esign Apex

            let requestJson = JSON.stringify({
            memberName: this.contact.Name,
            memberNumber: this.contact.MemberNumber__c.toString(),
            phoneNumber: this.contact.Phone,
            email: this.contact.Email,
            accountNumber: this.account.accountNumber,
            street: this.contact.MailingStreet,
            city: this.contact.MailingCity,
            state: this.contact.MailingState,
            postalCode: this.contact.MailingPostalCode,

            deliveryDate: moment(this.expectedDeliveryDate).format("M/D/YYYY"),
            productDesc: this.productDescription,
            contactMerchDate: moment(this.merchantDate).format("M/D/YYYY"),
            merchRepName: this.merchantRepName,
            contactMethod: this.merchantContactMethod,
            merchResponse: this.merchantResponse,
            hasBondingAuthority: this.insuranceScheme,
            shippedWrong: this.shippedWrong,
            returnedMerchandise: this.returnedMerchandise
        });

            // NOTE:
            // - `contactMethod` domain values are as follows:
            //     - Phone
            //     - Email
            //     - In Person

            sendVisaMerchNotReceivedForSignature({ jsonPayload : requestJson, personNumber : this.contact.PersonNumber__c, cardUniqueId : this.cardUniqueId }).then(result => {
                let visaResult = result ? result : {};
                if (!visaResult.error) {
                    this.complete = true;
                    this.isSaving = false;
                } else {
                    this.setError('Unable to complete visa form. ' + visaResult.error);
                    this.isDisabled = true;
                }
            }).catch(error => {
                if (error.body) {
                    this.setError(error.body.message);
                } else if (error.message) {
                    this.setError(error.message);
                } else {
                    this.setError('An unknown error occurred while trying to submit the form.');
                }

                this.isDisabled = true;
            });
        }

        // Start of not as described
        if (this.disputeReason === 'not as described') {
            // Submit to Esign Apex

            let requestJson = JSON.stringify({
            memberName: this.contact.Name,
            memberNumber: this.contact.MemberNumber__c.toString(),
            phoneNumber: this.contact.Phone,
            email: this.contact.Email,
            accountNumber: this.account.accountNumber,
            street: this.contact.MailingStreet,
            city: this.contact.MailingCity,
            state: this.contact.MailingState,
            postalCode: this.contact.MailingPostalCode,
            transactions: this.transList,

            disputeReason: this.disputeDueTo,
            reasonDesc: this.merchReason,
            contactMerchDate: moment(this.merchantDate).format("M/D/YYYY"),
            merchRepName: this.merchantRepName,
            contactMethod: this.merchantContactMethod,
            wasReturned: this.merchReturn,
            returnedVia: this.returnMethod,
            merchResponse: this.merchantResponse,
            previousNegotiation: this.negotiations,
            nogitiationDescription: this.negotiationDescription
        });

            // NOTE:
            //     - `disputeReason` domain values are as follows:
            //         - Counterfeit Merchandise
            //         - Damaged/Defective Merchandise
            //         - Misrepresentation/Not as Described
            //         - Quality Issues
            //     - `contactMethod` domain values are as follows:
            //         - Phone
            //         - Email
            //         - In Person
            //     - `returnedVia` domain values are as follows:
            //         - DHL
            //         - In Person
            //         - FedEx
            //         - UPS
            //         - USPS

            sendVisaMerchNotAsDescribedForSignature({ jsonPayload : requestJson, personNumber : this.contact.PersonNumber__c, cardUniqueId : this.cardUniqueId }).then(result => {
                let visaResult = result ? result : {};
                if (!visaResult.error) {
                    this.complete = true;
                    this.isSaving = false;
                } else {
                    this.setError('Unable to complete visa form. ' + visaResult.error);
                    this.isDisabled = true;
                }
            }).catch(error => {
                if (error.body) {
                    this.setError(error.body.message);
                } else if (error.message) {
                    this.setError(error.message);
                } else {
                    this.setError('An unknown error occurred while trying to submit the form.');
                }

                this.isDisabled = true;
            });
        }

        // Start of overcharged
        if (this.disputeReason === 'overcharged') {
            // Submit to Esign Apex

            let requestJson = JSON.stringify({
            memberName: this.contact.Name,
            memberNumber: this.contact.MemberNumber__c.toString(),
            phoneNumber: this.contact.Phone,
            email: this.contact.Email,
            accountNumber: this.account.accountNumber,
            street: this.contact.MailingStreet,
            city: this.contact.MailingCity,
            state: this.contact.MailingState,
            postalCode: this.contact.MailingPostalCode,
            transactions: this.transList,

            amountCharged: this.transList[0].amount,
            correctCharge: '$' + this.overchargedAmount,
            contactMerchDate: moment(this.merchantDate).format("M/D/YYYY"),
            merchRepName: this.merchantRepName,
            contactMethod: this.merchantContactMethod,
            merchResponse: this.merchantResponse
        });

            // NOTE:
            //     - `contactMethod` domain values are as follows:
            //         - Phone
            //         - Email
            //         - In Person

            sendVisaOverchargeForSignature({ jsonPayload : requestJson, personNumber : this.contact.PersonNumber__c, cardUniqueId : this.cardUniqueId }).then(result => {
                let visaResult = result ? result : {};
                if (!visaResult.error) {
                    this.complete = true;
                    this.isSaving = false;
                } else {
                    this.setError('Unable to complete visa form. ' + visaResult.error);
                    this.isDisabled = true;
                }
            }).catch(error => {
                if (error.body) {
                    this.setError(error.body.message);
                } else if (error.message) {
                    this.setError(error.message);
                } else {
                    this.setError('An unknown error occurred while trying to submit the form.');
                }

                this.isDisabled = true;
            });
        }

        // Start of other means
        if (this.disputeReason === 'other means') {
            // Submit to Esign Apex

            let requestJson = JSON.stringify({
            memberName: this.contact.Name,
            memberNumber: this.contact.MemberNumber__c.toString(),
            phoneNumber: this.contact.Phone,
            email: this.contact.Email,
            accountNumber: this.account.accountNumber,
            street: this.contact.MailingStreet,
            city: this.contact.MailingCity,
            state: this.contact.MailingState,
            postalCode: this.contact.MailingPostalCode,
            transactions: this.transList,

            usedSameAccount: true,
            checkNumber: this.paymentTypeCheck,
            achAccountNumber: this.paymentTypeACH,
            cardNumber: this.paymentTypeCard,
            proof: this.paymentType,
            contactMerchDate: moment(this.merchantDate).format("M/D/YYYY"),
            merchRepName: this.merchantRepName,
            contactMethod: this.merchantContactMethod,
            merchResponse: this.merchantResponse
        });

            // NOTE:
            //     - `proof` domain values are as follows:
            //         - Check
            //         - ACH
            //         - Card
            //         - Cash
            //     - `contactMethod` domain values are as follows:
            //         - Phone
            //         - Email
            //         - In Person

            sendVisaPaidByOtherMeansForSignature({ jsonPayload : requestJson, personNumber : this.contact.PersonNumber__c, cardUniqueId : this.cardUniqueId }).then(result => {
                let visaResult = result ? result : {};
                if (!visaResult.error) {
                    this.complete = true;
                    this.isSaving = false;
                } else {
                    this.setError('Unable to complete visa form. ' + visaResult.error);
                    this.isDisabled = true;
                }
            }).catch(error => {
                if (error.body) {
                    this.setError(error.body.message);
                } else if (error.message) {
                    this.setError(error.message);
                } else {
                    this.setError('An unknown error occurred while trying to submit the form.');
                }

                this.isDisabled = true;
            });
        }

        // Start of cancelled
        if (this.disputeReason === 'cancelled') {
            // Submit to Esign Apex

            let requestJson = JSON.stringify({
            memberName: this.contact.Name,
            memberNumber: this.contact.MemberNumber__c.toString(),
            phoneNumber: this.contact.Phone,
            email: this.contact.Email,
            accountNumber: this.account.accountNumber,
            street: this.contact.MailingStreet,
            city: this.contact.MailingCity,
            state: this.contact.MailingState,
            postalCode: this.contact.MailingPostalCode,
            transactions: this.transList,

            isRecurring: this.recurringTransaction,
            cancelledDate: moment(this.cancellationDate).format("M/D/YYYY"),
            cancellationNumber: this.cancellationNumber,
            contactMerchDate: moment(this.merchantDate).format("M/D/YYYY"),
            merchRepName: this.merchantRepName,
            contactMethod: this.merchantContactMethod,
            merchResponse: this.merchantResponse,
            cancellationType: this.cancellationType,
            cancellationReason: this.cancellationReason
        });

            // NOTE:
            //     - `contactMethod` domain values are as follows:
            //         - Phone
            //         - Email
            //         - In Person

            sendVisaMembershipCancelledForSignature({ jsonPayload : requestJson, personNumber : this.contact.PersonNumber__c, cardUniqueId : this.cardUniqueId  }).then(result => {
                let visaResult = result ? result : {};
                if (!visaResult.error) {
                    this.complete = true;
                    this.isSaving = false;
                } else {
                    this.setError('Unable to complete visa form. ' + visaResult.error);
                    this.isDisabled = true;
                }
            }).catch(error => {
                if (error.body) {
                    this.setError(error.body.message);
                } else if (error.message) {
                    this.setError(error.message);
                } else {
                    this.setError('An unknown error occurred while trying to submit the form.');
                }

                this.isDisabled = true;
            });
        }

        // Start of duplicate
        if (this.disputeReason === 'duplicate') {
            // Submit to Esign Apex

            let requestJson = JSON.stringify({
            memberName: this.contact.Name,
            memberNumber: this.contact.MemberNumber__c.toString(),
            phoneNumber: this.contact.Phone,
            email: this.contact.Email,
            accountNumber: this.account.accountNumber,
            street: this.contact.MailingStreet,
            city: this.contact.MailingCity,
            state: this.contact.MailingState,
            postalCode: this.contact.MailingPostalCode,
            transactions: this.transList,

            usedSameAccount: true,
            contactMerchDate: moment(this.merchantDate).format("M/D/YYYY"),
            merchRepName: this.merchantRepName,
            contactMethod: this.merchantContactMethod,
            merchResponse: this.merchantResponse
        });

            // NOTE:
            //     - `contactMethod` domain values are as follows:
            //         - Phone
            //         - Email
            //         - In Person

            sendVisaDuplicateProcessingForSignature({ jsonPayload : requestJson, personNumber : this.contact.PersonNumber__c, cardUniqueId : this.cardUniqueId }).then(result => {
                let visaResult = result ? result : {};
                if (!visaResult.error) {
                    this.complete = true;
                    this.isSaving = false;
                } else {
                    this.setError('Unable to complete visa form. ' + visaResult.error);
                    this.isDisabled = true;
                }
            }).catch(error => {
                if (error.body) {
                    this.setError(error.body.message);
                } else if (error.message) {
                    this.setError(error.message);
                } else {
                    this.setError('An unknown error occurred while trying to submit the form.');
                }
                this.isDisabled = true;
            });
        }

    }
//End of Function
}