![logo_banner.png](design%2Flogo_banner.png)

> I started this project when I first started learning Flutter in August 2023 when I participated in the SupaBase Hackathon. Of course, I postponed it because it wasn't finished and I was new to Flutter. Months later, I started the project again in January 2024 and after a 3-week process, I got it ready to showcase it. I thought maybe it would work in some way in the Solution Challenge.

## Overview 🧾
- Artificial intelligence supported invoice reading application. It categorizes and saves them on a company basis according to the information in the invoice. It can analyze the impact of the products in the invoices on the person and the environment and can save time on financial transactions by taking Excel output.


- [You can download the APK in the releases section.](https://github.com/myavuzokumus/InvoiX/releases)

![invoix_main_design.png](design%2Finvoix_main_design.png)

## Installation ✨

1. Create a new Flutter project:
```
flutter create invoix
```

2. Clone the repository:
```
git clone https://github.com/myavuzokumus/InvoiX.git
```

3. Test your changes by running the app on a physical device:
```
flutter run
```

> [!IMPORTANT]
> You need to create `.env` file in root directory. And add that following things:
> - GEMINI_API_KEY= ""

## Solution areas covered 🌍
- **Goal 9 | Industry, Innovation and Infrastructure:**
  - Promotes industry and infrastructure by optimizing and digitizing invoice processing.
It can contribute to the fight against corruption by increasing financial transparency and accountability.


- **Goal 12 | Responsible Production and Consumption:**
  - Analyzing invoice data can help reduce resource waste and environmental pollution.
  It can encourage consumers to consume responsibly and use resources more sustainably.

## Target audience 👥
- **For Businesses:**
  - _Increased Productivity:_ Significantly reduces invoice processing time and costs, helping businesses save time and money.
  - _Error Reduction:_ Improves the accuracy and reliability of the invoicing process by eliminating manual data entry errors.
  - _Better Insight:_ By analyzing invoice data, it helps businesses better understand their finances and better predict future cash flows.


- **For Accountants:**
  - _Time Savings:_ Reduces time spent on invoice processing and data entry, allowing accountants to focus on more complex tasks.
  - _Data Accuracy:_ Improves the accuracy and reliability of accounting records by eliminating manual data entry errors.
  - _Compliance:_ Helps accountants comply with billing regulations by automatically categorizing and organizing invoice data.


- **For Consumers:**
  - _Easy Archiving:_ Helps consumers easily find and manage their invoices by storing invoice archives digitally.
  - _Income and Expense Tracking:_ Analyzes invoice data to help consumers better track their income and expenses and manage their budgets more effectively.
  - _Error Reduction_ Detects errors in billing information, helping consumers avoid financial losses due to incorrect invoices.


- And of course every audience can see the impact of products on humans and the environment and alternatives through invoice analysis.


## Packages

- [hive](https://pub.dev/packages/hive) - To save for the user’s invoices data in device’s storage. (InvoiceData, Read Mode, AI usage cooldown time, etc.)
- [syncfusion_flutter_xlsio](https://pub.dev/packages/syncfusion_flutter_xlsio) - To export invoices data with image to .xlsx file.
- [google_mlkit_text_recognition](https://pub.dev/packages/google_mlkit_text_recognition) - To read texts in image.
- opencv - It reads the corners of the invoice and ensures that it is trimmed.

---


#### Credits
Holding phone image by <a href="https://www.freepik.com/free-photo/digital-nomad-working-remotly-their-project_21795565.htm#from_view=detail_alsolike">Freepik</a>\
Phone canvas images by <a href="https://www.freepik.com/free-psd/dark-smartphone-mockup_9549207.htm#query=app%20mockup&position=6&from_view=keyword&track=ais&uuid=3a9c6107-c190-4c92-bbb3-7c4a6407e700">Deeplab on Freepik</a> 