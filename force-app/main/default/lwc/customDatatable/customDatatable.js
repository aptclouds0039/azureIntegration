import { LightningElement } from 'lwc';
import LightningDatatable from 'lightning/datatable';
import customDataType from './customDataType';
import customActionButton from './customActionButton';


export default class CustomDatatable extends LightningDatatable {
    static customTypes = {
        customDataType : {
            template: customDataType,
            typeAttributes : ['containerName']
        },
        customActionButton : {
            template : customActionButton,
            typeAttributes : ['containerName']
        }
    }
}