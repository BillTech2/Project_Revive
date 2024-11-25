//Field wordings
import EmployeeNameLabel from "@salesforce/label/c.LC_EmployeeName";
import EmployeeNumberLabel from "@salesforce/label/c.LC_EmployeeNumber";
import JobTitleLabel from "@salesforce/label/c.LC_JobTitle";
import LastDayOfEmploymentLabel from "@salesforce/label/c.LC_LastDayOfEmployment";
import StaffTravelCardLabel from "@salesforce/label/c.LC_StaffTravelCard";
import DutyTravelPassLabel from "@salesforce/label/c.LC_DutyTravelPass";
import PTACCardLabel from "@salesforce/label/c.LC_PTACCard";
import BRLULResidentialPassLabel from "@salesforce/label/c.LC_BRLULResidentialPass";
import UnusedEurostarVouchersLabel from "@salesforce/label/c.LC_UnusedEurostarVouchers";
import StatusPassLabel from "@salesforce/label/c.LC_StatusPass";
import TFLStatusPassLabel from "@salesforce/label/c.LC_TFLStatusPass";
import ContactPayrollServiceLabel from "@salesforce/label/c.LC_ContactPayrollService";
import ReturnUniformEquipmentLabel from "@salesforce/label/c.LC_ReturnUniformEquipment";
import ReturnRulesBooksPublicationsLabel from "@salesforce/label/c.LC_ReturnRulesBooksPublications";
import ReturnClockingCardLockerKeysLabel from "@salesforce/label/c.LC_ReturnClockingCardLockerKeys";
import ReturnSecurityPassesStaffIDBadgeLabel from "@salesforce/label/c.LC_ReturnSecurityPassesStaffIDBadge";
import ReturnISEquipmentAccessoriesLabel from "@salesforce/label/c.LC_ReturnISEquipmentAccessories";
import MobilePhoneUnlockSignOutLabel from "@salesforce/label/c.LC_MobilePhoneUnlockSignOut";
import ReturnCreditCardsSettleBalanceLabel from "@salesforce/label/c.LC_ReturnCreditCardsSettleBalance";
import EnsureExpenseClaimsSubmissionLabel from "@salesforce/label/c.LC_EnsureExpenseClaimsSubmission";
import EnsureHRPayrollNotifiedLabel from "@salesforce/label/c.LC_EnsureHRPayrollNotified";
import EnsureLeaversTicketRaisedWithISLabel from "@salesforce/label/c.LC_EnsureLeaversTicketRaisedWithIS";
import EnsureMarkViewQueuesClearedLabel from "@salesforce/label/c.LC_EnsureMarkViewQueuesCleared";
import EnsureDTPROReassignedLabel from "@salesforce/label/c.LC_EnsureDTPROReassigned";
import EnsureFinancialApprovalRightsReassignedLabel from "@salesforce/label/c.LC_EnsureFinancialApprovalRightsReassigned";
import EnsureBoxFoldersOwnershipAlteredLabel from "@salesforce/label/c.LC_EnsureBoxFoldersOwnershipAltered";
import EnsureIntranetSitesManagerAlteredLabel from "@salesforce/label/c.LC_EnsureIntranetSitesManagerAltered";
import EnsurePayslipsCopiesDownloadedLabel from "@salesforce/label/c.LC_EnsurePayslipsCopiesDownloaded";
//import FormCompleteLabel from "@salesforce/label/c.LC_FormComplete";
//Responsibles
import PayrollServicedeskLabel from "@salesforce/label/c.LC_PayrollServicedesk";
import LineManagerLabel from "@salesforce/label/c.LC_LineManager";
import UniformStoresLabel from "@salesforce/label/c.LC_UniformStores";
import ResourcePlanningLabel from "@salesforce/label/c.LC_ResourcePlanning";
import EurostarSecurityPassOfficeLabel from "@salesforce/label/c.LC_EurostarSecurityPassOffice";
import ISServicedeskLabel from "@salesforce/label/c.LC_ISServicedesk";
import EmployeeLabel from "@salesforce/label/c.LC_Employee";
import FinanceLabel from "@salesforce/label/c.LC_Finance";
//Headers
import MainHeaderLabel from "@salesforce/label/c.LC_MainHeader";
import TravelRailBenefitsHeaderLabel from "@salesforce/label/c.LC_TravelRailBenefitsHeader";
import MoniesEquipmentHeaderLabel from "@salesforce/label/c.LC_MoniesEquipmentHeader";
import ProcessSystemsHeaderLabel from "@salesforce/label/c.LC_ProcessSystemsHeader";
import PleaseTickAsApplicableSubHeaderLabel from "@salesforce/label/c.LC_PleaseTickAsApplicableSubHeader";
//Section wordings
import MainWordingsLabel from "@salesforce/label/c.LC_MainWordings";
import TravelRailBenefitsWordingsLabel from "@salesforce/label/c.LC_TravelRailBenefitsWordings";
import TravelRailBenefitsWordingsLabelPart2 from "@salesforce/label/c.LC_TravelRailBenefitsWordingsPart2";
//Misc
import ConfirmationMessageLabel from "@salesforce/label/c.LC_Confirmation_Message";
import ConfirmationMessageNoteLabel from "@salesforce/label/c.LC_ConfirmationMessageNote";




const pageLabels = {
    employeeName : EmployeeNameLabel,
    employeeNumber : EmployeeNumberLabel,
    jobTitle : JobTitleLabel,
    lastDayOfEmployment : LastDayOfEmploymentLabel,
    staffTravelCard : StaffTravelCardLabel,
    dutyTravelPass : DutyTravelPassLabel,
    pTACCard : PTACCardLabel,
    bRLULResidentialPass : BRLULResidentialPassLabel,
    unusedEurostarVouchers : UnusedEurostarVouchersLabel,
    statusPass : StatusPassLabel,
    tFLStatusPass : TFLStatusPassLabel,
    contactPayrollService : ContactPayrollServiceLabel,
    returnUniformEquipment : ReturnUniformEquipmentLabel,
    returnRulesBooksPublications : ReturnRulesBooksPublicationsLabel,
    returnClockingCardLockerKeys : ReturnClockingCardLockerKeysLabel,
    returnSecurityPassesStaffIDBadge : ReturnSecurityPassesStaffIDBadgeLabel,
    returnISEquipmentAccessories : ReturnISEquipmentAccessoriesLabel,
    mobilePhoneUnlockSignOut : MobilePhoneUnlockSignOutLabel,
    returnCreditCardsSettleBalance : ReturnCreditCardsSettleBalanceLabel,
    ensureExpenseClaimsSubmission : EnsureExpenseClaimsSubmissionLabel,
    ensureHRPayrollNotified : EnsureHRPayrollNotifiedLabel,
    ensureLeaversTicketRaisedWithIS : EnsureLeaversTicketRaisedWithISLabel,
    ensureMarkViewQueuesCleared : EnsureMarkViewQueuesClearedLabel,
    ensureDTPROReassigned : EnsureDTPROReassignedLabel,
    ensureFinancialApprovalRightsReassigned : EnsureFinancialApprovalRightsReassignedLabel,
    ensureBoxFoldersOwnershipAltered : EnsureBoxFoldersOwnershipAlteredLabel,
    ensureIntranetSitesManagerAltered : EnsureIntranetSitesManagerAlteredLabel,
    ensurePayslipsCopiesDownloaded : EnsurePayslipsCopiesDownloadedLabel,
    //FormComplete : FormCompleteLabel,

    payrollServicedesk : PayrollServicedeskLabel,
    lineManager : LineManagerLabel,
    uniformStores : UniformStoresLabel,
    resourcePlanning : ResourcePlanningLabel,
    eurostarSecurityPassOffice : EurostarSecurityPassOfficeLabel,
    iSServicedesk : ISServicedeskLabel,
    employee : EmployeeLabel,
    finance : FinanceLabel,

    mainHeader : MainHeaderLabel,
    travelRailBenefitsHeader : TravelRailBenefitsHeaderLabel,
    moniesEquipmentHeader : MoniesEquipmentHeaderLabel,
    processSystemsHeader : ProcessSystemsHeaderLabel,
    pleaseTickAsApplicableSubHeader : PleaseTickAsApplicableSubHeaderLabel,

    mainWordings : MainWordingsLabel,
    travelRailBenefitsWordings : TravelRailBenefitsWordingsLabel,
    travelRailBenefitsWordingsPart2 : TravelRailBenefitsWordingsLabelPart2,

    confirmationMessage : ConfirmationMessageLabel,
    confirmationMessageNote : ConfirmationMessageNoteLabel
} 

export default {
    pageLabels
};