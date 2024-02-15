# InvoiX

> I started this project when I first started learning Flutter in August 2023 when I participated in the SupaBase Hackathon. Of course, I postponed it because it wasn't finished and I was new to Flutter. Months later, I started the project again in January 2024 and after a 3-week process, I got it ready to showcase it. I thought maybe it would work in some way in the Solution Challenge.

A Flutter application that allows you to quickly read the invoices at hand, get the necessary information and then output it as an .xlsx file.

### TODO:
- Removing companies and invoices will be added.

## Installation

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

## Packages

- [hive](https://pub.dev/packages/hive) - To save for the user’s invoices data in device’s storage.
- [syncfusion_flutter_xlsio](https://pub.dev/packages/syncfusion_flutter_xlsio) - To export invoices data with image to .xls file.
- [google_mlkit_text_recognition](https://pub.dev/packages/google_mlkit_text_recognition) - To read texts in image.
- opencv - It reads the corners of the invoice and ensures that it is trimmed.
- [shared_preferences](https://pub.dev/packages/shared_preferences) - To save the user’s settings in device’s storage. (Read Mode, AI usage cooldown time, etc.)