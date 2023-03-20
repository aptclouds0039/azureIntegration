public with sharing class azureFilesConnectController {
    @AuraEnabled(cacheable=true)
    public static string checkContainerExists(Id recordId){
        system.debug('Inside Check container exists method');
        system.debug('Record Id ' + recordId);
        List<Azure_Files_Connect__c> containerWithThisId = [SELECT Id, Name from Azure_Files_Connect__c WHERE Object_Id__c =: recordId];
        if(containerWithThisId.size() == 0){
            system.debug('Zeor size');
            return 'No Container Found';
        }else{
            system.debug('Not zero size');
            return containerWithThisId[0].Name;
        }
    }

    @AuraEnabled
    public static string createNewContainer(Id recordId){
        Opportunity oppToCreateContainer = [SELECT name FROM Opportunity WHERE Id =: recordId];
        String oppName = oppToCreateContainer.name;
        String containerName = (String) recordId;
        containerName = containerName.toLowercase();
        oppName = oppName.toLowercase();
        oppName = oppName.replace(' ', '-');
        system.debug('Opportunity Name ' + oppName);
        String eTag = handleContainerCreation(containerName);
        Azure_Files_Connect__c azureConnection = new Azure_Files_Connect__c();
        azureConnection.name = containerName;
        azureConnection.ETag__c = eTag;
        azureConnection.Object_Id__c = (String) recordId;
        insert azureConnection;
        return containerName;
    }

    public static String handleContainerCreation(String containerName){
        Azure_Connect_Setting__mdt azureSettings = [SELECT azure_Storage_Key__c, Azure_Url__c, Azure_Version__c,Storage_Name__c FROM Azure_Connect_Setting__mdt WHERE DeveloperName = 'azure_Connect'];
        String Azure_storageName = azureSettings.Storage_Name__c;
        String Azure_Container = containerName;
        String Azure_URL = azureSettings.Azure_Url__c;
        String Azure_StorageKey = azureSettings.azure_Storage_Key__c; 
        String strGMTDate = DateTime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        system.debug ('date:'+strGMTDate);
        String version = azureSettings.Azure_Version__c;
        String canonicalHeader = 'x-ms-date:'+strGMTDate+'\nx-ms-version:2021-12-02\n';
        String canonRes = '/' + Azure_storageName + '/' + Azure_Container + '\nrestype:container';
        String stringToSign = 'PUT\n\n\n\n\n\n\n\n\n\n\n\n'+ canonicalHeader + canonRes;
        system.debug('stringToSign: '+stringToSign);
        Blob decodedAccountSharedKey = EncodingUtil.base64Decode(Azure_StorageKey);
        String authToken = EncodingUtil.base64Encode(crypto.generateMac('HmacSHA256',Blob.valueOf(stringToSign), decodedAccountSharedKey));
        String authHeader = 'SharedKey ' + Azure_storageName + ':' + authToken;
        String strEndpoint = 'https://'+ Azure_storageName + Azure_URL + Azure_Container + '?restype=container';

        system.debug('endpoint: '+strEndpoint);
        // system.debug('authHeader: '+authHeader);

        HttpRequest req = new HttpRequest();
        req.setMethod('PUT');
        req.setHeader('x-ms-date', strGMTDate);
        req.setHeader('x-ms-version', version);
        req.setHeader('Authorization', authHeader);
        req.setHeader('Content-Length','0');
        req.setEndpoint(strEndpoint);
     
        system.debug('request: '+req);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res.getHeader('ETag').replace('"', '');
    }


    @AuraEnabled
    public static String downloadBlob(String containerName, String fileName){
        try {
            Azure_Connect_Setting__mdt azureSettings = [SELECT azure_Storage_Key__c, Azure_Url__c, Azure_Version__c,Storage_Name__c FROM Azure_Connect_Setting__mdt WHERE DeveloperName = 'azure_Connect'];
            String Azure_storageName = azureSettings.Storage_Name__c;
            String Azure_Container = containerName;
            String Azure_URL = azureSettings.Azure_Url__c;
            String Azure_StorageKey = azureSettings.azure_Storage_Key__c; 
            String strGMTDate = DateTime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
            system.debug ('date:'+strGMTDate);
            String version = azureSettings.Azure_Version__c;
            String conDate = 'x-ms-date:'+strGMTDate;

            String canonicalHeader = 'x-ms-date:'+strGMTDate+'\nx-ms-version:2021-12-02\n';
            String canonRes = '/' + Azure_storageName + '/' + Azure_Container + '/InvoicePdf.pdf';
            String stringToSign = 'GET\n\n\n\n\n\n\n\n\n\n\n\n'+ canonicalHeader + canonRes;
            system.debug('stringToSign: '+stringToSign);

            Blob decodedAccountSharedKey = EncodingUtil.base64Decode(Azure_StorageKey);
            String authToken = EncodingUtil.base64Encode(crypto.generateMac('HmacSHA256',Blob.valueOf(stringToSign), decodedAccountSharedKey));
            String authHeader = 'SharedKey ' + Azure_storageName + ':' + authToken;
            String strEndpoint = 'https://'+ Azure_storageName + Azure_URL + Azure_Container + '/InvoicePdf.pdf';
            system.debug('endpoint: '+strEndpoint);
            system.debug('authtoken: '+authHeader);

            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setHeader('x-ms-date', strGMTDate);
            req.setHeader('x-ms-version', version);
            req.setHeader('Authorization', authHeader);
            req.setHeader('Content-Length','0');
            req.setEndpoint(strEndpoint);

            system.debug('request: '+req);

            Http http = new Http();
            HTTPResponse res = http.send(req);
            system.debug('response: '+res.getBodyAsBlob());
            return EncodingUtil.base64Encode(res.getBodyAsBlob());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


}