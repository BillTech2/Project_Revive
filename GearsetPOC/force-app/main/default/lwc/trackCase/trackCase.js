/**
 * Created by JU on 27.09.2022.
 */

 import {api, track, LightningElement} from 'lwc';
 /*labels*/
 import AddInfo from '@salesforce/label/c.AddInfo';
 import AddInfo_dut from '@salesforce/label/c.AddInfo_dut';
 import AddInfo_fr from '@salesforce/label/c.AddInfo_fr';
 import CaseLabelDescription from '@salesforce/label/c.CaseDescription';
 import CaseLabelDescription_dut from '@salesforce/label/c.CaseDescription_dut';
 import CaseLabelDescription_fr from '@salesforce/label/c.CaseDescription_fr';
 import CaseHistory from '@salesforce/label/c.CaseHistory';
 import CaseHistory_dut from '@salesforce/label/c.CaseHistory_dut';
 import CaseHistory_fr from '@salesforce/label/c.CaseHistory_fr';
 import ClosedLessThanTenWeeksLabel from '@salesforce/label/c.ClosedLessThanTenWeeks';
 import ClosedLessThanTenWeeks_dut from '@salesforce/label/c.ClosedLessThanTenWeeks_dut';
 import ClosedLessThanTenWeeks_fr from '@salesforce/label/c.ClosedLessThanTenWeeks_fr';
 import ClosedMoreThanTenWeeksLabel from '@salesforce/label/c.ClosedMoreThanTenWeeks';
 import ClosedMoreThanTenWeeksLabel_dut from '@salesforce/label/c.ClosedMoreThanTenWeeks_dut';
 import ClosedMoreThanTenWeeksLabel_fr from '@salesforce/label/c.ClosedMoreThanTenWeeks_fr';
 import CommunicationHistory from '@salesforce/label/c.CommunicationHistory';
 import CommunicationHistory_dut from '@salesforce/label/c.CommunicationHistory_dut';
 import CommunicationHistory_fr from '@salesforce/label/c.CommunicationHistory_fr';
 import FailUpdate from '@salesforce/label/c.FailUpdate';
 import FailUpdate_dut from '@salesforce/label/c.FailUpdate_dut';
 import FailUpdate_fr from '@salesforce/label/c.FailUpdate_dut';
 import Greeting from '@salesforce/label/c.Greeting';
 import Greeting_dut from '@salesforce/label/c.Greeting_dut';
 import Greeting_fr from '@salesforce/label/c.Greeting_fr';
 import OpenCaseLabel_dut from '@salesforce/label/c.OpenCase_dut';
 import OpenCaseLabel from '@salesforce/label/c.OpenCase';
 import OpenCaseLabel_fr from '@salesforce/label/c.OpenCase_fr';
 import parkingPageLabel from '@salesforce/label/c.ParkingPage';
 import parkingPageLabel_dut from '@salesforce/label/c.ParkingPage_dut';
 import parkingPageLabel_fr from '@salesforce/label/c.ParkingPage_fr';
 import redirectToContactUs from '@salesforce/label/c.redirectToContactUs';
 import redirectToContactUs_dut from '@salesforce/label/c.redirectToContactUs_dut';
 import redirectToContactUs_fr from '@salesforce/label/c.redirectToContactUs_fr';
 import SuccessfulUpdate from '@salesforce/label/c.SuccessfulUpdate';
 import SuccessfulUpdate_dut from '@salesforce/label/c.SuccessfulUpdate_dut';
 import SuccessfulUpdate_fr from '@salesforce/label/c.SuccessfulUpdate_fr';
 import TrackPageSave from '@salesforce/label/c.TrackPageSave';
 import TrackPageSave_dut from '@salesforce/label/c.TrackPageSave_dut';
 import TrackPageSave_fr from '@salesforce/label/c.TrackPageSave_fr';
 import trSubmit from '@salesforce/label/c.trSubmit';
 import trSubmit_dut from '@salesforce/label/c.trSubmit_dut';
 import TypeSomeText from '@salesforce/label/c.TypeSomeText';
 import TypeSomeText_dut from '@salesforce/label/c.TypeSomeText_dut';
 import TypeSomeText_fr from '@salesforce/label/c.TypeSomeText_fr';
 import trSubmit_fr from '@salesforce/label/c.trSubmit_fr';
 import ContactUsButtonLink from '@salesforce/label/c.ContactUsButtonLink';
 
 
 
 
 
 
 
 /*labels*/
 import getContactbyHash from '@salesforce/apex/HashController.getContactbyHash'
 import updateCase from '@salesforce/apex/HashController.updateCase'
 import createContactUsLink from '@salesforce/apex/HashController.createContactUsLink'
 import { NavigationMixin } from "lightning/navigation";
 import lang from '@salesforce/schema/User.LanguageLocaleKey';
 
 
 
 export default class TrackCase extends LightningElement {
 
 
     @api langCode;
     @api caseId;
     @track showSpinner = true;
     @track customerName;
     @track caseDescription;
     @track emailMessages = [];
     @track isParkingPage;
     @track isParkingPageLabel;
     @track isClosedMoreThanTenWeeks;
     @track displayAddCommentsForm;
     @track isClosedLessThanTenWeeks;
     @track isOpenCase;
     @track displayRedirectToContactUs;
     @track displayQueryHistory;
     @track showLoadingSpinner = false;
     @track isTrue = false;
     @track fileNames = '';
     @track fileList = [];
     @track isSaveSuccessful = false;
     @track isSaveFailed = false;
     @track contactUsUrl ;
     @track typeSomethingComment = false;
 
     label = {
         AddInfo
         ,AddInfo_dut
         ,AddInfo_fr
         ,CaseLabelDescription
         ,CaseLabelDescription_dut
         ,CaseLabelDescription_fr
         ,CaseHistory
         ,CaseHistory_dut
         ,CaseHistory_fr
         ,ClosedLessThanTenWeeksLabel
         ,ClosedLessThanTenWeeks_dut
         ,ClosedLessThanTenWeeks_fr
         ,ClosedMoreThanTenWeeksLabel
         ,ClosedMoreThanTenWeeksLabel_dut
         ,ClosedMoreThanTenWeeksLabel_fr
         ,CommunicationHistory
         ,CommunicationHistory_dut
         ,CommunicationHistory_fr
         ,FailUpdate
         ,FailUpdate_dut
         ,FailUpdate_fr
         ,Greeting
         ,Greeting_dut
         ,Greeting_fr
         ,OpenCaseLabel
         ,OpenCaseLabel_dut
         ,OpenCaseLabel_fr
         ,parkingPageLabel
         ,parkingPageLabel_dut
         ,parkingPageLabel_fr
         ,redirectToContactUs
         ,redirectToContactUs_dut
         ,redirectToContactUs_fr
         ,SuccessfulUpdate
         ,SuccessfulUpdate_dut
         ,SuccessfulUpdate_fr
         ,TrackPageSave
         ,TrackPageSave_dut
         ,TrackPageSave_fr
         ,trSubmit
         ,trSubmit_dut
         ,trSubmit_fr
         ,TypeSomeText_fr
         ,TypeSomeText_dut
         ,TypeSomeText
         ,ContactUsButtonLink
     }
     caseDetails;
     @track filesUploaded = [];
     file;
     fileContents;
     content;
 
     @track addInfoTr;
     @track CaseDescriptionTr;
     @track CaseHistoryTr;
     @track ClosedLessThanTenWeeksTr;
     @track ClosedMoreThanTenWeeksTr;
     @track CommunicationHistoryTr;
     @track FailUpdateTr;
     @track GreetingTr;
     @track OpenCaseTr;
     @track ParkingPageTr;
     @track redirectToContactUsTr;
     @track SuccessfulUpdateTr;
     @track TrackPageSaveTr;
     @track trSubmitTr;
     @track typeSomeTextTr;
 
 
 
     connectedCallback() {
         this.addInfoTr = this.langCode=='FR'?this.label.AddInfo_fr:(this.langCode=='NL'?this.label.AddInfo_dut:this.label.AddInfo);
         this.CaseDescriptionTr = this.langCode=='FR'?this.label.CaseLabelDescription_fr:(this.langCode=='NL'?this.label.CaseLabelDescription_dut:this.label.CaseLabelDescription);
         this.CaseHistoryTr = this.langCode=='FR'?this.label.CaseHistory_fr:(this.langCode=='NL'?this.label.CaseHistory_dut:this.label.CaseHistory);
         this.ClosedLessThanTenWeeksTr = this.langCode=='FR'?this.label.ClosedLessThanTenWeeks_fr:(this.langCode=='NL'?this.label.ClosedLessThanTenWeeks_dut:this.label.ClosedLessThanTenWeeksLabel);
         this.ClosedMoreThanTenWeeksTr = this.langCode=='FR'?this.label.ClosedMoreThanTenWeeksLabel_fr:(this.langCode=='NL'?this.label.ClosedMoreThanTenWeeksLabel_dut:this.label.ClosedMoreThanTenWeeksLabel);
         this.CommunicationHistoryTr = this.langCode=='FR'?this.label.CommunicationHistory_fr:(this.langCode=='NL'?this.label.CommunicationHistory_dut:this.label.CommunicationHistory);
         this.FailUpdateTr = this.langCode=='FR'?this.label.FailUpdate_fr:(this.langCode=='NL'?this.label.FailUpdate_dut:this.label.FailUpdate);
         this.GreetingTr = this.langCode=='FR'?this.label.Greeting_fr:(this.langCode=='NL'?this.label.Greeting_dut:this.label.Greeting);
         this.OpenCaseTr = this.langCode=='FR'?this.label.OpenCaseLabel_fr:(this.langCode=='NL'?this.label.OpenCaseLabel_dut:this.label.OpenCaseLabel);
         this.ParkingPageTr = this.langCode=='FR'?this.label.parkingPageLabel_fr:(this.langCode=='NL'?this.label.parkingPageLabel_dut:this.label.parkingPageLabel);
         this.redirectToContactUsTr = this.langCode=='FR'?this.label.redirectToContactUs_fr:(this.langCode=='NL'?this.label.redirectToContactUs_dut:this.label.redirectToContactUs);
         this.SuccessfulUpdateTr = this.langCode=='FR'?this.label.SuccessfulUpdate_fr:(this.langCode=='NL'?this.label.SuccessfulUpdate_dut:this.label.SuccessfulUpdate);
         this.TrackPageSaveTr = this.langCode=='FR'?this.label.TrackPageSave_fr:(this.langCode=='NL'?this.label.TrackPageSave_dut:this.label.TrackPageSave);
         this.trSubmitTr = this.langCode=='FR'?this.label.trSubmit_fr:(this.langCode=='NL'?this.label.trSubmit_dut:this.label.trSubmit);
         this.typeSomeTextTr = this.langCode=='FR'?this.label.TypeSomeText_fr:(this.langCode=='NL'?this.label.TypeSomeText_dut:this.label.TypeSomeText);
 
 
         if(this.caseId!=''){
             getContactbyHash({hash: this.caseId})
                 .then((result) => {
                     this.caseDetails = result;
                     if(this.caseDetails!=null){
                         this.customerName = this.caseDetails.customerName;
                         this.caseDescription = this.caseDetails.Description;
                         this.emailMessages = this.caseDetails.messages;
                         this.isParkingPage = false;
                         this.isClosedMoreThanTenWeeks = this.caseDetails.isClosed&&!this.caseDetails.canAddDetails;
                         this.displayAddCommentsForm = this.caseDetails.canAddDetails;
                         this.isClosedLessThanTenWeeks = this.caseDetails.isClosed&&this.caseDetails.canAddDetails;
                         this.isOpenCase = this.caseDetails.isClosed==false;
                         this.displayRedirectToContactUs = this.isClosedMoreThanTenWeeks;
                         this.displayQueryHistory = this.caseDescription!=null||this.emailMessages.length>0;
                         console.log( this.caseDetails);
                         createContactUsLink().
                             then((result) =>{
                                 this.contactUsUrl = result;
                             }).catch((error) =>{
                                 this.contactUsUrl = 'https://www.eurostar.com/rw-en'
                         })
                     }
                     else{
                         this.isParkingPage = true;
                         this.isParkingPageLabel = true;
                     }
 
                     this.showSpinner = false;
                 })
                 .catch((error) => {
                     this.error = error;
                     this.case = undefined;
                     this.isParkingPage = true;
                     this.isParkingPageLabel = true;
                     this.showSpinner = false;
                 });
         }
 
         else{this.isParkingPage=true}
 
 
     }
 
     handleChange(){
         this.typeSomethingComment = false;
     }
 
     submitButton(event) {
         console.log('submitButton');
         console.log(this.template.querySelector("lightning-textarea").value);
         this.showLoadingSpinner = true;
         //this.handleSave();
         if(this.template.querySelector("lightning-textarea").value!=null&&this.template.querySelector("lightning-textarea").value!=''){
             console.log('notnull')
             if (this.caseId != '') {
             updateCase({
                 caseHash: this.caseId,
                 newDescription: this.template.querySelector("lightning-textarea").value,
                 attachments: this.filesUploaded
             })
                 .then((result) => {
                     this.fileName = this.fileName + ' - Uploaded Successfully';
                     this.isTrue = true;
                     this.isSaveSuccessful = true;
                     this.isParkingPage = true;
                     this.showLoadingSpinner = false;
 
                 })
                 .catch((error) => {
                     this.error = error;
                     this.isSaveFailed != true;
                     this.isParkingPage = true;
                     this.showLoadingSpinner = false;
                 });
 
         }
 
         }
         else{
             this.showLoadingSpinner = false;
             this.typeSomethingComment = true;
         }
 
 
 
     }
 
 
 
 
     handleFilesChange(event) {
         let files = event.target.files;
         if (files.length > 0) {
             let filesName = '';
             for (let i = 0; i < files.length; i++) {
                 let file = files[i];
                 filesName = filesName + file.name + ',';
                 let freader = new FileReader();
                 freader.onload = f => {
                     let base64 = 'base64,';
                     let content = freader.result.indexOf(base64) + base64.length;
                     let fileContents = freader.result.substring(content);
                     this.filesUploaded.push({
                         title: file.name,
                         versionData: fileContents
                     });
                 };
                 freader.readAsDataURL(file);
             }
             this.fileNames = filesName.slice(0, -1);
         }
     }
 
 
 
 
 }