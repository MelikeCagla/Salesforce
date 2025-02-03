@RestResource(urlMapping='/WSInvoicesAll/*')
global class WSInvoicesAll {
    @HttpPost
    global static void PostAccounts() {
        Savepoint sp = Database.setSavepoint();
        System.debug(sp);
        List<Info> infoList = new List<Info>();
        try {
            String jsonBody = RestContext.request.requestBody.toString();
            List<USINGERPREC> usingErpRecs = parseUSINGERPREC(jsonBody);
            System.debug(usingErpRecs);
            
            if (usingErpRecs.size() > 0)
            {
            List<Invoice__c> invoicesToInsert = new List<Invoice__c>();
            List<Invoice__c> invoicesToUpdate = new List<Invoice__c>(); 
            List<Invoice__c> invoicesToDelete = new List<Invoice__c>(); 
            List<Invoice_Item__c> invoiceItemsToDelete = new List<Invoice_Item__c>();
            List<Invoice_Item__c> invoiceItemsToInsert = new List<Invoice_Item__c>();
            
            List<String> ids = new List<String>();
            List<String> invoiceIds = new List<String>();
            List<String> oldInvoiceIds = new List<String>(); 
            List<String> purInfos = new List<String>();
            List<String> productCodeIds = new List<String>();
            List<String> orderCodeIds = new List<String>();
            List<String> invoiceDeletedQuoteIds = new List<String>();
            List<String> invoiceIds2Delete = new List<String>();
            Map<String,Product2> proMap = new Map<String,Product2>();  
            Map<String,Order> ordMap = new Map<String,Order>();  
            Map<String,Invoice__c> invoiceIdMap = new Map<String,Invoice__c>();  
            Map<String,Invoice__c> idMap = new Map<String,Invoice__c>();  
            Map<String,PriceInfo> priceInfoOldMap = new Map<String,PriceInfo>();
            Map<String,PriceInfo> priceInfoNewMap = new Map<String,PriceInfo>(); 
            Map<String,String> invoiceStatusMap = new Map<String,String>();  
            Map<String,Account> accountMap = new Map<String,Account>();  
            List<String> accountCodes = new List<String>();
            List<String> salDeptCodes = new List<String>();

            for (USINGERPREC usingErpRec: usingErpRecs) {
                String invoiceId = usingErpRec.INVOICEID;            
                
                for (Integer oi=0; oi< usingErpRec.InvoiceItems.size(); oi++) {
                    USINGERPItem ci = usingErpRec.InvoiceItems[oi];
                    ci.ProductCode = ci.ProductCode.trim();
                    productCodeIds.add(ci.ProductCode); 

                    ci.Reference_Order_Number = ci.Reference_Order_Number.trim();
                    orderCodeIds.add(ci.Reference_Order_Number); 
                }
                invoiceIds.add(usingErpRec.INVOICEID);	
                if (usingErpRec.ID instanceOf Id) {                    
                    ids.add(usingErpRec.ID);	
                }

                if (!String.isBlank(usingErpRec.Partner_Code)) {                    
                    accountCodes.add(usingErpRec.Partner_Code);	
                }

                
            }
            
            System.debug('usingErpRecs');
            System.debug(usingErpRecs);
            List<Order> orderList = [SELECT Id, C_Code__c, Name FROM Order WHERE C_Code__c IN :orderCodeIds ];           
            for(Order ord : orderList){
                ordMap.put(ord.C_Code__c ,ord);
            } 

            List<Product2> productList = [SELECT Id, C_Code__c, Name FROM Product2 WHERE C_Code__c IN :productCodeIds ];           
            for(Product2 pro : productList){
                proMap.put(pro.C_Code__c ,pro);
            } 

            for(Invoice__c inv : [SELECT Id, Name, C_Code__c, Invoice_Document_Type__c , Invoice_Document_Number__c, CurrencyIsoCode
                             FROM Invoice__c 
                             WHERE C_Code__c IN :invoiceIds OR Id IN :ids
                            ]){
                                idMap.put(inv.Id ,inv);
                                invoiceIdMap.put(inv.C_Code__c ,inv);
                                oldInvoiceIds.add(inv.Id);
                            } 
            
            for(Invoice_Item__c oitem : [SELECT Id
                                   FROM Invoice_Item__c 
                                   WHERE InvoiceId__c IN :oldInvoiceIds
                                  ]){
                                      invoiceItemsToDelete.add(oitem);
                                  } 
            
            List<Account> accountList = [SELECT Id, C_Customer__c FROM Account WHERE C_Customer__c IN :accountCodes];           
            for(Account acc : accountList){
                accountMap.put(acc.C_Customer__c ,acc);
            }
            System.debug(accountMap);

            for (USINGERPREC usingErpRec: usingErpRecs) {
                
                System.debug('usingErpRec.ID instanceOf Id:'+usingErpRec.ID instanceOf Id);
                Invoice__c inv = (usingErpRec.ID instanceOf Id) ? idMap.get(usingErpRec.ID) : new Invoice__c();
                System.debug('inv:'+inv);
                inv = (inv == null) ?  new 	Invoice__c() : inv;
                System.debug('bosmu:'+String.isBlank(inv.Id));
                inv = String.isBlank(inv.Id) ? invoiceIdMap.get(usingErpRec.INVOICEID) : inv;
                System.debug('inv:'+inv);
                inv = (inv == null) ?  new Invoice__c() : inv;
                System.debug('inv:'+inv);
                System.debug('inv.Id:'+inv.Id);
                Boolean isNewInvoice = String.isBlank(inv.Id);
                usingErpRec.ID = isNewInvoice ? '' : inv.Id;
                System.debug('usingErpRec.ID:'+usingErpRec.ID);
                System.debug('isNewInvoice:'+isNewInvoice);

                inv.Invoice_Document_Type__c = usingErpRec.Invoice_Document_Type;
                inv.Invoice_Document_Number__c = usingErpRec.Invoice_Document_Number;
                inv.Country__c = usingErpRec.Country;
                inv.Exchange_Rate_Information__c = usingErpRec.Exchange_Rate_Information;
                inv.External_Invoice_Number__c = usingErpRec.External_Invoice_Number;
                inv.Grand_Total__c = usingErpRec.Grand_Total;
                inv.Invoice_ValidFrom__c = usingErpRec.Invoice_ValidFrom;
                inv.IsStop__c = usingErpRec.IsStop;
                inv.CurrencyIsoCode = usingErpRec.CurrencyIsoCode;

                if (usingErpRec.DeletedSF) {
                    invoiceIds2Delete.add(inv.Id);  
                    invoicesToDelete.add(inv);	

                } else {
                    if(isNewInvoice){
                        Invoice__c newInvoice = new Invoice__c();
                        newInvoice = mapUSINGERPRec2Invoice(newInvoice,usingErpRec, accountMap);     
                        System.debug(newInvoice);      
                        invoicesToInsert.add(newInvoice);
                        System.debug(invoicesToInsert);   
                    } else {
                        String oldCurrencyIsoCode = inv.CurrencyIsoCode == null ? '' : inv.CurrencyIsoCode; 
                        String newCurrencyIsoCode = usingErpRec.CurrencyIsoCode == null ? '' : usingErpRec.CurrencyIsoCode; 
                        inv = mapUSINGERPRec2Invoice(inv,usingErpRec, accountMap);   
                        
                        for (Integer oi=0; oi< usingErpRec.InvoiceItems.size(); oi++) {
                            USINGERPItem ci = usingErpRec.InvoiceItems[oi];
                            Product2 product = proMap.get(ci.ProductCode);   
                            Order order = ordMap.get(ci.Reference_Order_Number);                      
                            if (product != null) {
                                Invoice_Item__c oitem = new Invoice_Item__c();

                                oitem.InvoiceId__c = inv.Id;
                                oitem.GrandTotal__c = ci.GrandTotal;
                                oitem.CurrencyIsoCode = ci.CurrencyIsoCode;
                                oitem.ProductName__c = product.Id;
                                oitem.Quantity__c = ci.Quantity;
                                oitem.Reference_Order_Number__c = order.Id;
                                oitem.Unit__c = ci.Unit;
                                oitem.VAT_Amount__c = ci.VAT_Amount;
                                oitem.Voption__c = ci.Voption;
                                invoiceItemsToInsert.add(oitem); 
                                
                            }                   
                            
                        } 
                        invoicesToUpdate.add(inv);
                    } 
                }

                System.debug(inv);
                
            }

            List<String> usingErpIds = new List<String>();
            List<String> relatedObjectIds = new List<String>();
            
             // Updates changes to the invoice
            for(Invoice__c inv : invoicesToUpdate) {     
                PriceInfo priceInfo = priceInfoOldMap.get(inv.Id);
                usingErpIds.add(inv.C_Code__c);
            } 
            List<Database.SaveResult> resultUpdateInvoiceStatusDraft = new List<Database.SaveResult>();
            if (invoicesToUpdate.size() > 0) {
                resultUpdateInvoiceStatusDraft = Database.update(invoicesToUpdate,false);
            }
            
            logSaveResults('Successfully Updated Invoice to Draft', infoList,resultUpdateInvoiceStatusDraft, usingErpIds, 'Invoice', '', relatedObjectIds);
			

            List<Database.DeleteResult> resultDeleteInvoiceItems = new List<Database.DeleteResult>();
            if (invoiceItemsToDelete.size() > 0) {
                resultDeleteInvoiceItems = Database.delete(invoiceItemsToDelete,false);
            }
            
            // delete invoices invoicesToDelete
            List<Database.DeleteResult> resultDeleteInvoices = new List<Database.DeleteResult>();
            if (invoicesToDelete.size() > 0) {
                delete invoicesToDelete;
            }
			
             // Deletes the invoice according to the generated ID information
            System.debug('invoicesToDelete');
            System.debug(invoicesToDelete);
            for(Integer index=0;index<resultDeleteInvoices.size();index++){
                Database.DeleteResult sr = resultDeleteInvoices[index];
                Info info = new Info();
                info.message = (sr.isSuccess() ? 'Successfully Deleted' : String.valueOf(sr.getErrors()));
                info.isSuccess = sr.isSuccess();
                info.companyId = usingErpIds[index];
                info.objectId = sr.getId();
                info.objectType = 'Invoice';
                info.relatedObjectType = '';
                info.relatedObjectId = '';
                infoList.add(info);
            }
            System.debug('resultDeleteInvoices');
            System.debug(resultDeleteInvoices);
            
            
            // Inserted Invoice Item Information       
            List<Database.SaveResult> insertResultItems = new List<Database.SaveResult>();
            if (invoiceItemsToInsert.size() > 0) {
                insertResultItems = Database.insert(invoiceItemsToInsert,false); 
                usingErpIds = new List<String>();
                relatedObjectIds = new List<String>(); 
                for(Invoice_Item__c oitem: invoiceItemsToInsert) {
                    usingErpIds.add(oitem.InvoiceId__c);
                    relatedObjectIds.add(oitem.InvoiceId__c);
                }
                logSaveResults('Successfully Inserted Invoice Items', infoList,insertResultItems, usingErpIds, 'InvoiceItem', 'Invoice', relatedObjectIds);
                
            }
            
        
            // Inserted Invoice Head Information
            List<Database.SaveResult> resultInsertInvoices = new List<Database.SaveResult>();
            if (invoicesToInsert.size() > 0) {
                resultInsertInvoices = Database.insert(invoicesToInsert,false);
                usingErpIds = new List<String>();
                relatedObjectIds = new List<String>(); 
                System.debug(invoicesToInsert);
                
                for(Invoice__c inv : invoicesToInsert) {     
                    usingErpIds.add(inv.C_Code__c);
                    Id insertedId = resultInsertInvoices[0].getId();
                    System.debug('Inserted Record ID: ' + insertedId);
                    makeCallout(insertedId,inv.C_Code__c);
                    System.debug('usingErp SFKEY created.');
                                  
                } 
                logSaveResults('Successfully Inserted Invoice', infoList,resultInsertInvoices, usingErpIds, 'Invoice', '', relatedObjectIds);
            } 

            String jsonResponse = JSON.serialize(infoList);   
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(jsonResponse);
            return;
            }
            else {
                return;
            }

        }
        catch(Exception ex) {
            Database.rollback(sp);
            System.debug('error');
            System.debug(String.valueOf(ex.getMessage()));
            String jsonResponse = JSON.serialize(infoList);            
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(jsonResponse);
            return;
        }

    }

    @future(callout=true)
    public static void makeCallout(String insertedId, String usingErpId) {
        // getInvoiceSFKey service is provides the erp connections to use. The place where we merge data from ERP.
        String response = getInvoiceSFKey(insertedId,usingErpId);
        System.debug(response);
    }

    public static String getInvoiceSFKey(String SFKey,String usingErpId) {
        String response;
        if(SFKey != '')
        {
            //HNUsingERP is where SOAP and REST services are written
            response = HNUsingERP.callButunbiConnectorSync('getInvoiceSFKey','{"cnparameters":["T", "INVOICEDOC", "' + SFKey + '", "' + usingErpId + '"]}');
            if (Test.isRunningTest()) {
                response = '{"isSuccess":true,"data":{}';
            }
        }
        else {
            response = '{"isSuccess":false,"data":{}';
        }
        
        return response;
    }

    public static Invoice__c mapUSINGERPRec2Invoice(Invoice__c invoice,USINGERPREC usingErpRec,Map<String,Account> accountMap) {
        invoice.Invoice_Document_Type__c = usingErpRec.Invoice_Document_Type;
        invoice.Invoice_Document_Number__c = usingErpRec.Invoice_Document_Number;
        invoice.Country__c = usingErpRec.Country;
        invoice.C_Code__c = usingErpRec.C_Code;
        invoice.Exchange_Rate_Information__c = usingErpRec.Exchange_Rate_Information;
        invoice.External_Invoice_Number__c = usingErpRec.External_Invoice_Number;
        invoice.Grand_Total__c = usingErpRec.Grand_Total;
        invoice.Invoice_ValidFrom__c = usingErpRec.Invoice_ValidFrom;
        invoice.IsStop__c = usingErpRec.IsStop;
        invoice.CurrencyIsoCode = usingErpRec.CurrencyIsoCode;
        Account account = accountMap.get(usingErpRec.Partner_Code);
        account = account == null ? new Account() : account;               
        invoice.Partner_Name__c = account.Id;
        invoice.Total_Discount__c = usingErpRec.Total_Discount;
        invoice.Total_Gross_Total__c = usingErpRec.Total_Gross_Total;
        invoice.Total_Invoice_Quantity__c = usingErpRec.Total_Invoice_Quantity;
        return invoice;
    }

    public static List<Info> logSaveResults(String message, List<Info> infoList, List<Database.SaveResult> saveResults, List<String> usingErpIds, String objectType, String relatedObjectType, List<String> relatedObjectIds) {
        for(Integer index=0;index<saveResults.size();index++){
            Database.SaveResult sr = saveResults[index];
            Info info = new Info();
            info.message = (sr.isSuccess() ? message : String.valueOf(sr.getErrors()));
            info.isSuccess = sr.isSuccess();
            info.companyId = usingErpIds[index];
            info.objectId = sr.getId();
            info.objectType = objectType;
            info.relatedObjectType = relatedObjectType;
            info.relatedObjectId = relatedObjectIds.size() > 0 ? relatedObjectIds[index] : '';
            infoList.add(info);
        }
        return infoList;
    }

    public static List<USINGERPREC> parseUSINGERPREC(String json) {
        return (List<USINGERPREC>) System.JSON.deserialize(json, List<USINGERPREC>.class);
    }
    public class PriceInfo {
        public String Pricebook2Id;
        public String CurrencyIsoCode;
    }

    public class USINGERPREC {
        public String ID;
        public String INVOICEID;
        public String STEXT;
        public String C_Code;
        public String Invoice_Document_Type;
        public String Invoice_Document_Number;
        public String Country;
        public Double Exchange_Rate_Information;
        public String External_Invoice_Number;
        public Double Grand_Total;
        public Date Invoice_ValidFrom;
        public Boolean IsStop;
        public String CurrencyIsoCode;
        public String Partner_Code;
        public String Partner_Name;
        public Double Total_Discount;
        public Double Total_Gross_Total;
        public Double Total_Invoice_Quantity;
        public Double Total_Net_Total;
        public Boolean DeletedSF;
        public List<USINGERPItem> InvoiceItems;
    }

    public class USINGERPItem {
        public Double List_Price;
        public Double Net_Price;
        public String CurrencyIsoCode;
        public String ProductCode;
        public String ProductName;
        public Double Quantity;
        public Double Quantity_Converted;
        public String Reference_Order_Number;
        public Double SubTotal;
        public String Unit;
        public Double VAT_Amount;
        public String Voption;
    }

    public class Info{
        public String message;
        public Boolean isSuccess;     
        public String companyId;   
        public String objectType;
        public String objectId;    
        public String relatedObjectType;
        public String relatedObjectId;
    }  
}