import { LightningElement, api } from 'lwc';

export default class CustomActionButtons extends LightningElement {
    @api folderName;

    handleDeleteAction(){
        console.log('Delete Container Event');
        const event = new CustomEvent('azuredeletecontainer', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                fileFolderObj : {
                    objName: this.folderName,
                }
            },
        });
        console.log('Delete event firing : ', event);
        this.dispatchEvent(event);
    }

    handleEditAction(){
        console.log('Rename Container Event');
        const event = new CustomEvent('azurerenamecontainer', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                fileFolderObj : {
                    objName: this.folderName,
                }
            },
        });
        console.log('Rename event firing : ', event);
        this.dispatchEvent(event);
    }

    hanldeCopyAction(){
        console.log('Copy action Container Event');
        const event = new CustomEvent('azurerecopycontainer', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                fileFolderObj : {
                    objName: this.folderName,
                }
            },
        });
        console.log('Copy Action event firing : ', event);
        this.dispatchEvent(event);
    }

    handleCopyLink(){
        console.log('Copy Link Container Event');
        const event = new CustomEvent('azurerecopylinkcontainer', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                fileFolderObj : {
                    objName: this.folderName,
                }
            },
        });
        console.log('Copy Link event firing : ', event);
        this.dispatchEvent(event);
    }

}