import { LightningElement, track, api } from 'lwc';
import saveFiles from '@salesforce/apex/MultipleFileUploadController.saveFiles';
import { LABELS } from './generic_fileuploaderConfig';

export default class Generic_fileuploader extends LightningElement {
    showLoadingSpinner = false;
    @api langCode;
    labels = LABELS;
    successMessage;

    async handleFileChanges(event) {
        this.successMessage = '';
        this.showLoadingSpinner = true;
        let files = Array.from(event.target.files).map(
            file => {
                let reader = new FileReader();
                return new Promise(resolve => {
                    reader.onload = () => {
                        let base64 = 'base64,';
                        let content = reader.result.indexOf(base64) + base64.length;
                        let fileContents = reader.result.substring(encodeURIComponent(content));
                        let fileNew = {
                            title: file.name,
                            versionData: fileContents
                        };
                        resolve(fileNew);
                    }
                    reader.readAsDataURL(file);
                });
            }
        )
        let result = await Promise.all(files);
        let ids = await saveFiles({ filesToInsert: result });
        let filenames = [];
        result.forEach(elem => {filenames.push(elem.title)});
        this.successMessage = filenames.join(',');
        this.dispatchEvent(
            new CustomEvent('uploadfileids', {
                detail: {
                    files: JSON.stringify(ids)
                }
            })
        );
        this.showLoadingSpinner = false;
    }
}