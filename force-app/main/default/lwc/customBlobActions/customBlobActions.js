import { LightningElement, api } from 'lwc';

export default class CustomActionButtons extends LightningElement {
    @api fileName;
    @api fileContentType;

    handleDeleteBlobAction(){
        console.log('Delete Blob Event');
        const event = new CustomEvent('azuredeleteblob', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                fileFolderObj : {
                    objName: this.fileName,
                }
            },
        });
        console.log('Delete event firing : ', event);
        this.dispatchEvent(event);
    }


    handleCopyLinkBlob(){
        console.log('Copy Link Blob Event');
        const event = new CustomEvent('azurerecopylinkblob', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                fileFolderObj : {
                    objName: this.fileName,
                }
            },
        });
        console.log('Copy Link event firing : ', event);
        this.dispatchEvent(event);
    }

    handleDownloadBlobAction(){
        console.log('Download Blob Event');
        const event = new CustomEvent('azuredownloadblob', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                fileFolderObj : {
                    objName: this.fileName,
                    contentType: this.fileContentType
                }
            },
        });
        console.log('Download Blob event firing : ', JSON.stringify(event.detail.fileFolderObj));
        this.dispatchEvent(event);

    }



        // handleEditAction(){
    //     console.log('Rename Container Event');
    //     const event = new CustomEvent('azurerenamecontainer', {
    //         composed: true,
    //         bubbles: true,
    //         cancelable: true,
    //         detail: {
    //             fileFolderObj : {
    //                 objName: this.folderName,
    //             }
    //         },
    //     });
    //     console.log('Rename event firing : ', event);
    //     this.dispatchEvent(event);
    // }

    // hanldeCopyAction(){
    //     console.log('Copy action Container Event');
    //     const event = new CustomEvent('azurerecopycontainer', {
    //         composed: true,
    //         bubbles: true,
    //         cancelable: true,
    //         detail: {
    //             fileFolderObj : {
    //                 objName: this.folderName,
    //             }
    //         },
    //     });
    //     console.log('Copy Action event firing : ', event);
    //     this.dispatchEvent(event);
    // }

}