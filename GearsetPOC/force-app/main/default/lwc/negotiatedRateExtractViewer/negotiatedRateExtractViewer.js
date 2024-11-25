import { LightningElement, wire } from 'lwc';
import getNegotiatedRateExtractRows from '@salesforce/apex/NegotiatedRateExtractViewerController.getNegotiatedRateExtractRows';
import getNegotiatedRateBeNeContractExtractRows from '@salesforce/apex/NegotiatedRateExtractViewerController.getNegotiatedRateBeNeContractExtractRows';

const colsBeNe = [
  {label: "Account Manager",fieldName: 'accManager'},
  {label: "Account Name",fieldName: 'accName'},
  {label: "Unique Code",fieldName: 'uniqueCode'},
  {label: "Distributor",fieldName: 'distributor'},
  {label: "Road",fieldName: 'road'},
  {label: "Tariff Code Eurostar Standard",fieldName: 'tariffCodeEurostarStandard'},
  {label: "Tariff Code Eurostar Plus",fieldName: 'tariffCodeEurostarPlus'},
  {label: "Tariff Code Eurostar Premier",fieldName: 'tariffCodeEurostarPremier'},
  {label: "Start Date",fieldName: 'startDate'},
  {label: "End Date",fieldName: 'endDate'},
  {label: "Action Type",fieldName: 'actionType'}
];

const colsBeNeContract = [
  {label: "Business Account Name",fieldName: 'accName'},
  {label: "Distributor",fieldName: 'distributor'},
  {label: "Unique Code",fieldName: 'uniqueCode'},
  {label: "City",fieldName: 'billingCity'},
  {label: "Country",fieldName: 'billingCountry'}
];

const colsGdsAir = [
  {label: "Account Manager",fieldName: 'accManager'},
  {label: "Account Name",fieldName: 'accName'},
  {label: "Unique Code",fieldName: 'uniqueCode'},
  {label: "GDS Used",fieldName: 'gdsUsed'},
  {label: "PCC",fieldName: 'pcc'},
  {label: "Road",fieldName: 'road'},
  {label: "Tariff Code Eurostar Standard",fieldName: 'tariffCodeEurostarStandard'},
  {label: "Tariff Code Eurostar Plus",fieldName: 'tariffCodeEurostarPlus'},
  {label: "Tariff Code Eurostar Premier",fieldName: 'tariffCodeEurostarPremier'},
  {label: "Start Date",fieldName: 'startDate'},
  {label: "End Date",fieldName: 'endDate'},
  {label: "Action Type",fieldName: 'actionType'}
];

const colsIdl = [
  {label: "Account Manager",fieldName: 'accManager'},
  {label: "Account Name",fieldName: 'accName'},
  {label: "Unique Code",fieldName: 'uniqueCode'},
  {label: "Type of Unique Code",fieldName: 'distributor'},
  {label: "Road",fieldName: 'road'},
  {label: "Tariff Code Eurostar Standard",fieldName: 'tariffCodeEurostarStandard'},
  {label: "Percentage Discount Eurostar Standard",fieldName: 'percentageDiscountEurostarStandard'},
  {label: "Tariff Code Eurostar Plus",fieldName: 'tariffCodeEurostarPlus'},
  {label: "Percentage Discount Eurostar Plus",fieldName: 'percentageDiscountEurostarPlus'},
  {label: "Tariff Code Eurostar Premier",fieldName: 'tariffCodeEurostarPremier'},
  {label: "Percentage Discount Eurostar Premier",fieldName: 'percentageDiscountEurostarPremier'},
  {label: "Action Type",fieldName: 'actionType'}
];

export default class NegotiatedRateExtractViewer extends LightningElement {
    isLoadedExtracts = false;
    isLoadedContracts = false;
    columnsBeNe = colsBeNe;
    columnsBeNeContract = colsBeNeContract;
    columnsGdsAir = colsGdsAir;
    columnsIdl = colsIdl;
    negotiatedRatesBeNe;
    negotiatedRatesBeNeContract;
    negotiatedRatesGdsAir;
    negotiatedRatesIdl;
    @wire(getNegotiatedRateExtractRows)
    negotiatedRatesResult({ data, error }) {
        if(data) {
          this.negotiatedRatesBeNe = data['beneextract'];
          this.negotiatedRatesGdsAir = data['gdsairextract'];
          this.negotiatedRatesIdl = data['idlextract'];
            this.isLoadedExtracts = true;
        }
    };

    @wire(getNegotiatedRateBeNeContractExtractRows)
    negotiatedRatesBeneContractResult({ data, error }) {
        if(data) {
            this.negotiatedRatesBeNeContract = data;
            this.isLoadedContracts = true;
        }
    };
}