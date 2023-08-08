

class InvoicerListRepo {

  List<InvoicerList> saveList = [];

}

class InvoicerList {

  String CompanyName;
  String InvoiceNo;
  DateTime Date;
  double Amount;

  InvoicerList(this.CompanyName, this.InvoiceNo, this.Date, this.Amount);

  InvoicerList.save(this.CompanyName, this.InvoiceNo, this.Date, this.Amount) {

  }
}