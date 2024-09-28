
const String describeInvoicePrompt =
    """
Read the invoice in the picture, analyze the products purchased one by one and answer the questions below:

- Are the products purchased harmful to human health?
- Are the purchased products harmful to the environment?
- What are the alternatives to the products purchased?
- What can be suggested for more conscious consumption?
- What is the market value of the products purchased? How has this value changed in the last year?

Do not include any description, just provide an RFC8259 compliant JSON response that conforms to this format.

{
 "which_items_bought": [
  {
  "name": "",
  "price": "",
  }
 "any_health_problem": "",
 "any_habitat problem": "",
 "alternatives": [
  {
  "name": "",
  "description": "",
  }
 "conscious_consumption": "",
 "market_research": ""
}""";


const String identifyInvoicePrompt =
"""
Read the invoice in the picture. Identify the company name with company type, invoice number, date in dd-MM-yyyy format, total amount, tax amount, company id and invoice category.
Do not include any description, just provide an RFC8259 compliant JSON response that conforms to this format.

Category types: Food, Clothing, Electronics, Health, Education, Transportation, Entertainment, Others
Company types: SP, LTD, LLC, PLC, INC, GMBH, CORP, JSC
Units: EUR, USD, TRY, GBP, JPY, CNY, RUB, AUD, CAD

{
 "companyName": "",
 "invoiceNo": "",
 "date": "",
 "totalAmount": "",
 "taxAmount": "",
 "category": "",
 "unit": "",
 "companyId": ""
}""";
