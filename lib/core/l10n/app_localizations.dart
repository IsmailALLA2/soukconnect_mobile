import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('ar'),
  ];

  /// The name of the application
  ///
  /// In fr, this message translates to:
  /// **'SoukConnect'**
  String get appName;

  /// Login button / page title
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login;

  /// Register button / page title
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get register;

  /// Email input label
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get email;

  /// Password input label
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// Phone input label
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get phone;

  /// Full name input label
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fullName;

  /// Wilaya / province selector label
  ///
  /// In fr, this message translates to:
  /// **'Wilaya'**
  String get wilaya;

  /// User role selector label
  ///
  /// In fr, this message translates to:
  /// **'Rôle'**
  String get role;

  /// Wholesaler role label
  ///
  /// In fr, this message translates to:
  /// **'Grossiste'**
  String get grossiste;

  /// Retailer role label
  ///
  /// In fr, this message translates to:
  /// **'Détaillant'**
  String get detaillant;

  /// Home screen section: nearby stores
  ///
  /// In fr, this message translates to:
  /// **'Commerces à proximité'**
  String get nearbyStores;

  /// Tab / page: my orders
  ///
  /// In fr, this message translates to:
  /// **'Mes commandes'**
  String get myOrders;

  /// Tab / page: my store
  ///
  /// In fr, this message translates to:
  /// **'Mon commerce'**
  String get myStore;

  /// Products section / page title
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get products;

  /// Add to cart button
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au panier'**
  String get addToCart;

  /// Place order button
  ///
  /// In fr, this message translates to:
  /// **'Passer la commande'**
  String get placeOrder;

  /// Order status: pending
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get pending;

  /// Order status: confirmed
  ///
  /// In fr, this message translates to:
  /// **'Confirmée'**
  String get confirmed;

  /// Order status: cancelled
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get cancelled;

  /// Order status: delivered
  ///
  /// In fr, this message translates to:
  /// **'Livrée'**
  String get delivered;

  /// Logout button
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout;

  /// Settings page title
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// Search field hint text
  ///
  /// In fr, this message translates to:
  /// **'Rechercher...'**
  String get search;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
