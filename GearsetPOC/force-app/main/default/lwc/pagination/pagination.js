import { LightningElement, api } from 'lwc';

export default class Pagination extends LightningElement {

    @api isFirstPage;
    @api isLastPage;
    @api totalPages;
    @api currentPage;
    @api isNeedPageInfo;

    handlePrevPage() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    handleNextPage() {
        this.dispatchEvent(new CustomEvent('next'));
    }
}