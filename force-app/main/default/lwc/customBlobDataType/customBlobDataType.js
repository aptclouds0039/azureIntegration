import { LightningElement, api } from 'lwc';

export default class CustomDataType extends LightningElement {
    @api fileName;

    handleFileNameClick(){
        console.log('click on row');
        const event = new CustomEvent('azurecustomblobdatatype', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                fileFolderObj : {
                    objName: this.fileName,
                }
            },
        });
        console.log('handle file name event firing : ', event);
        this.dispatchEvent(event);
    }
}