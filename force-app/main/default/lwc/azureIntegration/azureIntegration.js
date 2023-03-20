import { LightningElement, wire } from 'lwc';
import getListOfContainers from '@salesforce/apex/azureIntegrationController.getListOfContainers';
import createContainer from '@salesforce/apex/azureIntegrationController.createContainer';
import deleteContainer from '@salesforce/apex/azureIntegrationController.deleteContainer';
import getContentsOfContainer from '@salesforce/apex/azureIntegrationController.getContentsOfContainer';
import uploadBlobInContainer from '@salesforce/apex/azureIntegrationController.uploadBlobInContainer';
import deleteBlobFromContainer from '@salesforce/apex/azureIntegrationController.deleteBlobFromContainer';
import LightningModal from 'lightning/modal';
export default class AzureIntegration extends LightningModal {
    containerList;
    error;
    containerListView=true;
    containerListScreen = true;
    showCreateNewContainerModal = false;
    blobListScreen = false;
    openedContainer;
    heading = 'Azure file Manager';
    showLoadingSpinner = false;
    pathName = ['aptcloudsdatalake'];
    showFileUploadModal = false;

    containerCols = [
        {label:'Container Name',type: "customDataType", typeAttributes: { containerName: {fieldName: 'name'}}},
        {label:'Last Modified', fieldName: 'lastModidifed'},
        {label:'ETag', fieldName:'eTag'},
        {label: 'Actions', type:'customActionButton', typeAttributes: { containerName: {fieldName: 'name'}}}
    ]

    blobCols = [
        {label: 'File Name',  type:'customBlobDataType', typeAttributes:{blobFileName:{fieldName:'name'}}},
        {label:'Last Modified', fieldName: 'lastModidifed'},
        {label: 'ETag', fieldName:'eTag'},
        {label:'Content Type', fieldName: 'contentType'},
        {label: 'Actions', type:'customBlobAction',typeAttributes:{blobFileName:{fieldName:'name'}}}
    ]

    get acceptedFormats(){
        return ['.pdf', '.png'];
    }

    connectedCallback(){
        getListOfContainers()
        .then(res => {
            this.containerList = res;
            console.log(this.containerList);
        })
    }
    /* Breadcrumb Methods */
    myBreadcrumbs = [
        {label:'aptclouds-datalake', name:'aptclouds-datalake', id:'root'},
    ]

    handleNavigateTo(event){
        const name = event.target.name;
        if(name == 'aptclouds-datalake'){
            this.showLoadingSpinner = true;
            this.containerListScreen = true;
            this.blobListScreen = false;
            this.blobList = null;
            this.myBreadcrumbs =  [{label:'aptclouds-datalake', name:'aptclouds-datalake', id:'root'}];
            this.showLoadingSpinner = false;
        }
    }

    /* Contianer Methods */
    handleFolderClick(event){
        console.log('Click Event Fired');
        this.openedContainer = event.detail.fileFolderObj.objName;
        this.showLoadingSpinner = true;
        getContentsOfContainer({containerName: this.openedContainer})
        .then(result => {
            this.blobListScreen = true;
            this.containerListScreen = false;
            this.blobList = result;
            this.heading = '/' + this.openedContainer;
            this.myBreadcrumbs.push({
                label:this.openedContainer,
                name: this.openedContainer,
                id:'childContainer'
            })
            this.showLoadingSpinner = false;
        })
        .catch(error => {
            console.log(JSON.stringify(error));
        })
    }

    handleDeleteButtonClick(event){
        console.log('Delete Event Fired');
        let obj = event.detail.fileFolderObj.objName;
        this.showLoadingSpinner = true;
        deleteContainer({containerName : obj})
        .then(result => {
            this.containerList = result;
            this.showLoadingSpinner = false;
        })
        console.log(JSON.stringify(obj));
    }

    handleCopyLinkClick(event){
        console.log('Copy Link event Fired');
        let obj = event.detail.fileFolderObj;
        console.log(JSON.stringify(obj));
    }
    
    /* New Container Creation Methods */
    handleNewContainerClick(){
        this.showCreateNewContainerModal= true;
    }

    handleContainerNameChange(event){
        this.newContainerName = event.detail.value;
    }

    handleCreateNewContainerSubmit(){
        this.showCreateNewContainerModal= false;
        console.log(this.newContainerName);
        this.showLoadingSpinner = true;
        createContainer({containerName: this.newContainerName})
        .then(result => {
            this.containerList = result;
            this.showLoadingSpinner = false;
        })
        this.newContainerName = '';
    }

    handleCreateNewContainerClose(){
        this.showCreateNewContainerModal = false;
        this.newContainerName = '';
    }

    /* Blob File Methods */
    handleDeleteBlob(event){
        console.log('Delete Blob Event Fired');
        let selectedBlob  = event.detail.fileFolderObj.objName;
        console.log('File To Delete : ' , selectedBlob);
        this.showLoadingSpinner = true;
        deleteBlobFromContainer({fName: selectedBlob, containerName: this.openedContainer})
        .then(result => {
            console.log('Deletion Successful');
            this.blobList = result;
            this.showLoadingSpinner = false;
        })
        .catch(error => {
            console.log('Error ' + error);
            this.showLoadingSpinner = true;
        })
    }

    handleCopyLinkBlob(event){
        console.log('Copy Link Blob Event Fired');
        let selectedBlob  = event.detail.fileFolderObj.objName;
        console.log('File To Copy : ' , selectedBlob);
    }

    handleDownLoadBlob(event){
        console.log('Download Blob Event Fired');
        let selectedBlob  = event.detail.fileFolderObj.objName;
        console.log('File To Download : ' , selectedBlob);
    }

    /* Method to Go back to home */
    handleHomeClick(){
        this.heading = 'Azure File Manager';
        this.blobListScreen = false;
        this.containerListScreen = true;
    }

    /* File Upload Handling Methods */
    handleFileUploadClick(){
        this.showFileUploadModal = true;
    }

    handleFileUploadClose(){
        this.showFileUploadModal = false;
    }

    handleFilesChange(event){
        const file = event.target.files[0]
        console.log(file);
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'type':file.type,
                'size':file.size
            }
            console.log(this.fileData)
        }
        reader.readAsDataURL(file)

    }
    handleFileUploadSubmit(){
        const {base64, filename, type, size} = this.fileData
        console.log('Base 64', base64);
        console.log('FileName' , filename);
        this.showLoadingSpinner = true;
        uploadBlobInContainer({base64data:base64, strFileName: filename, fileType:type, flength:size, containerName: this.openedContainer})
        .then(result => {
            this.blobList = result;
            this.showFileUploadModal = false;
            this.showLoadingSpinner = false;
        })
        .catch(error => {
            console.log('Error ' + error);
            this.showLoadingSpinner = false;
        })
        this.showFileUploadModal = false;
    }
}
