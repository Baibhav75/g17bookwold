class ApiConstants {
  static const String baseUrl = "https://g17bookworld.com/api/";

  /// Sample Purchase List Details Invoice
  static String purchaseSampleInvoice(String billNo) =>
      "${baseUrl}PurchaseSamplerevenwDetails/GetPurchaseInvoice?billNo=$billNo";

// purchaseSampleLedger details

  static String purchaseSampleLedger(String publicationId) =>
      "${baseUrl}PurchaseSampleRevenewLadger/GetLedgerPurchaseSample?publicationId=$publicationId";


// purchaseReturnNotSaleInvoice}
  static String purchaseReturnNotForSaleInvoice(String billNo) =>
      "${baseUrl}PurchaseReturnNotForSaleDetails/GetPurchaseInvoice?billNo=$billNo";

  // purchaseREturnSampleREvenewDetails
  static String purchaseInvoice(String billNo) =>
      "$baseUrl/PurchaseReturnSampleRevenewDetails/GetPurchaseInvoice?billNo=$billNo";

  // SaleReturnMrpDetails

  static String saleReturnMrpInvoice(String billNo) =>
      "${baseUrl}SaleReturnMrpDetails/ViewSaleMRPInvoice?billNo=$billNo";

  // PurchseReturnListDeatils Invoice
  static String purchaseReturnDetails(String billNo) =>
      "$baseUrl/PurchaseReturnDetails/GetPurchaseInvoice?billNo=$billNo";

  // sale simple desing

  static const String saleSuperBrandBillDetails =
      "SuperBrandBillingSampleDetails/ViewSaleMRPInvoice";

  // Purchase View StockRegister
  static const String stockRegister =
      "ViewStoctRegister/GetStockRegister";

  // add day Book hstory
  static const String dayBookDetails =
      "$baseUrl/Ledger/ViewDetailsGenral";
 // Sample Bill ladger history invoice
  static String sampleSaleLedger(String schoolName) {
    return "$baseUrl/LedgerSaleSample/ViewLedgerSaleSample?schoolname=$schoolName";
  }

}
