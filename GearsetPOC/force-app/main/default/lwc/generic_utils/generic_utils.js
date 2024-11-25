import { LABELS_MAPPING } from 'c/generic_labelUtils';
import { CASE_WHAT_IS_THE_QUESTION, PNR_DISRUPTION_SCENARIOS } from 'c/dltConstants';

const typeToBtnList = {
    initial: [
        { label: 'cu_Yes', eventDetails: { formType: '', listType: '', showUploader: false, subtitle: 'cu_PleaseEnterYourPNR', inputData: [ { inputLabelName: 'cu_PNR', inputPlaceholderName: 'cu_CommentPlaceholder', inputName: 'pnr', checkPNR: true } ] } }, 
        { label: 'cu_No', eventDetails: { formType: '', listType: 'noBooking', showUploader: false, subtitle: 'cu_WhatWouldYouLikeToDo' } }
    ],
    noBooking: [
        {label: 'cu_MakeABooking', eventDetails: {formType: '', listType: 'makeBooking', subtitle: 'cu_MakeABooking'}},
        {label: 'cu_AskAQuestion', eventDetails: {formType: '', listType: 'askQuestion', subtitle: 'cu_AskAQuestion'}},
        {label: 'cu_ClubEurostar',  eventDetails: {formType: '', listType: 'clubEurostar', subtitle: 'cu_ClubEurostar'}},
        {label: 'cu_SpecialAssistance', eventDetails: {formType: '', listType: 'specialAssistanceNoPnr', subtitle: 'cu_SpecialAssistance'}},
        {label: 'cu_Disruption', eventDetails: {subtitle: 'cu_Disruption', listType: 'disruptionQuestions'}},
        {label: 'cu_ReportAProblem',  eventDetails: {formType: '', listType: 'reportProblem', subtitle: 'cu_ReportAProblemTitle'}},
        {label: 'cu_DataRequest', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_DataRequestsWithRedirectToGDPRForm', subtitle: 'cu_DataRequest'}},
        {label: 'cu_Doc_Request_Button', eventDetails: {subtitle: 'cu_Doc_Request_Button', listType: 'docRequests'}},
        {label: 'cu_GiveFeedback', eventDetails: {formType: '', listType: 'feedback', subtitle: 'cu_WhatIsYourFeedbackAbout'}},
        {label: 'cu_SmthWeHaventThoughtOf', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_PleaseEnterYourQuestionBelow', showUploader: true, selectedAction: 'createElseQuestionCase'}},
    ],
    disruptedWithPNR: [
        { label: 'cu_Change', eventDetails: { subtitle: 'cu_BookingChanges', listType: 'exchangeApproval', btnListLabel: 'cu_StillLikeToGoAheadWithExchange', showDynamicText: true, defineDynByPnr: true, flowType: 'change', param: 'isFree', selectedAction: 'createChangeWithPNR' }, visibilitySettings: [ { isLastMinuteTicket: false } ] },
        { label: 'cu_Cancel', eventDetails: { subtitle: 'cu_BookingCancellation', listType: 'cancelApproval', btnListLabel: 'cu_StillLikeToGoAheadWithCancellation', showDynamicText: true, defineDynByPnr: true, flowType: 'cancel', param: 'cancelOption', selectedAction: 'createCancelWithPNR' }, visibilitySettings: [ { isLastMinuteTicket: false } ] },
        { label: 'cu_Claim', eventDetails: { subtitle: 'cu_Claim', listType: 'whatTypeOfClaimFromBooking', btnListLabel: 'cu_WhatTypeOfClaimDoYouNeed', selectedAction: 'createDisruptionQuestionCase' } }, 
        { label: 'cu_Disruption', eventDetails: {subtitle: 'cu_Disruption', listType: 'disruptionQuestions'}},
        { label: 'cu_ClubEurostar', eventDetails: { subtitle: 'cu_ClubEurostar', listType: 'clubEurostar' } },
        { label: 'cu_SpecialAssistance', eventDetails: {formType: '', listType: 'specialAssistanceWithPnr', subtitle: 'cu_SpecialAssistance'}},
        { label: 'cu_Question', eventDetails: { listType: 'askQuestion', subtitle: 'cu_AskAQuestion' } }, 
        { label: 'cu_AddSomething', eventDetails: { addSomething: true }, visibilitySettings: [ { isLastMinuteTicket: false } ] }, 
        { label: 'cu_ReportAProblem', eventDetails: { listType: 'reportProblem', subtitle: 'cu_ReportAProblemTitle' } }, 
        { label: 'cu_MakeANewBooking', eventDetails: { listType: 'makeBooking' }, visibilitySettings: [ { isLastMinuteTicket: false } ] }, 
        { label: 'cu_DataRequest', eventDetails: { showDynamicText: true, dynTextLabel: 'cu_DataRequestsWithRedirectToGDPRForm', subtitle: 'cu_DataRequest' } }, 
        { label: 'cu_Doc_Request_Button', eventDetails: { subtitle: 'cu_Doc_Request_Button', listType: 'docRequestsWithPNR' } },
        { label: 'cu_GiveFeedback', eventDetails: { formType: '', listType: 'feedbackWithPnr', subtitle: 'cu_WhatIsYourFeedbackAbout' } }, 
        { label: 'cu_SmthWeHaventThoughtOf', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_PleaseEnterYourQuestionBelow', showUploader: true, selectedAction: 'createElseQuestionCase'}},
    ],
    notDisruptedWithPNR: [
        { label: 'cu_Change', eventDetails: { subtitle: 'cu_BookingChanges', listType: 'stillNeedHelpChange', showDynamicText: true, dynTextLabel: 'cu_BookingChangesText', defineDynByPnr: false, flowType: 'change', param: [ 'isExchangable', 'isChangeableOnline' ], selectedAction: 'createChangeWithPNR' }, visibilitySettings: [ { isLastMinuteTicket: false } ] }, 
        { label: 'cu_Cancel', eventDetails: { subtitle: 'cu_BookingCancellation', listType: 'stillNeedHelpCancel', showDynamicText: true, dynTextLabel: 'cu_BookingCancellationText', defineDynByPnr: false, flowType: 'cancel', param: [ 'cancelOption', 'isChangeableOnline' ], selectedAction: 'createCancelWithPNR' }, visibilitySettings: [ { isLastMinuteTicket: false } ] },  
        { label: 'cu_ClubEurostar', eventDetails: { subtitle: 'cu_ClubEurostar', listType: 'clubEurostar' } }, 
        { label: 'cu_SpecialAssistance', eventDetails: { listType: 'specialAssistanceWithPnr', subtitle: 'cu_SpecialAssistance' } }, 
        { label: 'cu_Question', eventDetails: { listType: 'askQuestion' } }, 
        { label: 'cu_AddSomething', eventDetails: { addSomething: true }, visibilitySettings: [ { isLastMinuteTicket: false } ] }, 
        { label: 'cu_ReportAProblem', eventDetails: { listType: 'reportProblem', subtitle: 'cu_ReportAProblemTitle' } }, 
        { label: 'cu_MakeANewBooking', eventDetails: { listType: 'makeBooking' }, visibilitySettings: [ { isLastMinuteTicket: false } ] }, 
        { label: 'cu_Disruption', eventDetails: {subtitle: 'cu_Disruption', listType: 'disruptionQuestions'}},
        { label: 'cu_GiveFeedback', eventDetails: { formType: '', listType: 'feedbackWithPnr', subtitle: 'cu_WhatIsYourFeedbackAbout' } }, 
        { label: 'cu_DataRequest', eventDetails: { showDynamicText: true, dynTextLabel: 'cu_DataRequestsWithRedirectToGDPRForm', subtitle: 'cu_DataRequest' } }, 
        { label: 'cu_Doc_Request_Button', eventDetails: { subtitle: 'cu_Doc_Request_Button', listType: 'docRequestsWithPNR' } },
        { label: 'cu_SmthWeHaventThoughtOf', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_PleaseEnterYourQuestionBelow', showUploader: true, selectedAction: 'createElseQuestionCase'}},
    ],
    exchangeApproval: [
        {label: 'cu_Yes', eventDetails: {subtitle: 'cu_BookingChanges', showDynamicText: true, dynTextLabel: 'cu_BookingChangesText', defineDynByPnr: false, flowType: 'change', param: 'isChangeableOnline', listType: 'stillNeedHelpChange'}},
        {label: 'cu_No', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_EndOfFlowMessage'}},
    ],
    cancelApproval: [
        {label: 'cu_Yes', eventDetails: {subtitle: 'cu_BookingCancellation', showDynamicText: true, dynTextLabel: 'cu_BookingCancellationText', defineDynByPnr: false, flowType: 'cancel', param: 'isChangeableOnline', listType: 'stillNeedHelpCancel'}},
        {label: 'cu_No', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_EndOfFlowMessage'}},
    ],
    stillNeedHelpChange: [
        {label: 'cu_StillNeedHelp', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_GiveInformationWhatToChangeInBooking', selectedAction: 'createChangeWithPNR'}},
    ],
    stillNeedHelpCancel: [
        {label: 'cu_StillNeedAssistance', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_GiveInformationWhatToDoWithBooking', selectedAction: 'createCancelWithPNR'}},
    ],
    specialAssistanceNoPnr: [
        {label: 'cu_UrgentSpecialAssistance', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Urgent_Assistance_1_1,cu_Urgent_Assistance_1_2', subtitle: 'cu_WhenYouPlanToTravel', inputData: [{inputType: 'date', inputLabelName: 'cu_TravelDate', inputName: 'dateOfTravel', nextStepKey: 'afterDateEnter'}], selectedAction: 'createSpecialAssistanceCase'}},
        {label: 'cu_SpecialAssistance', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Special_Assistance_1_1,cu_Special_Assistance_1_2', subtitle: 'cu_WhenYouPlanToTravel', inputData: [{inputType: 'date', inputLabelName: 'cu_TravelDate', inputName: 'dateOfTravel', nextStepKey: 'afterDateEnter'}], selectedAction: 'createSpecialAssistanceCase'}},
        {label: 'cu_WheelchairTravel', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Special_Assistance_2_1,cu_Special_Assistance_2_2', subtitle: 'cu_WhenYouPlanToTravel', inputData: [{inputType: 'date', inputLabelName: 'cu_TravelDate', inputName: 'dateOfTravel', nextStepKey: 'afterDateEnter'}], selectedAction: 'createSpecialAssistanceCase'}},
        {label: 'cu_AssistanceAnimals', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Special_Assistance_3_1,cu_Special_Assistance_3_2', subtitle: 'cu_WhenYouPlanToTravel', inputData: [{inputType: 'date', inputLabelName: 'cu_TravelDate', inputName: 'dateOfTravel', nextStepKey: 'afterDateEnter'}], selectedAction: 'createSpecialAssistanceCase'}},
        {label: 'cu_TravellingWithChildren', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Special_Travel_Needs_1', subtitle: 'cu_TravellingWithChildren', listType: 'stillHaveQuestionsAssist', btnListLabel: 'cu_StillWouldLikeToAskQuestion'}},
        {label: 'cu_UnaccompaniedMinors', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Special_Travel_Needs_2', subtitle: 'cu_UnaccompaniedMinors', listType: 'stillHaveQuestionsAssist', btnListLabel: 'cu_StillWouldLikeToAskQuestion'}},
        {label: 'cu_SpecialistLuggage', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Special_Travel_Needs_3', subtitle: 'cu_SpecialistLuggage', listType: 'stillHaveQuestionsAssist', btnListLabel: 'cu_StillWouldLikeToAskQuestion'}},
    ],
    specialAssistanceWithPnr: [ // needs to be checked
        {label: 'cu_UrgentSpecialAssistance', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Urgent_Assistance_1_1,cu_Urgent_Assistance_1_2', midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_PleaseEnterYourQuestionBelow', showUploader: true, selectedAction: 'createSpecialAssistanceCase'}},
        {label: 'cu_SpecialAssistance', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Special_Assistance_1_1,cu_Special_Assistance_1_2', midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_PleaseEnterYourQuestionBelow', showUploader: true, selectedAction: 'createSpecialAssistanceCase'}},
        {label: 'cu_WheelchairTravel', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Special_Assistance_2_1,cu_Special_Assistance_2_2', midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_PleaseEnterYourQuestionBelow', showUploader: true, selectedAction: 'createSpecialAssistanceCase'}},
        {label: 'cu_AssistanceAnimals', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Special_Assistance_3_1,cu_Special_Assistance_3_2', midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_PleaseEnterYourQuestionBelow', showUploader: true, selectedAction: 'createSpecialAssistanceCase'}},
        {label: 'cu_TravellingWithChildren', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Special_Travel_Needs_1', subtitle: 'cu_TravellingWithChildren', listType: 'stillHaveQuestionsAssist', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createSpecialAssistanceCase'}},
        {label: 'cu_UnaccompaniedMinors', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Special_Travel_Needs_2', subtitle: 'cu_UnaccompaniedMinors', listType: 'stillHaveQuestionsAssist', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createSpecialAssistanceCase'}, visibilitySettings: [ { isLastMinuteTicket: false } ]},
        {label: 'cu_SpecialistLuggage', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Special_Travel_Needs_3', subtitle: 'cu_SpecialistLuggage', listType: 'stillHaveQuestionsAssist', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createSpecialAssistanceCase'}},
    ],
    makeBooking: [
        {label: 'cu_OneToNinePassengers', eventDetails: {subtitle: 'cu_MakeBookingOnWebsiteQuestion', listType: 'makeBookingOnWebsite', showDynamicText: true, dynTextLabel: 'cu_Make_A_Booking_1', selectedAction: 'createMakeBookingCase'}},
        {label: 'cu_TenOrMore', eventDetails: {redirectUrl: 'cu_GroupsLink', selectedAction: 'createMakeBookingCase'}},
    ],
    makeBookingOnWebsite: [
        {label: 'cu_NoINeedMoreAssistance', eventDetails: {listType: 'needMoreAssistance', subtitle: 'cu_WhatWouldYouLikeToDo', selectedAction: 'createMakeBookingCase'}},
        {label: 'cu_YesPleaseTakeMeThere', eventDetails: {redirectUrl: 'cu_WebsiteLink'}},
    ],
    askQuestion: [
        {label: 'cu_TravelInfo', eventDetails: {listType: 'travelInfo', subtitle: 'cu_TravelInfo'}},
        {label: 'cu_TicketConditions', eventDetails: {listType: 'ticketConditions', subtitle: 'cu_TicketConditions'}},
        {label: 'cu_Stations', eventDetails: { subtitle: 'cu_Stations', listType: 'countriesList', btnListLabel: 'cu_WhichStation'}},
        {label: 'cu_Onboard', eventDetails: {listType: 'onboardQuestions', subtitle: 'cu_Onboard'}},
        {label: 'cu_LuggageAndBikes', eventDetails: {listType: 'travelToFromUK', subtitle: 'cu_Travelling_to_from_UK'}},
        {label: 'cu_Website', eventDetails: {listType: 'websiteQuestions', subtitle: 'cu_Website'}},
        {label: 'cu_DocumentsAndPaperWork', eventDetails: {listType: 'documentsAndPaperwork', subtitle: 'cu_DocumentsAndPaperwork'}},
        {label: 'cu_Vouchers', eventDetails: {listType: 'vouchersQuestions', subtitle: 'cu_Vouchers'}},
    ],
    travelInfo: [
        {label: 'cu_TimetableInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Timetable_Info_1', subtitle: 'cu_TimetableInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createTravelQuestionCase'}},
        {label: 'cu_Destinations',  eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Destination_Info_1', subtitle: 'cu_Destinations', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createTravelQuestionCase'}},
        {label: 'cu_LiveDeparturesAndArrivals',  eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Live_Trains_1', subtitle: 'cu_LiveDeparturesAndArrivals', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createTravelQuestionCase'}},
        {label: 'cu_ConnectingTravel',  eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Connecting_Info_1', subtitle: 'cu_ConnectingTravel', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createTravelQuestionCase'}},
        {label: 'cu_Brexit',  eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Brexit_Info_1', subtitle: 'cu_Brexit', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createTravelQuestionCase'}},
        {label: 'cu_GettingYourTickets',  eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Ticket_Collection_1', subtitle: 'cu_GettingYourTickets', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createTravelQuestionCase'}},
    ],
    stillHaveQuestions: [
        {label: 'cu_Yes', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_PleaseEnterYourQuestionBelow', showUploader: true}},
        {label: 'cu_No', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_EndOfFlowMessage'}},
    ],
    stillHaveQuestionsAssist: [
        {label: 'cu_Yes', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_PleaseEnterYourQuestionBelow', showUploader: true, selectedAction: 'createSpecialAssistanceCase'}},
        {label: 'cu_No', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_EndOfFlowMessage'}},
    ],
    stillHaveQuestionDocs: [
        {label: 'cu_Yes', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_PleaseEnterYourQuestionBelow', showUploader: true, selectedAction: 'createDocRequestCase'}},
        {label: 'cu_No', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_EndOfFlowMessage'}},
    ],
    needMoreAssistance: [
        {label: 'cu_ReportAProblem', eventDetails: {listType: 'reportProblem', subtitle: 'cu_ReportAProblemTitle'}},
        {label: 'cu_HelpMakeBooking', eventDetails: {subtitle: 'cu_SelectDatesYouWishToTravel', inputData: [{inputType: 'date', inputLabelName: 'cu_TravelDate', inputName: 'dateOfTravel', nextStepKey: 'travelFromBooking'}]}},
    ],
    reportProblem: [
        {label: 'cu_OnOurWebsite', eventDetails: {listType: 'typeOfProblem', subtitle: 'cu_WhatTypeOfProblemDidYouExperience'}},
        {label: 'cu_OnOurApp', eventDetails: {listType: 'typeOfProblem', subtitle: 'cu_WhatTypeOfProblemDidYouExperience'}},
        {label: 'cu_OverThePhone', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, subtitle: 'cu_TellMoreAboutYourProblem', selectedAction: 'createReportAProblemFeedbackCase'}},
        {label: 'cu_OnYourJourney', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, subtitle: 'cu_TellMoreAboutYourProblem', selectedAction: 'createReportAProblemFeedbackCase'}},
        {label: 'cu_SomewhereElse', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, subtitle: 'cu_TellMoreAboutYourProblem', selectedAction: 'createReportAProblemFeedbackCase'}},
    ],
    typeOfProblem: [
        {label: 'cu_ProblemsMakingABooking', eventDetails: {subtitle: 'cu_IncludeErrorMessageLabel', inputData: [{inputLabelName: 'cu_ErrorMessage', inputName: 'errorMessage', inputPlaceholderName: 'cu_CommentPlaceholder', inputType: 'textarea', nextStepKey: 'errorMessage', submitLabelName: 'cu_Next'}], selectedAction: 'createReportAnErrorCase'}},
        {label: 'cu_ProblemsMakingAPayment', eventDetails: {subtitle: 'cu_IncludeErrorMessageLabel', inputData: [{inputLabelName: 'cu_ErrorMessage', inputPlaceholderName: 'cu_CommentPlaceholder', inputType: 'textarea', inputName: 'errorMessage', nextStepKey: 'errorMessage', submitLabelName: 'cu_Next'}], selectedAction: 'createReportAnErrorCase'}},
        {label: 'cu_ProblemsExchangingABooking', eventDetails: {subtitle: 'cu_IncludeErrorMessageLabel', inputData: [{inputLabelName: 'cu_ErrorMessage', inputPlaceholderName: 'cu_CommentPlaceholder', inputName: 'errorMessage', inputType: 'textarea', nextStepKey: 'errorMessage', submitLabelName: 'cu_Next'}], selectedAction: 'createReportAnErrorCase'}},
        {label: 'cu_ProblemsCancellingABooking', eventDetails: {subtitle: 'cu_IncludeErrorMessageLabel', inputData: [{inputLabelName: 'cu_ErrorMessage', inputPlaceholderName: 'cu_CommentPlaceholder', inputName: 'errorMessage', inputType: 'textarea', nextStepKey: 'errorMessage', submitLabelName: 'cu_Next'}], selectedAction: 'createReportAnErrorCase'}},
        {label: 'cu_ProblemsAccessingYourBooking', eventDetails: {subtitle: 'cu_IncludeErrorMessageLabel', inputData: [{inputLabelName: 'cu_ErrorMessage', inputPlaceholderName: 'cu_CommentPlaceholder', inputType: 'textarea', inputName: 'errorMessage', nextStepKey: 'errorMessage', submitLabelName: 'cu_Next'}], selectedAction: 'createReportAnErrorCase'}},
        {label: 'cu_SomethingElse', eventDetails: {subtitle: 'cu_IncludeErrorMessageLabel', inputData: [{inputLabelName: 'cu_ErrorMessage', inputPlaceholderName: 'cu_CommentPlaceholder', inputType: 'textarea', inputName: 'errorMessage', nextStepKey: 'errorMessage', submitLabelName: 'cu_Next'}], selectedAction: 'createReportAnErrorCase'}},
    ],
    ticketConditions: [
        {label: 'cu_GeneralTermsAndConditions', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Ticket_Conditions_1', subtitle: 'cu_GeneralTermsAndConditions', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createTicketConditionQuestionCase'}},
        {label: 'cu_Exchanges', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Ticket_Conditions_2', subtitle: 'cu_Exchanges', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createTicketConditionQuestionCase'}},
        {label: 'cu_CancellationsAndRefunds', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Ticket_Conditions_3', subtitle: 'cu_CancellationsAndRefunds', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createTicketConditionQuestionCase'}},
        {label: 'cu_TransferTicketQuestion', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Ticket_Conditions_4', subtitle: 'cu_TransferTicketQuestion', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createTicketConditionQuestionCase'}},
    ],
    stationQuestions: [
        {label: 'cu_GeneralTermsAndConditions', eventDetails: {listType: 'stationQuestions', selectedAction: 'createStationsQuestionCase'}},
    ],
    onboardQuestions: [
        {label: 'cu_Seating', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Onboard_1', subtitle: 'cu_Seating', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createOnboardQuestionCase'}},
        {label: 'cu_Catering', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Onboard_2', subtitle: 'cu_Catering', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createOnboardQuestionCase'}},
        {label: 'cu_TravelClasses', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Onboard_3', subtitle: 'cu_TravelClasses', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createOnboardQuestionCase'}},
        {label: 'cu_Wifi', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Onboard_4', subtitle: 'cu_Wifi', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createOnboardQuestionCase'}},
        {label: 'cu_SmthWeHaventThoughtOf', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_PleaseEnterYourQuestionBelow', selectedAction: 'createOnboardQuestionCase'}},
    ],
    luggageQuestions: [
        {label: 'cu_LuggageAllowance', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Luggage_1', subtitle: 'cu_LuggageAllowance', listType: 'stillHaveQuestions', btnListLabel:'cu_StillWouldLikeToAskQuestion', selectedAction: 'createLugageQuestionCase', topic: 'cu_LuggageAllowance'}},
        {label: 'cu_ProhibitedAndRestrictedItems', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Luggage_2', subtitle: 'cu_ProhibitedAndRestrictedItems', listType: 'stillHaveQuestions', btnListLabel:'cu_StillWouldLikeToAskQuestion', selectedAction: 'createLugageQuestionCase', topic: 'cu_ProhibitedAndRestrictedItems'}},
        {label: 'cu_GeneralInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Luggage_3', subtitle: 'cu_GeneralInformation', listType: 'stillHaveQuestions', btnListLabel:'cu_StillWouldLikeToAskQuestion', selectedAction: 'createLugageQuestionCase', topic: 'cu_GeneralInformation'}},
        {label: 'cu_TravelingWithBikes', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Luggage_4', subtitle: 'cu_TravelingWithBikes', listType: 'stillHaveQuestions', btnListLabel:'cu_StillWouldLikeToAskQuestion', selectedAction: 'createLugageQuestionCase', topic: 'cu_TravelingWithBikes'}},
        {label: 'cu_SpecialLuggage', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Luggage_5', subtitle: 'cu_SpecialLuggage', listType: 'stillHaveQuestions', btnListLabel:'cu_StillWouldLikeToAskQuestion', selectedAction: 'createLugageQuestionCase', topic: 'cu_SpecialLuggage'}},
        {label: 'cu_LostProperty', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Luggage_6', subtitle: 'cu_LostProperty', listType: 'whereDidYouLoseTheItem', btnListLabel:'cu_WhereDidYouLoseTheItem', selectedAction: 'createLugageQuestionCase', topic: 'cu_LostProperty'}},
    ],
    documentsAndPaperwork: [
        {label: 'cu_WhatDoINeedToTravel', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Travel_Docs_1', subtitle: 'cu_WhatDoINeedToTravel', listType: 'stillHaveQuestions', btnListLabel:'cu_StillWouldLikeToAskQuestion', selectedAction: 'createDocsQuestionCase'}},
        {label: 'cu_NamesAndOtherPersonalDetails', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Travel_Docs_2', subtitle: 'cu_NamesAndOtherPersonalDetails', listType: 'stillHaveQuestions', btnListLabel:'cu_StillWouldLikeToAskQuestion', selectedAction: 'createDocsQuestionCase'}},
        {label: 'cu_SmthWeHaventThoughtOf', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_PleaseEnterYourQuestionBelow', selectedAction: 'createDocsQuestionCase'}},
    ],
    vouchersQuestions: [
        {label: 'cu_IWouldLikeToPurchaseGiftVouchers', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Vouchers_1', subtitle: 'cu_IWouldLikeToPurchaseGiftVouchers', listType: 'stillHaveQuestions', btnListLabel:'cu_StillWouldLikeToAskQuestion', selectedAction: 'createVoucherQuestionCase'}},
        {label: 'cu_HowDoIUseMyVoucher', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Vouchers_2', subtitle: 'cu_HowDoIUseMyVoucher', listType: 'stillHaveQuestions', btnListLabel:'cu_StillWouldLikeToAskQuestion', selectedAction: 'createVoucherQuestionCase'}},
        {label: 'cu_ProblemsWithAnExistingVoucher', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Vouchers_3', subtitle: 'cu_ProblemsWithAnExistingVoucher', listType: 'stillHaveQuestions', btnListLabel:'cu_StillWouldLikeToAskQuestion', selectedAction: 'createVoucherQuestionCase'}},
        {label: 'cu_IHaveLostMyVoucher', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Vouchers_4', subtitle: 'cu_IHaveLostMyVoucher', listType: 'stillHaveQuestions', btnListLabel:'cu_StillWouldLikeToAskQuestion', selectedAction: 'createVoucherQuestionCase'}},
        {label: 'cu_SmthWeHaventThoughtOf', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_PleaseEnterYourQuestionBelow', selectedAction: 'createVoucherQuestionCase'}},
    ],
    websiteQuestions: [
        {label: 'cu_HelpFindingInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Website_Navigation_1_1,cu_Website_Navigation_1_2', subtitle: 'cu_HelpFindingInformation', listType: 'stillHaveQuestions', btnListLabel:'cu_StillWouldLikeToAskQuestion', inputData: [{inputLabelName: 'cu_PNR', inputPlaceholderName: 'cu_CommentPlaceholder', inputName: 'pnr', nextStepKey: ''}], selectedAction: 'createWebsiteQuestionCase'}},
        {label: 'cu_HelpDoingSomething', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Website_Navigation_2', subtitle: 'cu_HelpDoingSomething', listType: 'stillHaveQuestions', btnListLabel:'cu_StillWouldLikeToAskQuestion', selectedAction: 'createWebsiteQuestionCase'}},
        {label: 'cu_OnlineAccountHelp', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Online_Account_1', subtitle: 'cu_OnlineAccountHelp', listType: 'stillHaveQuestions', btnListLabel:'cu_StillWouldLikeToAskQuestion', selectedAction: 'createWebsiteQuestionCase'}},
        {label: 'cu_ReportAProblem', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Report_A_Problem_1', subtitle: 'cu_ReportAProblem', listType: 'stillHaveQuestions', btnListLabel:'cu_StillWouldLikeToAskQuestion', selectedAction: 'createWebsiteQuestionCase'}},
        {label: 'cu_ResetMyPassword', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Password_Reset_1', subtitle: 'cu_ResetMyPassword', listType: 'stillHaveQuestions', btnListLabel:'cu_StillWouldLikeToAskQuestion', selectedAction: 'createWebsiteQuestionCase'}},
    ],
    clubEurostar: [
        {label: 'cu_AlreadyAMember', eventDetails: {subtitle: 'cu_PleaseEnterMembershipNumber', inputData: [{inputLabelName: 'cu_MembershipNumber', inputPlaceholderName: 'cu_CommentPlaceholder', inputName: 'membershipNumber', nextStepKey: 'memberNumber', checkMembership: true}], selectedAction: 'createClubEurostarCase'}},
        {label: 'cu_ThinkingOfJoining', eventDetails: {subtitle: 'cu_ThinkingOfJoining', showDynamicText: true, dynTextLabel: 'cu_Loyalty_5', selectedAction: 'createClubEurostarCase'}},
        {label: 'cu_subscriptions', eventDetails: {subtitle: 'cu_subscriptions', listType: 'ctaButtonsList', showDynamicText: true, dynTextLabel: 'cu_SubscriptionsDynamic'}}
    ],
    clubHelp: [
        {label: 'cu_AccountQuery', eventDetails: {subtitle: 'cu_AccountQuery', showDynamicText: true, dynTextLabel: 'cu_Loyalty_1', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createClubEurostarCase'}},
        {label: 'cu_AddingJourneyOrMissingPoints', eventDetails: {subtitle: 'cu_AddingJourneyOrMissingPoints', showDynamicText: true, dynTextLabel: 'cu_Loyalty_2_1,cu_Loyalty_2_2', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createClubEurostarCase'}},
        {label: 'cu_ChangesToMyPersonalInformation', eventDetails: {subtitle: 'cu_ChangesToMyPersonalInformation', showDynamicText: true, dynTextLabel: 'cu_Loyalty_3', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createClubEurostarCase'}},
        {label: 'cu_TroubleAccessingMyAccount', eventDetails: {subtitle: 'cu_TroubleAccessingMyAccount', showDynamicText: true, dynTextLabel: 'cu_Loyalty_4', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createClubEurostarCase'}},
    ],
    ctaButtonsList: [
        {label: 'cu_subscriptions_CTAquestion', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_PleaseEnterYourQuestionBelow', showUploader: true, showDynamicText: true, dynTextLabel: 'cu_subscriptions_DynamicText1', selectedAction: 'createClubEurostarCase'}},
        {label: 'cu_subscriptions_CTArenewalOfPurchase', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_PleaseEnterYourQuestionBelow', showUploader: true, showDynamicText: true, dynTextLabel: 'cu_subscriptions_DynamicText2', selectedAction: 'createClubEurostarCase'}},
        {label: 'cu_subscriptions_CTAdocumentRequest', eventDetails: {showDynamicText: false, subtitle: 'cu_Doc_Request_Button', listType: 'docRequests'}}
    ],
    feedback: [
        {label: 'cu_Staff', eventDetails: {topic: 'cu_Staff', subtitle: 'cu_IfYouHaveBookingInclude', listType: 'skipStep', btnListLabel: 'cu_DontHaveBookingReference', inputData: [{inputLabelName: 'cu_PNR_Optional', inputPlaceholderName: 'cu_CommentPlaceholder', checkPNR: true, inputName: 'pnr', nextStepKey: 'pnrOptional'}]}},
        {label: 'cu_Station', eventDetails: {topic: 'cu_Station', subtitle: 'cu_IfYouHaveBookingInclude', listType: 'skipStep', btnListLabel: 'cu_DontHaveBookingReference', inputData: [{inputLabelName: 'cu_PNR_Optional', inputPlaceholderName: 'cu_CommentPlaceholder', inputName: 'pnr', checkPNR: true, nextStepKey: 'pnrOptional'}]}},
        {label: 'cu_Disruption', eventDetails: {topic: 'cu_Disruption', subtitle: 'cu_IfYouHaveBookingInclude', listType: 'skipStep', btnListLabel: 'cu_DontHaveBookingReference', inputData: [{inputLabelName: 'cu_PNR_Optional', inputPlaceholderName: 'cu_CommentPlaceholder', inputName: 'pnr', checkPNR: true, nextStepKey: 'pnrOptional'}]}},
        {label: 'cu_OnboardExperience', eventDetails: {topic: 'cu_OnboardExperience', subtitle: 'cu_IfYouHaveBookingInclude', listType: 'skipStep', btnListLabel: 'cu_DontHaveBookingReference', inputData: [{inputLabelName: 'cu_PNR_Optional', inputPlaceholderName: 'cu_CommentPlaceholder', inputName: 'pnr', checkPNR: true, nextStepKey: 'pnrOptional'}]}},
        {label: 'cu_Policy', eventDetails: {topic: 'cu_Policy', subtitle: 'cu_IfYouHaveBookingInclude', listType: 'skipStep', btnListLabel: 'cu_DontHaveBookingReference', inputData: [{inputLabelName: 'cu_PNR_Optional', inputPlaceholderName: 'cu_CommentPlaceholder', inputName: 'pnr', checkPNR: true, nextStepKey: 'pnrOptional'}]}},
        {label: 'cu_WebsiteOrApp', eventDetails: {topic: 'cu_WebsiteOrApp', subtitle: 'cu_IfYouHaveBookingInclude', listType: 'skipStep', btnListLabel: 'cu_DontHaveBookingReference', inputData: [{inputLabelName: 'cu_PNR_Optional', inputPlaceholderName: 'cu_CommentPlaceholder', inputName: 'pnr', checkPNR: true, nextStepKey: 'pnrOptional'}]}},
        {label: 'cu_Communication', eventDetails: {topic: 'cu_Communication', subtitle: 'cu_IfYouHaveBookingInclude', listType: 'skipStep', btnListLabel: 'cu_DontHaveBookingReference', inputData: [{inputLabelName: 'cu_PNR_Optional', inputPlaceholderName: 'cu_CommentPlaceholder', inputName: 'pnr', checkPNR: true, nextStepKey: 'pnrOptional'}]}},
        {label: 'cu_ClubEurostar', eventDetails: {topic: 'cu_ClubEurostar', subtitle: 'cu_IfYouHaveBookingInclude', listType: 'skipStep', btnListLabel: 'cu_DontHaveBookingReference', inputData: [{inputLabelName: 'cu_PNR_Optional', inputPlaceholderName: 'cu_CommentPlaceholder', inputName: 'pnr', checkPNR: true, nextStepKey: 'pnrOptional'}]}},
        {label: 'cu_SomethingElse', eventDetails: {subtitle: 'cu_IfYouHaveBookingInclude', listType: 'skipStep', btnListLabel: 'cu_DontHaveBookingReference', inputData: [{inputLabelName: 'cu_PNR_Optional', inputPlaceholderName: 'cu_CommentPlaceholder', inputName: 'pnr', checkPNR: true, nextStepKey: 'pnrOptional'}]}},
    ],
    feedbackWithPnr: [
        {label: 'cu_Staff', eventDetails: {subtitle: 'cu_EnterYourFeedBackBelow', showDynamicText: true, dynTextLabel: 'cu_Feedback_1', midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, selectedAction: 'createFeedbackCase'}},
        {label: 'cu_Station', eventDetails: {subtitle: 'cu_EnterYourFeedBackBelow', showDynamicText: true, dynTextLabel: 'cu_Feedback_1', midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, selectedAction: 'createFeedbackCase'}},
        {label: 'cu_Disruption', eventDetails: {subtitle: 'cu_EnterYourFeedBackBelow', showDynamicText: true, dynTextLabel: 'cu_Feedback_1', midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, selectedAction: 'createFeedbackCase'}},
        {label: 'cu_OnboardExperience', eventDetails: {subtitle: 'cu_EnterYourFeedBackBelow', showDynamicText: true, dynTextLabel: 'cu_Feedback_1', midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, selectedAction: 'createFeedbackCase'}},
        {label: 'cu_Policy', eventDetails: {subtitle: 'cu_EnterYourFeedBackBelow', showDynamicText: true, dynTextLabel: 'cu_Feedback_1', midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, selectedAction: 'createFeedbackCase'}},
        {label: 'cu_WebsiteOrApp', eventDetails: {subtitle: 'cu_EnterYourFeedBackBelow', showDynamicText: true, dynTextLabel: 'cu_Feedback_1', midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, selectedAction: 'createFeedbackCase'}},
        {label: 'cu_Communication', eventDetails: {subtitle: 'cu_EnterYourFeedBackBelow', showDynamicText: true, dynTextLabel: 'cu_Feedback_1', midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, selectedAction: 'createFeedbackCase'}},
        {label: 'cu_ClubEurostar', eventDetails: {subtitle: 'cu_EnterYourFeedBackBelow', showDynamicText: true, dynTextLabel: 'cu_Feedback_1', midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, selectedAction: 'createFeedbackCase'}},
        {label: 'cu_SomethingElse', eventDetails: {subtitle: 'cu_EnterYourFeedBackBelow', showDynamicText: true, dynTextLabel: 'cu_Feedback_1', midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, selectedAction: 'createFeedbackCase'}},
    ],
    feedbackType: [
        {label: 'cu_Praise', eventDetails: {subtitle: 'cu_EnterYourFeedBackBelow', showDynamicText: true, dynTextLabel: 'cu_Feedback_1', midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, selectedAction: 'createFeedbackCase'}},
        {label: 'cu_NeutralFeedback', eventDetails: {subtitle: 'cu_EnterYourFeedBackBelow', showDynamicText: true, dynTextLabel: 'cu_Feedback_1', midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, selectedAction: 'createFeedbackCase'}},
        {label: 'cu_Complaint', eventDetails: {subtitle: 'cu_EnterYourFeedBackBelow', showDynamicText: true, dynTextLabel: 'cu_Feedback_1', midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, selectedAction: 'createFeedbackCase'}},
    ],
    addSomething2: [
        {label: 'cu_Meals', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_WhatToAddToBooking', showUploader: true, showDynamicText: true, dynTextLabel: 'cu_Add_Meals_1', selectedAction: 'createAddSomethingCase'}},
        {label: 'cu_SeatPreference', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_WhatToAddToBooking', showUploader: true, showDynamicText: true, dynTextLabel: 'cu_Add_Seats_1', selectedAction: 'createAddSomethingCase'}},
        {label: 'cu_SomethingElse', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_WhatToAddToBooking', showUploader: true, selectedAction: 'createAddSomethingCase'}},
    ],
    addSomething3: [
        {label: 'cu_Meals', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_WhatToAddToBooking', showUploader: true, showDynamicText: true, dynTextLabel: 'cu_Add_Meals_2', selectedAction: 'createAddSomethingCase'}},
        {label: 'cu_SeatPreference', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_WhatToAddToBooking', showUploader: true, showDynamicText: true, dynTextLabel: 'cu_Add_Seats_2', selectedAction: 'createAddSomethingCase'}},
        {label: 'cu_SomethingElse', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_WhatToAddToBooking', showUploader: true, selectedAction: 'createAddSomethingCase'}},
    ],
    whereDidYouLoseTheItem: [
        {label: 'cu_LondonStPancras', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Lost_Property_1', subtitle: 'cu_LondonStPancras'}},
        {label: 'cu_Station_Paris_Gare_Du_Nord', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Lost_Property_2', subtitle: 'cu_Station_Paris_Gare_Du_Nord'}},
        {label: 'cu_Station_Brussels_Midi_Zuid', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Lost_Property_3', subtitle: 'cu_Station_Brussels_Midi_Zuid'}},
        {label: 'cu_Station_Lille_Europe', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Lost_Property_4', subtitle: 'cu_Station_Lille_Europe'}},
        {label: 'cu_Amsterdam_Or_Rotterdam', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Lost_Property_5', subtitle: 'cu_Amsterdam_Or_Rotterdam'}},
        {label: 'cu_Station_Disneyland_Paris', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Lost_Property_6_10', subtitle: 'cu_Station_Disneyland_Paris'}},
        {label: 'cu_Station_Calas_Frethun', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Lost_Property_6_10', subtitle: 'cu_Station_Calas_Frethun'}},
        {label: 'cu_Avignon', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Lost_Property_6_10', subtitle: 'cu_Avignon'}},
        {label: 'cu_Moutiers', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Lost_Property_6_10', subtitle: 'cu_Moutiers'}},
        {label: 'cu_BourgStMaurice', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Lost_Property_6_10', subtitle: 'cu_BourgStMaurice'}},
        {label: 'cu_OnboardOurTrains', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Lost_Property_Email', subtitle: 'cu_OnboardOurTrains'}}
    ],
    disruptionQuestions: [
        {label: 'cu_ClaimingCompensationForDisruption', eventDetails: {showDynamicText: true, listType: 'whatTypeOfClaimDoYouNeed', btnListLabel: 'cu_WhatTypeOfClaimDoYouNeed', subtitle: 'cu_ClaimingCompensationForDisruption', selectedAction: 'createDisruptionQuestionCase', topic: 'cu_ClaimingCompensationForDisruption'}},
        {label: 'cu_HelpWithCurrentDisruption', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Current_Disruption_1', subtitle: 'cu_HelpWithCurrentDisruption', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createDisruptionQuestionCase', topic: 'cu_HelpWithCurrentDisruption'}},
        {label: 'cu_CoronavirusDisruption', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Covid_1', subtitle: 'cu_CoronavirusDisruption', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createDisruptionQuestionCase', topic: 'cu_CoronavirusDisruption'}},
        {label: 'cu_FutureDisruptionInfo', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_SelectDateToKnowMore', subtitle: 'cu_FutureDisruptionInfo', topic: 'cu_FutureDisruptionInfo', inputData: [{inputType: 'date', inputLabelName: 'cu_TravelDate', inputName: 'dateOfTravel', nextStepKey: 'afterDateDisruptEnter'}]}},
    ],
    whatToDoNextDisruption: [
        {label: 'cu_IWouldLikeToMakeAClaim', eventDetails: {subtitle: 'cu_IfYouHaveBookingInclude', listType: 'skipStep', btnListLabel: 'cu_DontHaveBookingReference', isCompensationCheck: true, inputData: [{inputLabelName: 'cu_PNR_Optional', inputPlaceholderName: 'cu_CommentPlaceholder', checkPNR: true, inputName: 'pnr', nextStepKey: 'pnrOptional2'}]}},
        {label: 'cu_AskAQuestion', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_PleaseEnterYourQuestionBelow', showUploader: true}},
    ],
    whatTypeOfClaimFromBooking: [
        {label: 'cu_Expenses', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Expenses_1,cu_Expenses_Claim_Info_1,cu_ToHelpUsReimburseYouIncludeDetails', subtitle: 'cu_Expenses', listType: 'whereIsYourAccountHeld', btnListLabel: 'cu_WhereIsYourAccountHeld', selectedAction: 'createDisruptionQuestionCase'}},
        {label: 'cu_Compensation', eventDetails: {redirectUrl: 'cu_CompensationPageLink'}},
    ],
    whatTypeOfClaimDoYouNeed: [
        {label: 'cu_Expenses', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Expenses_1,cu_Expenses_Claim_Info_1,cu_ToHelpUsReimburseYouIncludeDetails', subtitle: 'cu_Expenses', listType: 'whereIsYourAccountHeld', btnListLabel: 'cu_WhereIsYourAccountHeld', selectedAction: 'createDisruptionQuestionCase'}},
        {label: 'cu_CompensationForDelay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Delay_Comp_1', subtitle: 'cu_CompensationForDelay', listType: 'whatToDoNextDisruption', btnListLabel: 'cu_WhatWouldYouLikeToDo', selectedAction: 'createDisruptionQuestionCase'}},
        {label: 'cu_CompensationForCancellation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Cancellation_Comp_1', subtitle: 'cu_CompensationForCancellation', listType: 'whatToDoNextDisruption', btnListLabel: 'cu_WhatWouldYouLikeToDo', selectedAction: 'createDisruptionQuestionCase'}},
    ],
    whereIsYourAccountHeld: [
        {label: 'cu_InTheEurozone', eventDetails: {subtitle: 'cu_InTheEurozone', inputData: [{inputLabelName: 'cu_IBAN', inputName: 'iban', inputPlaceholderName: 'cu_IBAN', inputType: 'textarea', nextStepKey: 'bicOrSwiftInput'}]}},
        {label: 'cu_InTheUK', eventDetails: {subtitle: 'cu_InTheUK', inputData: [{inputLabelName: 'cu_AccountNumber', inputPlaceholderName: 'cu_AccountNumber', inputName: 'accountNumber', nextStepKey: 'sortCode', regexp: `^[0-9]{8,8}$`}]}},
        {label: 'cu_OutsideOfEurope', eventDetails: {subtitle: 'cu_OutsideOfEurope', inputData: [{inputLabelName: 'cu_PayPalAccount', inputName: 'paypal', inputPlaceholderName: 'cu_PayPalAccount', inputType: 'textarea', nextStepKey: 'afterExpensesForms'}]}},
    ],
    existingCaseQuestion: [
        {label: 'cu_YesAddToExisting', eventDetails: {addToExisting: true}},
        {label: 'cu_NoCreateNewCase', eventDetails: {addToExisting: false}},
    ],
    existingCaseQuestion2: [
        {label: 'cu_YesAddToExisting', eventDetails: {subtitle: 'cu_PleaseEnterYourCommentBelow', inputData: [{inputLabelName: 'cu_YourComment', inputPlaceholderName: 'cu_CommentPlaceholder', inputType: 'textarea', inputName: 'comment', nextStepKey: 'afterCommentEnter'}]}},
        {label: 'cu_NoCreateNewCase', eventDetails: {subtitle: 'cu_UnderConstruction'}},
    ],
    skipStep: [
        {label: 'cu_SkipThisStep', eventDetails: {subtitle: 'cu_EnterYourFeedBackBelow', showDynamicText: true, dynTextLabel: 'cu_Feedback_1', midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, selectedAction: 'createFeedbackCase'
    }},
    ],
    skipStepDoc: [
        {label: 'cu_SkipThisStep', eventDetails: {subtitle: 'cu_HowWeCanHelp', midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, selectedAction: 'createDocRequestCase'}},
    ],
    skipStepDocNoPNR: [
        {label: 'cu_SkipThisStep', eventDetails: {subtitle: 'cu_HowWeCanHelp', showDynamicText: true, dynTextLabel: 'cu_PleaseIncludeInfo', midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, selectedAction: 'createDocRequestCase'}},
    ],
    skipStepToTCN: [
        {label: 'cu_SkipThisStep', eventDetails: {subtitle: 'cu_TCN_Input_Text', listType: 'skipStepDoc', btnListLabel: 'cu_DontHaveTCNReference', inputData: [{inputLabelName: 'cu_TCN', inputPlaceholderName: 'cu_CommentPlaceholder', checkTCN: true, inputName: 'tcn', nextStepKey: 'pnrOptionalDoc', addToExisting: false}]}},
    ],
    skipStepToTCNNoPNR: [
        {label: 'cu_SkipThisStep', eventDetails: {subtitle: 'cu_TCN_Input_Text', listType: 'skipStepDocNoPNR', btnListLabel: 'cu_DontHaveTCNReference', inputData: [{inputLabelName: 'cu_TCN', inputPlaceholderName: 'cu_CommentPlaceholder', checkTCN: true, inputName: 'tcn', nextStepKey: 'pnrOptionalDoc', addToExisting: false}]}},
    ],
    skipDepartureDateStepDisraptedPNR: [
        {label: 'cu_SkipThisStep', eventDetails: {title: 'cu_WeHaveFoundYourBooking', showDynamicText: true, dynTextLabel: 'cu_DisruptionDynamicText', listType: 'disruptedWithPNR', subtitle: 'cu_WhatWouldYouLikeToDo' }},
    ],
    skipDepartureDateStepNotDisraptedPNR: [
        {label: 'cu_SkipThisStep', eventDetails: {title: 'cu_WeHaveFoundYourBooking', listType: 'notDisruptedWithPNR', subtitle: 'cu_WhatWouldYouLikeToDo' }},
    ],
    skipDepartureDateStepDisraptedPNRExistingCase: [
        {label: 'cu_SkipThisStep', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_DisruptionDynamicText', listType: 'disruptedWithPNR', subtitle: 'cu_WhatWouldYouLikeToDo' }},
    ],
    skipDepartureDateStepNotDisraptedPNRExistingCase: [
        {label: 'cu_SkipThisStep', eventDetails: {listType: 'notDisruptedWithPNR', subtitle: 'cu_WhatWouldYouLikeToDo' }},
    ],
    futureDisruptionCountriesList: [
        {label: 'cu_United_Kingdom', eventDetails: {subtitle: 'cu_United_Kingdom', inputData: [{inputLabelName: 'cu_United_Kingdom', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'destination', required: 'true', selectedCountry: 'United Kingdom', nextStepKey: 'futureDisruptEnd'}], selectedAction: 'createDisruptionQuestionCase'}},
        {label: 'cu_France', eventDetails: {subtitle: 'cu_France', inputData: [{inputLabelName: 'cu_France', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'destination', required: 'true', selectedCountry: 'France', nextStepKey: 'futureDisruptEnd'}], selectedAction: 'createDisruptionQuestionCase'}},
        {label: 'cu_Belgium', eventDetails: {subtitle: 'cu_Belgium', inputData: [{inputLabelName: 'cu_Belgium', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'destination', required: 'true', selectedCountry: 'Belgium', nextStepKey: 'futureDisruptEnd'}], selectedAction: 'createDisruptionQuestionCase'}},
        {label: 'cu_Germany', eventDetails: {subtitle: 'cu_Germany', inputData: [{inputLabelName: 'cu_Germany', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'destination', required: 'true', selectedCountry: 'Germany', nextStepKey: 'futureDisruptEnd'}], selectedAction: 'createDisruptionQuestionCase'}},
        {label: 'cu_Netherlands', eventDetails: {subtitle: 'cu_Netherlands', inputData: [{inputLabelName: 'cu_Netherlands', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'destination', required: 'true', selectedCountry: 'Netherlands', nextStepKey: 'futureDisruptEnd'}], selectedAction: 'createDisruptionQuestionCase'}},
    ],
    travelFromCountriesList: [
        {label: 'cu_United_Kingdom', eventDetails: {subtitle: 'cu_United_Kingdom', inputData: [{inputLabelName: 'cu_United_Kingdom', inputPlaceholderName: 'cu_ChooseYourOrigin', inputType: 'select', inputName: 'origin', required: 'true', nextStepKey: 'travelToBooking'}]}},
        {label: 'cu_France', eventDetails: {subtitle: 'cu_France', inputData: [{inputLabelName: 'cu_France', inputPlaceholderName: 'cu_ChooseYourOrigin', inputType: 'select', inputName: 'origin', required: 'true', nextStepKey: 'travelToBooking'}]}},
        {label: 'cu_Belgium', eventDetails: {subtitle: 'cu_Belgium', inputData: [{inputLabelName: 'cu_Belgium', inputPlaceholderName: 'cu_ChooseYourOrigin', inputType: 'select', inputName: 'origin', required: 'true', nextStepKey: 'travelToBooking'}]}},
        {label: 'cu_Germany', eventDetails: {subtitle: 'cu_Germany', inputData: [{inputLabelName: 'cu_Germany', inputPlaceholderName: 'cu_ChooseYourOrigin', inputType: 'select', inputName: 'origin', required: 'true', nextStepKey: 'travelToBooking'}]}},
        {label: 'cu_Netherlands', eventDetails: {subtitle: 'cu_Netherlands', inputData: [{inputLabelName: 'cu_Netherlands', inputPlaceholderName: 'cu_ChooseYourOrigin', inputType: 'select', inputName: 'origin', required: 'true', nextStepKey: 'travelToBooking'}]}},
    ],
    travelToCountriesList: [
        {label: 'cu_United_Kingdom', eventDetails: {subtitle: 'cu_United_Kingdom', inputData: [{inputLabelName: 'cu_United_Kingdom', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'destination', required: 'true', nextStepKey: 'afterBookingDirection'}]}},
        {label: 'cu_France', eventDetails: {subtitle: 'cu_France', inputData: [{inputLabelName: 'cu_France', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'destination', required: 'true', nextStepKey: 'afterBookingDirection'}]}},
        {label: 'cu_Belgium', eventDetails: {subtitle: 'cu_Belgium', inputData: [{inputLabelName: 'cu_Belgium', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'destination', required: 'true', nextStepKey: 'afterBookingDirection'}]}},
        {label: 'cu_Germany', eventDetails: {subtitle: 'cu_Germany', inputData: [{inputLabelName: 'cu_Germany', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'destination', required: 'true', nextStepKey: 'afterBookingDirection'}]}},
        {label: 'cu_Netherlands', eventDetails: {subtitle: 'cu_Netherlands', inputData: [{inputLabelName: 'cu_Netherlands', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'destination', required: 'true', nextStepKey: 'afterBookingDirection'}]}},
    ],
    travelGroupFromCountriesList: [
        {label: 'cu_United_Kingdom', eventDetails: {subtitle: 'cu_United_Kingdom', inputData: [{inputLabelName: 'cu_United_Kingdom', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'origin', required: 'true', nextStepKey: 'travelToBookingGroup'}]}},
        {label: 'cu_France', eventDetails: {subtitle: 'cu_France', inputData: [{inputLabelName: 'cu_France', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'origin', required: 'true', nextStepKey: 'travelToBookingGroup'}]}},
        {label: 'cu_Belgium', eventDetails: {subtitle: 'cu_Belgium', inputData: [{inputLabelName: 'cu_Belgium', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'origin', required: 'true', nextStepKey: 'travelToBookingGroup'}]}},
        {label: 'cu_Germany', eventDetails: {subtitle: 'cu_Germany', inputData: [{inputLabelName: 'cu_Germany', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'origin', required: 'true', nextStepKey: 'travelToBookingGroup'}]}},
        {label: 'cu_Netherlands', eventDetails: {subtitle: 'cu_Netherlands', inputData: [{inputLabelName: 'cu_Netherlands', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'origin', required: 'true', nextStepKey: 'travelToBookingGroup'}]}},
    ],
    travelGroupToCountriesList: [
        {label: 'cu_United_Kingdom', eventDetails: {subtitle: 'cu_United_Kingdom', inputData: [{inputLabelName: 'cu_United_Kingdom', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'destination', required: 'true', nextStepKey: 'returnOrSingle'}]}},
        {label: 'cu_France', eventDetails: {subtitle: 'cu_France', inputData: [{inputLabelName: 'cu_France', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'destination', required: 'true', nextStepKey: 'returnOrSingle'}]}},
        {label: 'cu_Belgium', eventDetails: {subtitle: 'cu_Belgium', inputData: [{inputLabelName: 'cu_Belgium', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'destination', required: 'true', nextStepKey: 'returnOrSingle'}]}},
        {label: 'cu_Germany', eventDetails: {subtitle: 'cu_Germany', inputData: [{inputLabelName: 'cu_Germany', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'destination', required: 'true', nextStepKey: 'returnOrSingle'}]}},
        {label: 'cu_Netherlands', eventDetails: {subtitle: 'cu_Netherlands', inputData: [{inputLabelName: 'cu_Netherlands', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'destination', required: 'true', nextStepKey: 'returnOrSingle'}]}},
    ],
    countriesList: [
        {label: 'cu_United_Kingdom', eventDetails: {subtitle: 'cu_United_Kingdom', listType: 'ukStationsList', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_France', eventDetails: {subtitle: 'cu_France', listType: 'franceStationsList', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Belgium', eventDetails: {subtitle: 'cu_Belgium', listType: 'belgiumStationsList', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Germany', eventDetails: {subtitle: 'cu_Germany', listType: 'germanyStationsList', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Netherlands', eventDetails: {subtitle: 'cu_Netherlands', listType: 'netherlandsStationsList', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_SomewhereElse', eventDetails: {subtitle: 'cu_SomewhereElse', showDynamicText: true, dynTextLabel: 'cu_Other_Stations_1', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createStationsQuestionCase'}},
    ],
    ukStationsList: [
        {label: 'cu_Station_St_Pancras_International', eventDetails: {subtitle: 'cu_Station_St_Pancras_International', listType: 'stationQuestions1', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Ashford_International', eventDetails: {subtitle: 'cu_Station_Ashford_International', listType: 'stationQuestions2', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Ebbsfleet', eventDetails: {subtitle: 'cu_Station_Ebbsfleet', listType: 'stationQuestions3', selectedAction: 'createStationsQuestionCase'}},
    ],
    franceStationsList: [
        {label: 'cu_Station_Albertville', eventDetails: {subtitle: 'cu_Station_Albertville', listType: 'stationQuestions12', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Aime_La_Plagne', eventDetails: {subtitle: 'cu_Station_Aime_La_Plagne', listType: 'stationQuestions13', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Aix_en_Provence', eventDetails: {subtitle: 'cu_Station_Aix_en_Provence', listType: 'stationQuestions14', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Avignon', eventDetails: {subtitle: 'cu_Avignon', listType: 'stationQuestions15', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_BourgStMaurice', eventDetails: {subtitle: 'cu_BourgStMaurice', listType: 'stationQuestions16', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Calas_Frethun', eventDetails: {subtitle: 'cu_Station_Calas_Frethun', listType: 'stationQuestions17', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Chambery', eventDetails: {subtitle: 'cu_Station_Chambery', listType: 'stationQuestions18', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Disneyland_Paris', eventDetails: {subtitle: 'cu_Station_Disneyland_Paris', listType: 'stationQuestions9', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Landry', eventDetails: {subtitle: 'cu_Station_Landry', listType: 'stationQuestions19', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Lille_Europe', eventDetails: {subtitle: 'cu_Station_Lille_Europe', listType: 'stationQuestions7', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Lyon_Part_Dieu', eventDetails: {subtitle: 'cu_Station_Lyon_Part_Dieu', listType: 'stationQuestions10', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Marseilles', eventDetails: {subtitle: 'cu_Station_Marseilles', listType: 'stationQuestions20', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Moutiers', eventDetails: {subtitle: 'cu_Moutiers', listType: 'stationQuestions21', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Paris_Charles_de_Gaulle_Airport', eventDetails: {subtitle: 'cu_Station_Paris_Charles_de_Gaulle_Airport', listType: 'stationQuestions22', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Paris_Gare_Du_Nord', eventDetails: {subtitle: 'cu_Station_Paris_Gare_Du_Nord', listType: 'stationQuestions4', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Valence', eventDetails: {subtitle: 'cu_Station_Valence', listType: 'stationQuestions23', selectedAction: 'createStationsQuestionCase'}},
    ],
    belgiumStationsList: [
        {label: 'cu_Station_Antwerp', eventDetails: {subtitle: 'cu_Station_Antwerp', listType: 'stationQuestions24', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Brussels_Midi_Zuid', eventDetails: {subtitle: 'cu_Station_Brussels_Midi_Zuid', listType: 'stationQuestions5', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Liege', eventDetails: {subtitle: 'cu_Station_Liege', listType: 'stationQuestions25', selectedAction: 'createStationsQuestionCase'}},
    ],
    germanyStationsList: [
        {label: 'cu_Station_Aachen', eventDetails: {subtitle: 'cu_Station_Aachen', listType: 'stationQuestions26', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Cologne', eventDetails: {subtitle: 'cu_Station_Cologne', listType: 'stationQuestions27', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Duisburg', eventDetails: {subtitle: 'cu_Station_Duisburg', listType: 'stationQuestions28', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Dortmund', eventDetails: {subtitle: 'cu_Station_Dortmund', listType: 'stationQuestions29', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Dusseldorf', eventDetails: {subtitle: 'cu_Station_Dusseldorf', listType: 'stationQuestions30', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Dusseldorf_Airport', eventDetails: {subtitle: 'cu_Station_Dusseldorf_Airport', listType: 'stationQuestions31', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Essen', eventDetails: {subtitle: 'cu_Station_Essen', listType: 'stationQuestions32', selectedAction: 'createStationsQuestionCase'}},
    ],
    netherlandsStationsList: [
        {label: 'cu_Station_Amsterdam_Centraal', eventDetails: {subtitle: 'cu_Station_Amsterdam_Centraal', listType: 'stationQuestions6', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Rotterdam_Centraal', eventDetails: {subtitle: 'cu_Station_Rotterdam_Centraal', listType: 'stationQuestions8', selectedAction: 'createStationsQuestionCase'}},
        {label: 'cu_Station_Schiphol_Airport', eventDetails: {subtitle: 'cu_Station_Schiphol_Airport', listType: 'stationQuestions33', selectedAction: 'createStationsQuestionCase'}},
    ],
    stationQuestions1: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_St_Pancras_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.ST_PANCRAS_INTERNATIONAL}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_St_Pancras_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.ST_PANCRAS_INTERNATIONAL}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.ST_PANCRAS_INTERNATIONAL}},
    ],
    stationQuestions2: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Ashford_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.ASHFORD_INTERNATIONAL}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Ashford_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.ASHFORD_INTERNATIONAL}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.ASHFORD_INTERNATIONAL}},
    ],
    stationQuestions3: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Ebbsfleet_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.EBBSFLEET_INTERNATIONAL}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Ebbsfleet_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.EBBSFLEET_INTERNATIONAL}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.EBBSFLEET_INTERNATIONAL}},
    ],
    stationQuestions4: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Paris_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.PARIS_GARE_DU_NORD}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Paris_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.PARIS_GARE_DU_NORD}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.PARIS_GARE_DU_NORD}},
    ],
    stationQuestions5: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Brussels_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.BRUSSELS_MIDI_ZUID}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Brussels_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.BRUSSELS_MIDI_ZUID}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.BRUSSELS_MIDI_ZUID}},
    ],
    stationQuestions6: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Amsterdam_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.AMSTERDAM_CENTRAAL}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Amsterdam_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.AMSTERDAM_CENTRAAL}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.AMSTERDAM_CENTRAAL}},
    ],
    stationQuestions7: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Lille_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.LILLE_EUROPE}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Lille_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.LILLE_EUROPE}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.LILLE_EUROPE}},
    ],
    stationQuestions8: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Rotterdam_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.ROTTERDAM_CENTRAAL}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Rotterdam_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.ROTTERDAM_CENTRAAL}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.ROTTERDAM_CENTRAAL}},
    ],
    stationQuestions9: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Disney_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.DISNEYLAND_PARIS}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Disney_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.DISNEYLAND_PARIS}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.DISNEYLAND_PARIS}},
    ],
    stationQuestions10: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Lyon_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.LYON_PART_DIEU}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Lyon_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.LYON_PART_DIEU}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.LYON_PART_DIEU}},
    ],
    stationQuestions12: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Albertville_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.ALBERTVILLE}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Albertville_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.ALBERTVILLE}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.ALBERTVILLE}},
    ],
    stationQuestions13: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Aime_La_Plagne_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.AIME_LA_PLAGNE}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Aime_La_Plagne_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.AIME_LA_PLAGNE}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.AIME_LA_PLAGNE}},
    ],
    stationQuestions14: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Aix_en_Provence_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.AIX_EN_PROVENCE}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Aix_en_Provence_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.AIX_EN_PROVENCE}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.AIX_EN_PROVENCE}},
    ],
    stationQuestions15: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Avignon_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.AVIGNON}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Avignon_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.AVIGNON}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.AVIGNON}},
    ],
    stationQuestions16: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Bourg_St_Maurice_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.BOURG_SAINT_MAURICE}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Bourg_St_Maurice_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.BOURG_SAINT_MAURICE}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.BOURG_SAINT_MAURICE}},
    ],
    stationQuestions17: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Calas_Frethun_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.CALAS_FRETHUN}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Calas_Frethun_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.CALAS_FRETHUN}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.CALAS_FRETHUN}},
    ],
    stationQuestions18: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Chambery_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.CHAMBERY}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Chambery_1', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.CHAMBERY}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.CHAMBERY}},
    ],
    stationQuestions19: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Landry_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.LANDRY}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Landry_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.LANDRY}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.LANDRY}},
    ],
    stationQuestions20: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Marseilles_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.MARSEILLES}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Marseilles_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.MARSEILLES}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.MARSEILLES}},
    ],
    stationQuestions21: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Moutiers_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.MOUTIERS}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Moutiers_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.MOUTIERS}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.MOUTIERS}},
    ],
    stationQuestions22: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Paris_Charles_de_Gaulle_Airport_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.PARIS_CHARLES_DE_GAULLE_AIRPORT}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Paris_Charles_de_Gaulle_Airport_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.PARIS_CHARLES_DE_GAULLE_AIRPORT}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.PARIS_CHARLES_DE_GAULLE_AIRPORT}},
    ],
    stationQuestions23: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Valence_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.VALENCE}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Valence_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.VALENCE}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.VALENCE}},
    ],
    stationQuestions24: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Antwerp_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.ANTWERP}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Antwerp_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.ANTWERP}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.ANTWERP}},
    ],
    stationQuestions25: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Liege_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.LIEGE}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Liege_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.LIEGE}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.LIEGE}},
    ],
    stationQuestions26: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Aachen_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.AACHEN}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Aachen_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.AACHEN}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.AACHEN}},
    ],
    stationQuestions27: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Cologne_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.COLOGNE}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Cologne_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.COLOGNE}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.COLOGNE}},
    ],
    stationQuestions28: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Duisburg_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.DUISBURG}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Duisburg_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.DUISBURG}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.DUISBURG}},
    ],
    stationQuestions29: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Dortmund_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.DORTMUND}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Dortmund_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.DORTMUND}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.DORTMUND}},
    ],
    stationQuestions30: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Dusseldorf_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.DUSSELDORF}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Dusseldorf_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.DUSSELDORF}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.DUSSELDORF}},
    ],
    stationQuestions31: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Dusseldorf_Airport_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.DUSSELDORF_AIRPORT}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Dusseldorf_Airport_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.DUSSELDORF_AIRPORT}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.DUSSELDORF_AIRPORT}},
    ],
    stationQuestions32: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Essen_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.ESSEN}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Essen_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.ESSEN}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.ESSEN}},
    ],
    stationQuestions33: [
        {label: 'cu_WhatToExpect', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Schiphol_Airport_1', subtitle: 'cu_WhatToExpect', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.SCHIPHOL_AIRPORT}},
        {label: 'cu_FindingYourWay', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Station_Schiphol_Airport_2', subtitle: 'cu_FindingYourWay', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.SCHIPHOL_AIRPORT}},
        {label: 'cu_MoreInformation', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Generic_Station_Info_1', subtitle: 'cu_MoreInformation', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', topic: 'cu_Case_Topic_Station_Information', whatIsTheQuestion: CASE_WHAT_IS_THE_QUESTION.SCHIPHOL_AIRPORT}},
    ],
    initialGroupBooking: [
        {label: 'cu_StepByStepBooking', eventDetails: {subtitle: 'cu_SelectDatesYouWishToTravel', inputData: [
            {inputType: 'date', inputLabelName: 'cu_TravelDate', inputName: 'dateOfTravel', nextStepKey: 'travelFromBookingGroup', showButton: false},
            {inputType: 'select', inputLabelName: 'cu_Time', inputName: 'timeOfTravel', nextStepKey: 'travelFromBookingGroup'}
        ]}},
        {label: 'cu_BookWithSpreadsheet', eventDetails: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_AdditionalInfoSpreadsheet', showUploader: true, selectedAction: 'createB2BBookingCaseFromSpreadsheet', b2bForm: true}},
    ],
    returnOrSingleYesNo: [
        {label: 'cu_Yes', eventDetails:{subtitle: 'cu_SelectDateOfReturn', inputData: [
            {inputType: 'date', inputLabelName: 'cu_TravelDate', inputName: 'dateOfReturn', nextStepKey: 'passengerDetails', showButton: false},
            {inputType: 'select', inputLabelName: 'cu_Time', inputName: 'timeOfReturn', nextStepKey: 'passengerDetails'}
        ]}},
        {label: 'cu_No', eventDetails: {subtitle: 'cu_NumberOfPassengers', inputData: [
            {inputLabelName: 'cu_AdultPassengers', inputName: 'adultPassengers', inputPlaceholderName: 'cu_NumberPlaceholder', inputType: 'number', showButton: false, required: 'true'},
            {inputLabelName: 'cu_ChildPassengers', inputName: 'childrenPassengers', inputPlaceholderName: 'cu_NumberPlaceholder', inputType: 'number', showButton: false},
            {inputLabelName: 'cu_InfantPassengers', inputName: 'infantsPassengers', inputPlaceholderName: 'cu_NumberPlaceholder', inputType: 'number', nextStepKey: 'serviceClass'}
        ]}},
    ],
    specialAssistance: [
        {label: 'cu_Yes', eventDetails: {subtitle: 'cu_SpecialAssistancePicklist', inputData: [
            {inputLabelName: 'cu_Catering', inputName: 'assistanceCatering', inputType: 'checkbox', showButton: false, showForAll: true},
            {inputLabelName: 'cu_Luggage', inputName: 'assistanceLuggage', inputType: 'checkbox', showButton: false, showForAll: false},
            {inputLabelName: 'cu_Branding', inputName: 'assistanceBranding', inputType: 'checkbox', showButton: false, showForAll: false},
            {inputLabelName: 'cu_OnboardExperience', inputName: 'assistanceExperience', inputType: 'checkbox', showButton: false, showForAll: false},
            {inputLabelName: 'cu_ExclusiveCarriage', inputName: 'assistanceCarriage', inputType: 'checkbox', showButton: false, showForAll: false},
            {inputLabelName: 'cu_HalfCharter', inputName: 'assistanceHalfcharter', inputType: 'checkbox', showButton: false, showForAll: false},
            {inputLabelName: 'cu_Charter', inputName: 'assistanceCharter', inputType: 'checkbox', nextStepKey: 'companyNameInput', showForAll: true}
        ]}},
        {label: 'cu_No', eventDetails:{subtitle: 'cu_CompanyNameText', inputData: [
            {inputLabelName: 'cu_CompanyName', inputName: 'companyName', inputPlaceholderName: 'cu_CompanyName', inputType: 'text', nextStepKey: 'showEndForm', required: 'true'}]}},
    ],
    docRequests: [
        {label: 'cu_Subscriptions_Docs', eventDetails: {subtitle: 'cu_Subscriptions_Docs', listType: 'docSubscription'}},
        {label: 'cu_Proof_of_Travel_Docs', eventDetails: {subtitle: 'cu_Proof_of_Travel_Docs', listType: 'docProof'}},
        {label: 'cu_Booking_Confirmation_Docs', eventDetails: {subtitle: 'cu_Booking_Confirmation_Docs', listType: 'docBooking'}}
    ],
    docRequestsWithPNR: [
        {label: 'cu_Subscriptions_Docs', eventDetails: {subtitle: 'cu_Subscriptions_Docs', listType: 'docSubscription'}},
        {label: 'cu_Proof_of_Travel_Docs', eventDetails: {subtitle: 'cu_Proof_of_Travel_Docs', listType: 'docProofWithPNR'}},
        {label: 'cu_Booking_Confirmation_Docs', eventDetails: {subtitle: 'cu_Booking_Confirmation_Docs', listType: 'docBookingWithPNR'}}
    ],
    docSubscription: [
        {label: 'cu_Invoices', eventDetails: {topic: 'cu_Invoices', showDynamicText: true, dynTextLabel: 'cu_InvoicesDynamicText', subtitle: 'cu_Invoices', listType: 'stillHaveQuestionDocs', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createDocRequestCase'}},
        {label: 'cu_CreditNotes', eventDetails: {topic: 'cu_CreditNotes', showDynamicText: true, dynTextLabel: 'cu_CreditNotesDynamicText', subtitle: 'cu_CreditNotes', listType: 'stillHaveQuestionDocs', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createDocRequestCase'}},
        {label: 'cu_ProForma', eventDetails: {topic: 'cu_ProForma', showDynamicText: true, dynTextLabel: 'cu_ProFormaDynamicText', subtitle: 'cu_ProForma', listType: 'stillHaveQuestionDocs', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createDocRequestCase'}},
        {label: 'cu_History', eventDetails: {topic: 'cu_History', showDynamicText: true, dynTextLabel: 'cu_HistoryDynamicText', subtitle: 'cu_History', listType: 'stillHaveQuestionDocs', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createDocRequestCase'}},
    ],
    docProof: [
        {label: 'cu_ProofOfTravel', eventDetails: {topic: 'cu_ProofOfTravel', subtitle: 'cu_IfYouHaveBookingInclude', listType: 'skipStepToTCNNoPNR', btnListLabel: 'cu_DontHaveBookingReference', inputData: [{inputLabelName: 'cu_PNR_Optional', inputPlaceholderName: 'cu_CommentPlaceholder', checkPNR: true, inputName: 'pnr', nextStepKey: 'tcnInput', addToExisting: false}]}},
        {label: 'cu_ProofOfDisruption', eventDetails: {topic: 'cu_ProofOfDisruption', subtitle: 'cu_IfYouHaveBookingInclude', listType: 'skipStepToTCNNoPNR', btnListLabel: 'cu_DontHaveBookingReference', inputData: [{inputLabelName: 'cu_PNR_Optional', inputPlaceholderName: 'cu_CommentPlaceholder', checkPNR: true, inputName: 'pnr', nextStepKey: 'tcnInput', addToExisting: false}]}},
        {label: 'cu_ProofOfCancellation', eventDetails: {topic: 'cu_ProofOfCancellation', subtitle: 'cu_IfYouHaveBookingInclude', listType: 'skipStepToTCNNoPNR', btnListLabel: 'cu_DontHaveBookingReference', inputData: [{inputLabelName: 'cu_PNR_Optional', inputPlaceholderName: 'cu_CommentPlaceholder', checkPNR: true, inputName: 'pnr', nextStepKey: 'tcnInput', addToExisting: false}]}},
    ],
    docProofWithPNR: [
        { label: 'cu_ProofOfTravel', eventDetails: { topic: 'cu_ProofOfTravel', subtitle: 'cu_TCN_Input_Text', listType: 'skipStepDoc', btnListLabel: 'cu_DontHaveTCNReference', inputData: [ { inputLabelName: 'cu_TCN', inputPlaceholderName: 'cu_CommentPlaceholder', checkTCN: true, inputName: 'tcn', nextStepKey: 'pnrOptionalDoc', addToExisting: false } ] } },
        {label: 'cu_ProofOfDisruption', eventDetails: {topic: 'cu_ProofOfDisruption', subtitle: 'cu_TCN_Input_Text', listType: 'skipStepDoc', btnListLabel: 'cu_DontHaveTCNReference', inputData: [{inputLabelName: 'cu_TCN', inputPlaceholderName: 'cu_CommentPlaceholder', checkTCN: true, inputName: 'tcn', nextStepKey: 'pnrOptionalDoc', addToExisting: false}]}},
        {label: 'cu_ProofOfCancellation', eventDetails: {topic: 'cu_ProofOfCancellation', subtitle: 'cu_TCN_Input_Text', listType: 'skipStepDoc', btnListLabel: 'cu_DontHaveTCNReference', inputData: [{inputLabelName: 'cu_TCN', inputPlaceholderName: 'cu_CommentPlaceholder', checkTCN: true, inputName: 'tcn', nextStepKey: 'pnrOptionalDoc', addToExisting: false}]}},
    ],
    docBooking: [
        {label: 'cu_BookingReceipt', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_BookingConfirmationDynamicText2', topic: 'cu_BookingReceipt', subtitle: 'cu_IfYouHaveBookingInclude', listType: 'skipStepDoc', btnListLabel: 'cu_DontHaveBookingReference', inputData: [{inputLabelName: 'cu_PNR_Optional', inputPlaceholderName: 'cu_CommentPlaceholder', checkPNR: true, inputName: 'pnr', nextStepKey: 'pnrOptionalDoc', addToExisting: false}]}},
        {label: 'cu_AdditionalCharges', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_BookingConfirmationDynamicText3', topic: 'cu_AdditionalCharges', subtitle: 'cu_IfYouHaveBookingInclude', listType: 'skipStepDoc', btnListLabel: 'cu_DontHaveBookingReference', inputData: [{inputLabelName: 'cu_PNR_Optional', inputPlaceholderName: 'cu_CommentPlaceholder', checkPNR: true, inputName: 'pnr', nextStepKey: 'pnrOptionalDoc', addToExisting: false}]}},
        {label: 'cu_ConfirmationOfBooking', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_BookingConfirmationDynamicText1', topic: 'cu_ConfirmationOfBooking', subtitle: 'cu_IfYouHaveBookingInclude', listType: 'skipStepDoc', btnListLabel: 'cu_DontHaveBookingReference', inputData: [{inputLabelName: 'cu_PNR_Optional', inputPlaceholderName: 'cu_CommentPlaceholder', checkPNR: true, inputName: 'pnr', nextStepKey: 'pnrOptionalDoc', addToExisting: false}]}},
    ],
    docBookingWithPNR: [
        {label: 'cu_BookingReceipt', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_BookingConfirmationDynamicText2', midStep: 'additionalAssistanceYesNo', formType: 'formType', topic: 'cu_BookingReceipt',  subtitle: 'cu_HowWeCanHelp', showUploader: true, selectedAction: 'createDocRequestCase'}},
        {label: 'cu_AdditionalCharges', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_BookingConfirmationDynamicText3', midStep: 'additionalAssistanceYesNo', formType: 'formType', topic: 'cu_AdditionalCharges', subtitle: 'cu_HowWeCanHelp', showUploader: true, selectedAction: 'createDocRequestCase'}},
        {label: 'cu_ConfirmationOfBooking', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_BookingConfirmationDynamicText1', midStep: 'additionalAssistanceYesNo', formType: 'formType', topic: 'cu_ConfirmationOfBooking', subtitle: 'cu_HowWeCanHelp', showUploader: true, selectedAction: 'createDocRequestCase'}},
    ],
    travelToFromUK: [
        {label: 'cu_Yes', eventDetails: {listType: 'luggageQuestions', subtitle: 'cu_LuggageAndBikes'}},
        {label: 'cu_No', eventDetails:{listType: 'luggageNotUK', subtitle: 'cu_LuggageAndBikes'}},
    ],
    luggageNotUK: [
        {label: 'cu_Luggage_Information', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Luggage_7', subtitle: 'cu_Luggage_Information', listType: 'stillHaveQuestions', btnListLabel:'cu_StillWouldLikeToAskQuestion', selectedAction: 'createRedLugageQuestionCase', topic: 'cu_Luggage_Information'}},
        {label: 'cu_TravelingWithBikes', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Luggage_8', subtitle: 'cu_TravelingWithBikes', listType: 'stillHaveQuestions', btnListLabel:'cu_StillWouldLikeToAskQuestion', selectedAction: 'createRedLugageQuestionCase', topic: 'cu_TravelingWithBikes'}},
        {label: 'cu_LostProperty', eventDetails: {showDynamicText: true, dynTextLabel: 'cu_Luggage_9', subtitle: 'cu_LostProperty', listType: 'stillHaveQuestions', btnListLabel:'cu_StillWouldLikeToAskQuestion', selectedAction: 'createRedLugageQuestionCase', topic: 'cu_LostProperty'}}
    ],

    // MID STEPS SCREENS
    additionalAssistance: [
        {label: 'cu_Yes', eventDetails: {subtitle: 'cu_AssistanceInformation', showDynamicText: true,
            listType: 'additionalAssistanceSkip', eventDetails: {},
            inputData: [
                {inputLabelName: 'cu_AdditionalAssistanceSubtitle', inputName: 'additionalAssistanceOptions', inputType: 'select', showButton: false, required: true},
                {inputLabelName: 'cu_OtherPleaseSpecify', inputName: 'additionalAssistanceOther', inputType: 'textarea', nextStepKey: 'additionalAssistanceFinish'},
            ]
        }},
        {label: 'cu_No', eventDetails:{finishMidStep: true}},
    ],
    additionalAssistanceSkip: [
        {label: 'cu_AdditionalAssistanceSkip', eventDetails: {finishMidStep: true}}
    ]
};

const MID_STEP_DETAILS_MAPPING = {
    additionalAssistanceYesNo: {subtitle: 'cu_AdditionalAssistance', showDynamicText: true, dynTextLabel: 'cu_AdditionalAssistance_DynTxt', listType: 'additionalAssistance'},
};

const INPUT_TO_DETAILS_MAPPING = {
    additionalAssistanceFinish: {finishMidStep: true},
    errorMessage: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_FinalErrorStepTitle', showUploader: true},
    pnrOptional: {subtitle: 'cu_EnterYourFeedBackBelow', showDynamicText: true, dynTextLabel: 'cu_Feedback_1', midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, selectedAction: 'createFeedbackCase'},
    tcnInput: {subtitle: 'cu_TCN_Input_Text', listType: 'skipStepDoc', btnListLabel: 'cu_DontHaveTCNReference', inputData: [{inputLabelName: 'cu_TCN', inputPlaceholderName: 'cu_CommentPlaceholder', checkTCN: true, inputName: 'tcn', nextStepKey: 'pnrOptionalDoc', addToExisting: false}]},
    pnrOptionalDoc: {subtitle: 'cu_HowWeCanHelp', midStep: 'additionalAssistanceYesNo', formType: 'formType', showUploader: true, selectedAction: 'createDocRequestCase'},
    pnrOptional2: {},
    afterDateEnter: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_PleaseEnterYourQuestionBelow', showUploader: true, selectedAction: 'createSpecialAssistanceCase'},
    afterDateDisruptEnter: {subtitle: 'cu_WhatDestinationOrRoute', listType: 'futureDisruptionCountriesList'},
    afterDateDisruptionEnter: {subtitle: 'cu_WhatDestinationOrRoute', inputData: [{inputLabelName: 'cu_ChooseTheDirection', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'direction', nextStepKey: 'futureDisruptEnd'}]},
    disruptionDestination: {subtitle: 'cu_WhereAreYouTravellingTo', listType: 'travelToCountriesList'},
    futureDisruptEnd: {subtitle: 'cu_FutureDisruptionInfo', showDynamicText: true, dynTextLabel: 'cu_Latest_Disruption_Info_1', subtitle: 'AskAQuestion', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion', selectedAction: 'createDisruptionQuestionCase'},
    memberNumber: {subtitle: 'cu_WhatCanWeHelpWith', listType: 'clubHelp'},
    stillNeedHelpChange: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_GiveInformationWhatToChangeInBooking', showUploader: true},
    stillNeedHelpCancel: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_GiveInformationWhatToDoWithBooking', showUploader: true},
    bicOrSwiftInput: {subtitle: 'cu_BICOrSWIFTCode', inputData: [{inputLabelName: 'cu_BICOrSWIFTCode', inputName: 'bicOrSwift', inputPlaceholderName: 'cu_BICOrSWIFTCode', inputType: 'textarea', nextStepKey: 'afterExpensesForms'}]},
    sortCode: {subtitle: 'cu_SortCode', inputData: [{inputLabelName: 'cu_SortCode', inputName: 'sortCode', inputPlaceholderName: 'cu_SortCode', nextStepKey: 'afterExpensesForms', regexp: `^[0-9]{6,6}$`}]},
    afterExpensesForms: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_PleaseEnterYourQuestionBelow', showUploader: true},
    travelDateBooking: {subtitle: 'cu_WhereWouldYouLikeToTravel', inputData: [{inputLabelName: 'cu_ChooseTheDirection', inputPlaceholderName: 'cu_ChooseTheDirection', inputType: 'select', inputName: 'direction', nextStepKey: 'afterBookingDirection'}]},
    travelFromBooking: {subtitle: 'cu_WhereAreYouTravellingFrom', listType: 'travelFromCountriesList'},
    travelToBooking: {subtitle: 'cu_WhereAreYouTravellingTo', listType: 'travelToCountriesList'},
    travelFromBookingGroup: {subtitle: 'cu_WhereAreYouTravellingFrom', listType: 'travelGroupFromCountriesList'},
    travelToBookingGroup: {subtitle: 'cu_WhereAreYouTravellingTo', listType: 'travelGroupToCountriesList'},
    afterBookingDirection: {midStep: 'additionalAssistanceYesNo', formType: 'formType', selectedAction: 'createMakeBookingCase', subtitle: 'cu_PleaseEnterYourQuestionBelow', showUploader: true},
    afterBookingDirectionGroup: {midStep: 'additionalAssistanceYesNo', formType: 'formType', selectedAction: 'createMakeBookingCase', subtitle: 'cu_PleaseEnterYourQuestionBelow', showUploader: true},
    disruptionFlow_Cancellation_Train: {title: 'cu_WeHaveFoundYourBooking', showDynamicText: true, dynTextLabel: 'cu_DisruptionFlow_Cancellation_Train2', listType: 'existingCaseQuestion2', subtitle: 'cu_DisruptionFlow_Cancellation_Train'},
    disruptionFlow_Delay_Train: {title: 'cu_WeHaveFoundYourBooking', showDynamicText: true, dynTextLabel: 'cu_DisruptionFlow_Delay_Train2', listType: 'existingCaseQuestion2', subtitle: 'cu_DisruptionFlow_Delay_Train'},
    disruptionFlow_AOPOther_Package: {title: 'cu_WeHaveFoundYourBooking', listType: 'existingCaseQuestion2', subtitle: 'cu_DisruptionFlow_AOPOther_Package'},
    disruptionFlow_Cancellation_Package: {title: 'cu_WeHaveFoundYourBooking', showDynamicText: true, dynTextLabel: 'cu_DisruptionFlow_Cancellation_Package2', listType: 'existingCaseQuestion2', subtitle: 'cu_DisruptionFlow_Cancellation_Package'},
    disruptionFlow_Delay_Package: {title: 'cu_WeHaveFoundYourBooking', showDynamicText: true, dynTextLabel: 'cu_DisruptionFlow_Delay_Package2', listType: 'existingCaseQuestion2', subtitle: 'cu_DisruptionFlow_Delay_Package'},
    disruptionFlow_Hotel: {title: 'cu_WeHaveFoundYourBooking', listType: 'existingCaseQuestion2', subtitle: 'cu_DisruptionFlow_Hotel'},
    errorCaseExists: {title: 'cu_WeHaveFoundYourBooking', listType: 'existingCaseQuestion2', subtitle: 'cu_CreateNewCaseQuestionPnr'},
    afterCommentEnter: {midStep: 'additionalAssistanceYesNo', formType: 'formType', addToExisting: true, subtitle: 'cu_WeAreUpdatingYourCase'},
    bookingDate: {subtitle: 'cu_BookingDate', inputData: [{inputType: 'date', inputLabelName: 'cu_Date', inputName: 'bookingDate', required: 'true', nextStepKey: 'bookingCompleted',}]},
    bookingCompleted: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_PleaseEnterAdditionalInfo', showUploader: true, selectedAction: 'createClubEurostarCase'},
    returnOrSingle: {subtitle: 'cu_ReturnOrSingle', listType: 'returnOrSingleYesNo'},
    passengerDetails: {subtitle: 'cu_NumberOfPassengers', inputData: [
        {inputLabelName: 'cu_AdultPassengers', inputName: 'adultPassengers', inputPlaceholderName: 'cu_NumberPlaceholder', inputType: 'number', showButton: false, required: 'true'},
        {inputLabelName: 'cu_ChildPassengers', inputName: 'childrenPassengers', inputPlaceholderName: 'cu_NumberPlaceholder', inputType: 'number', showButton: false},
        {inputLabelName: 'cu_InfantPassengers', inputName: 'infantsPassengers', inputPlaceholderName: 'cu_NumberPlaceholder', inputType: 'number', nextStepKey: 'serviceClass'}]},
    serviceClass : {subtitle: 'cu_ClassService', showDynamicText: true, dynTextLabel: 'cu_ClassServiceText', inputData: [{inputLabelName: 'cu_ClassService', inputPlaceholderName: 'cu_ClassService', inputType: 'select', inputName: 'classService', required: 'true', nextStepKey: 'doYouNeedSpecialAssistance',}]},
    doYouNeedSpecialAssistance: {subtitle: 'cu_SpecialAssistanceYesNo', listType: 'specialAssistance'},
    companyNameInput: {subtitle: 'cu_CompanyNameText', inputData: [
        {inputLabelName: 'cu_CompanyName', inputName: 'companyName', inputPlaceholderName: 'cu_CompanyName', inputType: 'text', nextStepKey: 'showEndForm', required: 'true'}]},
    showEndForm: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_AdditionalInfoB2B', showUploader: true, selectedAction: 'createB2BBookingCase', b2bForm: true},
    isDisruptedButtons: { title: 'cu_WeHaveFoundYourBooking', showDynamicText: true, dynTextLabel: 'cu_DisruptionDynamicText', listType: 'disruptedWithPNR', subtitle: 'cu_WhatWouldYouLikeToDo' }, 
    notDisruptedButtons: { title: 'cu_WeHaveFoundYourBooking', listType: 'notDisruptedWithPNR', subtitle: 'cu_WhatWouldYouLikeToDo' },
    isDisruptedButtonsExistingCase: { showDynamicText: true, dynTextLabel: 'cu_DisruptionDynamicText', listType: 'disruptedWithPNR', subtitle: 'cu_WhatWouldYouLikeToDo' }, 
    notDisruptedButtonsExistingCase: { listType: 'notDisruptedWithPNR', subtitle: 'cu_WhatWouldYouLikeToDo' },
};

const ADD_SOMETHING_PARAMS_MAPPING = {
    HOTEL_ONLY: {midStep: 'additionalAssistanceYesNo', formType: 'formType', subtitle: 'cu_WhatToAddToBooking', showUploader: true, selectedAction: 'createAddSomethingCase'},
    TRAIN_AND_HOTEL: {listType: 'addSomething2', subtitle: 'cu_WhatWouldYouLikeToAdd'},
    TRAIN_ONLY: {listType: 'addSomething3', subtitle: 'cu_WhatWouldYouLikeToAdd'},
};

const FIELD_VALUES_TO_DYN_TEXT = {
    change:{isDisrupted:{true:{isFree:{true:"cu_AOP_Free_1",false:"cu_AOP_With_Cost_1"},isChangeableOnline:{true:"cu_AOP_via_MYB_1"}}}},
    cancel:{isDisrupted:{true:{cancelOption:{NO_REFUND:"cu_No_Cancel_Options_1",FULL_REFUND:"cu_AOP_Full_Refund_1",REFUND_TO_VOUCHER:"cu_Cancel_To_Voucher_1"},isChangeableOnline:{true:"cu_Cancel_Via_MYB_1"}}}}
};

const PARAMS_MAPPING = {
    notDisrupted: {subtitle: 'cu_PleaseProvideDepartureDate', listType: 'skipDepartureDateStepNotDisraptedPNR', inputData: [{inputType: 'departuredate', inputLabelName: 'cu_TravelDate', inputName: 'travelDate', nextStepKey: 'notDisruptedButtons', checkDepartureDate: true}]},
    isDisrupted: {subtitle: 'cu_PleaseProvideDepartureDate', listType: 'skipDepartureDateStepDisraptedPNR', inputData: [{inputType: 'departuredate', inputLabelName: 'cu_TravelDate', inputName: 'travelDate', nextStepKey: 'isDisruptedButtons', checkDepartureDate: true}]},
    notDisruptedCompensation: {showDynamicText: true, dynTextLabel: 'cu_NoDisruptionDynamic', subtitle: 'cu_NoDisruptionTitle', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion'}
};

const EXISTING_CASE_PARAMS_MAPPING = {
    notDisrupted: {subtitle: 'cu_PleaseProvideDepartureDate', listType: 'skipDepartureDateStepNotDisraptedPNRExistingCase', inputData: [{inputType: 'departuredate', inputLabelName: 'cu_TravelDate', inputName: 'travelDate', nextStepKey: 'notDisruptedButtonsExistingCase', checkDepartureDate: true}]},
    isDisrupted: {subtitle: 'cu_PleaseProvideDepartureDate', listType: 'skipDepartureDateStepDisraptedPNRExistingCase', inputData: [{inputType: 'departuredate', inputLabelName: 'cu_TravelDate', inputName: 'travelDate', nextStepKey: 'isDisruptedButtonsExistingCase', checkDepartureDate: true}]},
    notDisruptedCompensation: {showDynamicText: true, dynTextLabel: 'cu_NoDisruptionDynamic', subtitle: 'cu_NoDisruptionTitle', listType: 'stillHaveQuestions', btnListLabel: 'cu_StillWouldLikeToAskQuestion'}
};

const getDynLabelsByPnrData = (pnrData, flowType, param) => {
    if (FIELD_VALUES_TO_DYN_TEXT[flowType] &&
        FIELD_VALUES_TO_DYN_TEXT[flowType]['isDisrupted'] &&
        FIELD_VALUES_TO_DYN_TEXT[flowType]['isDisrupted'][String(pnrData.isDisrupted)] &&
        !pnrData.isDelayed
    ) {
        if (!Array.isArray(param)) {
            if (
                FIELD_VALUES_TO_DYN_TEXT[flowType]['isDisrupted'][String(pnrData.isDisrupted)][param] &&
                FIELD_VALUES_TO_DYN_TEXT[flowType]['isDisrupted'][String(pnrData.isDisrupted)][param][String(pnrData[param])]
            ) {
                return FIELD_VALUES_TO_DYN_TEXT[flowType]['isDisrupted'][String(pnrData.isDisrupted)][param][String(pnrData[param])];
            } else {
                return null;
            }
        } else {
            for (let i = 0; i < param.length; i++) {
                if (
                    FIELD_VALUES_TO_DYN_TEXT[flowType]['isDisrupted'][String(pnrData.isDisrupted)][param[i]] &&
                    FIELD_VALUES_TO_DYN_TEXT[flowType]['isDisrupted'][String(pnrData.isDisrupted)][param[i]][String(pnrData[param[i]])]
                ) {
                    return FIELD_VALUES_TO_DYN_TEXT[flowType]['isDisrupted'][String(pnrData.isDisrupted)][param[i]][String(pnrData[param[i]])];
                }
            }
            return null;
        }
    } else {
        return null;
    }
};

const objectToListSettings = {
    STATIONS_OBJECT: {
        eventDetails: {listType: 'stationQuestions', formType: null, showUploader: false, subtitle: 'cu_PleaseEnterYourPNR'},
        additionalButton: {label: 'cu_SomewhereElse', eventDetails: {listType: null, formType: null, showUploader: false, subtitle: "Dynamic Text - Other stations 1"}}
    }
};

const getAddSomethingParams = (bookingType) => {
    return ADD_SOMETHING_PARAMS_MAPPING[bookingType] ? ADD_SOMETHING_PARAMS_MAPPING[bookingType]: null;
};

const getButtonList = (listType) => {
    return typeToBtnList[listType];
};

const createButtonsFromData = (dataType, data) => {
    let buttonList = [];
    data.forEach(element => {
        buttonList.push({label: element.label, eventDetails: objectToListSettings[dataType].eventDetails});
    });
    if (objectToListSettings[dataType].additionalButton) {
        buttonList.push(objectToListSettings[dataType].additionalButton);
    }
    return buttonList;
};

const getTranslatedLabel = (labelName, langCode) => {
    if (LABELS_MAPPING[labelName] && LABELS_MAPPING[labelName][langCode]) {
        return LABELS_MAPPING[labelName][langCode];
    } else if (LABELS_MAPPING[labelName]) {
        return LABELS_MAPPING[labelName]['en_US'];
    } else {
        return '';
    }
};

const getParamsForNextStepByInput = (labelName) => {
    if (INPUT_TO_DETAILS_MAPPING[labelName]) {
        return INPUT_TO_DETAILS_MAPPING[labelName];
    } else {
        return null;
    }
};

const addParamsForNextStepByDisruption = (key) => {
    if (EXISTING_CASE_PARAMS_MAPPING[key]) {
        for (let prop in EXISTING_CASE_PARAMS_MAPPING[key]) {
        typeToBtnList['existingCaseQuestion2'][1].eventDetails[prop] = EXISTING_CASE_PARAMS_MAPPING[key][prop];
        }
    }
};

const getMidStepParams = (name) => { return MID_STEP_DETAILS_MAPPING[name]; };


export {
    getButtonList,
    createButtonsFromData,
    getTranslatedLabel,
    getParamsForNextStepByInput,
    getAddSomethingParams,
    getDynLabelsByPnrData,
    addParamsForNextStepByDisruption,
    getMidStepParams
};

export { PARAMS_MAPPING };