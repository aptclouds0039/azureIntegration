import { LightningElement, api , wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkContainerExists from '@salesforce/apex/azureFilesConnectController.checkContainerExists';
import createNewContainer from '@salesforce/apex/azureFilesConnectController.createNewContainer';
import  getContentsOfContainer from '@salesforce/apex/azureIntegrationController.getContentsOfContainer';
import uploadBlobInContainer from '@salesforce/apex/azureIntegrationController.uploadBlobInContainer';
import deleteBlobFromContainer from '@salesforce/apex/azureIntegrationController.deleteBlobFromContainer';
import downloadBlob from '@salesforce/apex/azureFilesConnectController.downloadBlob';
export default class AzureFilesConnect extends LightningElement {
    @api recordId;
    containerDoesNotExist = false;
    containerExisting = false;
    containerData;
    openedContainer;
    showFileUploadModal = false;
    showLoadingSpinner = false;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    searchingKey = '';
    data;
    blobCols = [
        {label: 'File Name',  type:'customBlobDataType', fieldName:'name', typeAttributes:{blobFileName:{fieldName:'name'}}, sortable:true},
        {label:'Last Modified', fieldName: 'lastModidifed', sortable:true},
        {label: 'ETag', fieldName:'eTag'},
        {label:'Content Type', fieldName: 'contentType'},
        {label: 'Actions', type:'customBlobAction',
            typeAttributes:{blobFileName:{fieldName:'name'}, blobFileContentType:{fieldName:'contentType'}}
        }
    ]

    @wire(checkContainerExists, {recordId: '$recordId'})
    containerExists({error, data}){
        console.log('Wire Called');
        if(data){
            console.log(data);  
            if(data == 'No Container Found'){
                this.containerDoesNotExist = true;
            }else{
                console.log(data);
                this.containerDoesNotExist = false;
                this.containerExisting = true;
                this.openedContainer = data;
                getContentsOfContainer({containerName: data})
                .then(result => {
                    console.log('Data ' , result);
                    this.containerData = result;
                    this.data = this.containerData;
                })
                .catch(error => {
                    console.log('Error' , error);
                })
            }
        }
    }

    /* Method to create new Contianer */
    handleCreateNewContainerClick(){
        console.log('Asked to create a new container');
        this.showLoadingSpinner = true;
        createNewContainer({recordId : this.recordId})
        .then(result => {
            console.log(result);
            this.containerDoesNotExist = false;
            this.containerExisting = true;
            this.openedContainer = result;
            console.log(this.openedContainer);
            getContentsOfContainer({containerName: this.openedContainer})
            .then(result => {
                console.log('Data ' , result);
                this.containerData = result;
                this.data = this.containerData;
                this.showLoadingSpinner = false;
                const event = new ShowToastEvent({
                    title: 'New Container Created',
                    message:
                        'New Container has been created for the record -: ' + this.recordId,
                });
                this.dispatchEvent(event);
            })
            .catch(error => {
                console.log('Error' , error);
            })
        })
    }


    // File Action Methods
    handleDeleteBlob(event){
        console.log('Delete Blob Event Fired');
        let selectedBlob  = event.detail.fileFolderObj.objName;
        console.log('File To Delete : ' , selectedBlob);
        this.showLoadingSpinner = true;
        deleteBlobFromContainer({fName: selectedBlob, containerName: this.openedContainer})
        .then(result => {
            console.log('Deletion Successful');
            this.containerData = result;
            this.data = this.containerData;
            this.showLoadingSpinner = false;
            const event = new ShowToastEvent({
                title: 'File Deleted',
                message:
                    selectedBlob + ' has been deleted from the container for ' + this.recordId,
            });
            this.dispatchEvent(event);
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
        let selectedBlobType = event.detail.fileFolderObj.contentType;
        console.log('File To Download : ' , selectedBlob);
        console.log('file Type to Download : ', selectedBlobType);
        downloadBlob({containerName:this.openedContainer, fileName:selectedBlob})
        .then(result => {
            console.log(result);
            let element = document.createElement('a');
            element.setAttribute('href', 'data:'+selectedBlobType+';base64,'+result);
            element.setAttribute('download', selectedBlob);

            element.style.display = 'none';
            document.body.appendChild(element);

            element.click();

            document.body.removeChild(element);
        });
    }


    // File Upload Methods
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
            this.containerData = result;
            this.data = this.containerData;
            this.showFileUploadModal = false;
            this.showLoadingSpinner = false;
            const event = new ShowToastEvent({
                title: 'File Uploaded',
                message:
                filename + ' has been uploaded in the container for ' + this.recordId,
            });
            this.dispatchEvent(event);
        })
        .catch(error => {
            console.log('Error ' + error);
            this.showLoadingSpinner = false;
        })
        this.showFileUploadModal = false;
    }


    // Sorting Handler Methods
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.containerData];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.containerData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }


    // Searching Handler Methods
    handelSearchKey(event){
        console.log(event.detail.value);
        this.searchingKey = event.detail.value;
    }

    handleClearSearch(){
        this.containerData = this.data;
    }

    handleSearch(event) {
        const searchKey = this.searchingKey.toLocaleLowerCase();
 
        if (searchKey && searchKey!='') {
            this.containerData = this.data;
            console.log(this.data);
            
            if (this.containerData) {
                let searchRecords = [];
 
                for (let record of this.containerData) {
                    let valuesArray = Object.values(record);
 
                    for (let val of valuesArray) {
                        console.log('val is ' + val);
                        let strVal = String(val);
 
                        if (strVal) {
 
                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                }
 
                console.log('Matched Accounts are ' + JSON.stringify(searchRecords));
                this.containerData = searchRecords;
            }
        } else {
            this.containerData = this.data;
            console.log(this.data);
        }
    }
}