public with sharing class azureIntegrationController{

    @AuraEnabled
    public static List<azureContainerWrapper> createContainer(String containerName){
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
        system.debug('authHeader: '+authHeader);

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
        system.debug('response: '+res);
        List<azureContainerWrapper> containerList = getListOfContainers();
        return containerList;
    }

    @AuraEnabled
    public static List<azureContainerWrapper> deleteContainer(String containerName){
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
        String stringToSign = 'DELETE\n\n\n\n\n\n\n\n\n\n\n\n'+ canonicalHeader + canonRes;
        system.debug('stringToSign: '+stringToSign);
        Blob decodedAccountSharedKey = EncodingUtil.base64Decode(Azure_StorageKey);
        String authToken = EncodingUtil.base64Encode(crypto.generateMac('HmacSHA256',Blob.valueOf(stringToSign), decodedAccountSharedKey));
        String authHeader = 'SharedKey ' + Azure_storageName + ':' + authToken;
        String strEndpoint = 'https://'+ Azure_storageName + Azure_URL + Azure_Container + '?restype=container';
        system.debug('endpoint: '+strEndpoint);
        system.debug('authHeader: '+authHeader);
        HttpRequest req = new HttpRequest();
        req.setMethod('DELETE');
        req.setHeader('x-ms-date', strGMTDate);
        req.setHeader('x-ms-version', version);
        req.setHeader('Authorization', authHeader);
        req.setHeader('Content-Length','0');
        req.setEndpoint(strEndpoint);
        system.debug('request: '+req);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('response: '+res);
        return getListOfContainers();
    }

    @AuraEnabled
    public static List<azureFileWrapper> uploadBlobInContainer(String base64data, String strFileName, String fileType, Integer flength, String containerName){
        String conDocBody;
        Blob bodyAsBlob = EncodingUtil.base64Decode(base64Data);
        Azure_Connect_Setting__mdt azureSettings = [SELECT azure_Storage_Key__c, Azure_Url__c, Azure_Version__c,Storage_Name__c FROM Azure_Connect_Setting__mdt WHERE DeveloperName = 'azure_Connect'];
        String Azure_storageName = azureSettings.Storage_Name__c; 
        String Azure_Container = containerName;
        String Azure_URL = azureSettings.Azure_Url__c; 
        String Azure_StorageKey = azureSettings.azure_Storage_Key__c;
        String strGMTDate = DateTime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        system.debug ('date:'+strGMTDate);
        String version = azureSettings.Azure_Version__c;
        String fileName = EncodingUtil.urlEncode(strFileName, 'UTF-8');
        String fileLength = String.valueof(flength);
        String canonicalHeader = 'x-ms-blob-type:BlockBlob\nx-ms-date:'+strGMTDate+'\nx-ms-version:2021-12-02\n';
        String canonRes = '/' + Azure_storageName + '/' + Azure_Container + '/' + fileName;
        String stringToSign = 'PUT\n\n\n'+fileLength +'\n\n'+fileType+'\n\n\n\n\n\n\n'+canonicalHeader+canonRes;

        Blob decodedAccountSharedKey = EncodingUtil.base64Decode(Azure_StorageKey);
        String authToken = EncodingUtil.base64Encode(crypto.generateMac('HmacSHA256',Blob.valueOf(stringToSign), decodedAccountSharedKey));
        String authHeader = 'SharedKey ' + Azure_storageName + ':' + authToken;

        String strEndpoint = 'https://'+ Azure_storageName + Azure_URL + Azure_Container + '/' + filename;
        system.debug('endpoint: '+strEndpoint);
        system.debug('authHeader: '+authHeader);

        HttpRequest req = new HttpRequest();
        req.setMethod('PUT');
        req.setHeader('x-ms-date', strGMTDate);
        req.setHeader('x-ms-version', version);
        req.setHeader('x-ms-blob-type', 'BlockBlob');
        req.setHeader('Authorization', authHeader);
        req.setHeader('Content-Length', fileLength);
        req.setHeader('Content-Type', fileType);
        req.setEndpoint(strEndpoint);
        req.setBodyAsBlob(bodyAsBlob);

        system.debug('request: '+req);

        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('response: '+res);
        return getContentsOfContainer(containerName);
    }


    @AuraEnabled
    public static List<azureFileWrapper> deleteBlobFromContainer(String fName, String containerName){
        Azure_Connect_Setting__mdt azureSettings = [SELECT azure_Storage_Key__c, Azure_Url__c, Azure_Version__c,Storage_Name__c FROM Azure_Connect_Setting__mdt WHERE DeveloperName = 'azure_Connect'];
        String Azure_storageName = azureSettings.Storage_Name__c; 
        String Azure_Container = containerName;
        String Azure_URL = azureSettings.Azure_Url__c;
        String filename = fName;
        String Azure_StorageKey = azureSettings.azure_Storage_Key__c;
        String strGMTDate = DateTime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        system.debug ('date:'+strGMTDate);
        String version = azureSettings.Azure_Version__c;
        String canonicalHeader = 'x-ms-date:'+strGMTDate+'\nx-ms-version:2021-12-02\n';
        String canonRes = '/' + Azure_storageName + '/' + Azure_Container + '/'+ filename;
        String stringToSign = 'DELETE\n\n\n\n\n\n\n\n\n\n\n\n'+ canonicalHeader + canonRes;
        system.debug('stringToSign: '+stringToSign);
        Blob decodedAccountSharedKey = EncodingUtil.base64Decode(Azure_StorageKey);
        String authToken = EncodingUtil.base64Encode(crypto.generateMac('HmacSHA256',Blob.valueOf(stringToSign), decodedAccountSharedKey));
        String authHeader = 'SharedKey ' + Azure_storageName + ':' + authToken;
        String strEndpoint = 'https://'+ Azure_storageName + Azure_URL + Azure_Container + '/'+ filename;
        system.debug('endpoint: '+strEndpoint);
        system.debug('authHeader: '+authHeader);
        HttpRequest req = new HttpRequest();
        req.setMethod('DELETE');
        req.setHeader('x-ms-date', strGMTDate);
        req.setHeader('x-ms-version', version);
        req.setHeader('Authorization', authHeader);
        req.setHeader('Content-Length','0');
        req.setEndpoint(strEndpoint);
        system.debug('request: '+req);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('response: '+res.getBody());
        return getContentsOfContainer(containerName);
    }

    @AuraEnabled
    public static List<azureFileWrapper> getContentsOfContainer(String containerName){
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
        String canonRes = '/' + Azure_storageName + '/' + Azure_Container + '\ncomp:list\nrestype:container';
        String stringToSign = 'GET\n\n\n\n\n\n\n\n\n\n\n\n'+ canonicalHeader + canonRes;
        system.debug('stringToSign: '+stringToSign);

        Blob decodedAccountSharedKey = EncodingUtil.base64Decode(Azure_StorageKey);
        String authToken = EncodingUtil.base64Encode(crypto.generateMac('HmacSHA256',Blob.valueOf(stringToSign), decodedAccountSharedKey));
        String authHeader = 'SharedKey ' + Azure_storageName + ':' + authToken;
        String strEndpoint = 'https://'+ Azure_storageName + Azure_URL + Azure_Container + '?restype=container&comp=list';
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
        List<azureFileWrapper> filesInContainer = parseXMLResponse(res.getBody());
        system.debug(filesInContainer);
        return filesInContainer;
    }

    public static List<azureFileWrapper> parseXMLResponse(String xml){
        Dom.Document doc = new Dom.Document();  
        doc.load(xml);
        List<azureFileWrapper> filesInContainer = new List<azureFileWrapper>();
        for(Dom.XMLNode childElement : doc.getRootElement().getChildElements()){
            for(Dom.XMLNode azureBlob : childElement.getChildElements()){
                azureFileWrapper file = new azureFileWrapper();
                Dom.XMLNode properties =azureBlob.getChildElement('Properties', null);
                file.name =  azureBlob.getChildElement('Name', null).getText();
                file.lastModidifed = properties.getChildElement('Last-Modified', null).getText();
                file.eTag = properties.getChildElement('Etag', null).getText().remove('"');
                file.contentType = properties.getChildElement('Content-Type', null).getText();
                filesInContainer.add(file);
            }
        }
        return filesInContainer; 
    }


    @AuraEnabled(cacheable=true)
    public static List<azureContainerWrapper> getListOfContainers(){
        Azure_Connect_Setting__mdt azureSettings = [SELECT azure_Storage_Key__c, Azure_Url__c, Azure_Version__c,Storage_Name__c FROM Azure_Connect_Setting__mdt WHERE DeveloperName = 'azure_Connect'];
        String Azure_storageName = azureSettings.Storage_Name__c; 
        String Azure_URL = azureSettings.Azure_Url__c;
        String Azure_StorageKey = azureSettings.Azure_Version__c; 
        String strGMTDate = DateTime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        system.debug ('date:'+strGMTDate);
        String version = azureSettings.Azure_Version__c;
        String conDate = 'x-ms-date:'+strGMTDate;

        String canonicalHeader = 'x-ms-date:'+strGMTDate+'\nx-ms-version:2021-12-02\n';
        String canonRes = '/' + Azure_storageName + '/' + '\ncomp:list';
        String stringToSign = 'GET\n\n\n\n\n\n\n\n\n\n\n\n'+ canonicalHeader + canonRes;
        system.debug('stringToSign: '+stringToSign);

        Blob decodedAccountSharedKey = EncodingUtil.base64Decode(Azure_StorageKey);
        String authToken = EncodingUtil.base64Encode(crypto.generateMac('HmacSHA256',Blob.valueOf(stringToSign), decodedAccountSharedKey));
        String authHeader = 'SharedKey ' + Azure_storageName + ':' + authToken;
        String strEndpoint = 'https://'+ Azure_storageName + Azure_URL + '?comp=list';
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
        String responseBody = res.getBody();
        List<azureContainerWrapper> containers = parseContainerListResponse(responseBody);
        system.debug(containers);
        return containers;
    }


    public static List<azureContainerWrapper> parseContainerListResponse(String xml){
        Dom.Document doc = new Dom.Document();  
        doc.load(xml);
        List<azureContainerWrapper> containers = new List<azureContainerWrapper>();
        for(Dom.XMLNode allContainers : doc.getRootElement().getChildElements()){
            for(Dom.XMLNode containerNode : allContainers.getChildElements()){
                azureContainerWrapper container = new azureContainerWrapper();
                Dom.XMLNode properties =containerNode.getChildElement('Properties', null);
                container.name = containerNode.getChildElement('Name', null).getText();
                container.lastModidifed = properties.getChildElement('Last-Modified', null).getText();
                container.eTag = properties.getChildElement('Etag', null).getText().remove('"');
                containers.add(container);
            }
        }
        return containers;
    }

}