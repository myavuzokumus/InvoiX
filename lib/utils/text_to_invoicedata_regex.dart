//Regex
//RegExp NameRegex = RegExp(r"\b([A-ZÀ-ÿ][-,a-z. ']+[ ]*)+", caseSensitive: false);

// I need to find a different solution here, because it is not working perfectly.
// I inspected some similar projects and they are working perfectly but they are not open source. They probably using OCR.
// I am open to contributions.
// Google ML Text Recognition is not working perfectly, so it can’t read everything properly.
// OCR can be used here, but there are a lot of projects already available (GCS also has invoice recognition but it needs a price to use).
// So I wanna make my own parser or reader for the best use of Google ML Text Recognition.

final RegExp companyRegex =
    RegExp(r"(?:LTD\.|ŞTİ\.|(A\.Ş\.|A\.S\.)|LLC|PLC|INC|GMBH)", caseSensitive: false);

final RegExp invoiceNoRegex = RegExp(r'NO\s*:\s*(\S+)', caseSensitive: false);

final RegExp dateRegex = RegExp(
    r"(0[1-9]|[12][0-9]|3[01])(\/|-|\.)(0[1-9]|1[1,2])(\/|-|\.)(19|20)\d{2}",
    caseSensitive: false);

final RegExp amountRegex = RegExp(
    r"^(\$|\₺|€|\*)?(0|[1-9][0-9]{0,2})(,\d{1,4})*(\.\d{1,2})?$|^(0|[1-9][0-9]{0,2})(,\d{1,4})*(\.\d{1,2})?(\$|\₺|TL|€|\*)?",
    caseSensitive: false);
