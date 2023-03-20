import { LightningElement, api } from 'lwc';

export default class CustomDataType extends LightningElement {
    @api folderName;

    handleFolderNameClick(){
        console.log('click on row');
        const event = new CustomEvent('azurecustomdatatype', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                fileFolderObj : {
                    objName: this.folderName,
                }
            },
        });
        console.log('handleFolderNameClick event firing : ', event);
        this.dispatchEvent(event);
    }
}