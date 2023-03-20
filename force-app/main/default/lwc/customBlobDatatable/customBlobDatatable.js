import { LightningElement } from 'lwc';
import LightningDatatable from 'lightning/datatable';
import customBlobDataType from './customBlobDataType';
import customBlobAction from './customBlobAction';
// import customActionButton from './customActionButton';


export default class CustomDatatable extends LightningDatatable {
    static customTypes = {
        customBlobDataType : {
            template: customBlobDataType,
            typeAttributes : ['blobFileName']
        },
        customBlobAction : {
            template : customBlobAction,
            typeAttributes : ['blobFileName', 'blobFileContentType']
        }
    }
}