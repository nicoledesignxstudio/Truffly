// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get emailRequired => 'L\'email è obbligatoria';

  @override
  String get invalidEmail => 'Inserisci un indirizzo email valido';

  @override
  String get passwordRequired => 'La password è obbligatoria';

  @override
  String get passwordTooShort =>
      'La password deve contenere almeno 8 caratteri';

  @override
  String get passwordLettersNumbers =>
      'La password deve contenere lettere e numeri';

  @override
  String get confirmPasswordRequired => 'La conferma password è obbligatoria';

  @override
  String get passwordsDoNotMatch => 'Le password non coincidono';

  @override
  String get authLoginTitle => 'Bentornato';

  @override
  String get authLoginSubtitle =>
      'Accedi per continuare ad acquistare e vendere tartufi premium.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'nome@esempio.com';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authLoginButton => 'Accedi';

  @override
  String get authForgotPasswordLink => 'Password dimenticata?';

  @override
  String get authNoAccountText => 'Non hai un account?';

  @override
  String get authSignupLink => 'Registrati';

  @override
  String get authSignupTitle => 'Crea account';

  @override
  String get authSignupSubtitle =>
      'Unisciti al marketplace affidabile per acquistare e vendere tartufi premium.';

  @override
  String get authConfirmPasswordLabel => 'Conferma password';

  @override
  String get authSignupButton => 'Registrati';

  @override
  String get authAlreadyHaveAccountText => 'Hai già un account?';

  @override
  String get authLoginLink => 'Accedi';

  @override
  String get authErrorInvalidCredentials => 'Email o password non valide.';

  @override
  String get authErrorEmailNotVerified =>
      'Verifica la tua email prima di accedere.';

  @override
  String get authErrorNetwork =>
      'Errore di rete. Controlla la connessione e riprova.';

  @override
  String get authErrorTimeout => 'Tempo scaduto. Riprova.';

  @override
  String get authErrorUnknown => 'Si è verificato un errore. Riprova.';

  @override
  String get authErrorEmailAlreadyUsed => 'Questa email è già in uso.';

  @override
  String get authErrorEmailResendRateLimited =>
      'Hai richiesto troppe email di verifica. Attendi qualche minuto e riprova.';

  @override
  String get authErrorEmailDeliveryRestricted =>
      'Non possiamo inviare l\'email di verifica a questo indirizzo. Controlla l\'email inserita o configura SMTP personalizzato.';

  @override
  String get authPasswordResetRateLimitedError =>
      'Hai richiesto troppi link di reset. Attendi qualche minuto e riprova.';

  @override
  String get authPasswordResetDeliveryRestrictedError =>
      'Non possiamo inviare l\'email di reset a questo indirizzo. Controlla l\'email inserita o configura SMTP personalizzato.';

  @override
  String get authErrorLoginFallback => 'Impossibile accedere. Riprova.';

  @override
  String get authErrorSignupFallback =>
      'Impossibile creare l\'account. Riprova.';

  @override
  String get authVerifyEmailTitle => 'Verifica la tua email';

  @override
  String get authVerifyEmailSubtitle =>
      'Ti abbiamo inviato un link di verifica al tuo indirizzo email. Confermalo per continuare.';

  @override
  String get authVerifyEmailCurrentEmail => 'Email';

  @override
  String get authVerifyEmailRecheckButton => 'Ho verificato l\'email';

  @override
  String get authVerifyEmailWrongEmailCta => 'Ho sbagliato email';

  @override
  String get authVerifyEmailNotYetVerified =>
      'La tua email non è ancora verificata.';

  @override
  String get authVerifyEmailSessionExpired =>
      'La sessione è scaduta. Accedi di nuovo.';

  @override
  String get authVerifyEmailResendButton => 'Invia di nuovo email';

  @override
  String get authVerifyEmailResendSuccess =>
      'Ti abbiamo inviato una nuova email di verifica. Controlla la tua casella di posta.';

  @override
  String get authVerifyEmailMissingEmail =>
      'Impossibile trovare l\'email per il reinvio.';

  @override
  String get authVerifyEmailAutoContinueHint =>
      'Dopo aver cliccato il link nell\'email, l\'app continuerà automaticamente.';

  @override
  String get authVerifyEmailSignOutButton => 'Esci';

  @override
  String get authVerifyEmailSpamHint =>
      'Se non vedi l\'email, controlla la cartella spam.';

  @override
  String get authForgotPasswordTitle => 'Reimposta password';

  @override
  String get authForgotPasswordSubtitle =>
      'Inserisci la tua email e ti invieremo un link per reimpostare la password.';

  @override
  String get authForgotPasswordButton => 'Invia link di reset';

  @override
  String get authForgotPasswordSuccess =>
      'Controlla la tua email: ti abbiamo inviato un link per reimpostare la password.';

  @override
  String get authForgotPasswordErrorFallback =>
      'Impossibile inviare l\'email di reset. Riprova.';

  @override
  String get authForgotPasswordBackToLogin => 'Torna al login';

  @override
  String get authResetPasswordTitle => 'Reimposta password';

  @override
  String get authResetPasswordSubtitle =>
      'Scegli una nuova password sicura per il tuo account.';

  @override
  String get authResetPasswordNewPasswordLabel => 'Password';

  @override
  String get authResetPasswordButton => 'Aggiorna password';

  @override
  String get authResetPasswordSuccess => 'Password aggiornata con successo.';

  @override
  String get authResetPasswordInvalidLink =>
      'Il link di reset non è valido o è scaduto.';

  @override
  String get authResetPasswordInvalidRecoverySession =>
      'Sessione di recupero non valida. Apri di nuovo il link di reset.';

  @override
  String get authResetPasswordErrorFallback =>
      'Impossibile reimpostare la password. Riprova.';

  @override
  String get authResetPasswordSuccessTitle => 'Password aggiornata';

  @override
  String get authResetPasswordSuccessMessage =>
      'La tua password è stata aggiornata con successo.';

  @override
  String get authResetPasswordSuccessButton => 'Torna al login';

  @override
  String get authWelcomeTitle => 'Porta a casa il sapore autentico del tartufo';

  @override
  String get authWelcomeSubtitle =>
      'Il primo marketplace dedicato ai tartufi freschi';

  @override
  String get authWelcomeCreateAccountButton => 'Iscriviti a Truffly';

  @override
  String get authWelcomeLoginButton => 'Ho già un account';

  @override
  String get authWelcomeFooterInfo =>
      'Informazioni su Truffly: La nostra piattaforma';

  @override
  String get welcomeFreshTrufflesHome => 'Tartufi freschi a casa tua';

  @override
  String get welcomeRealFreshTruffle => 'Il vero tartufo fresco';

  @override
  String get welcomeDiscoverNewFlavors => 'Scopri nuovi sapori';

  @override
  String get welcomeVerifiedHunters => 'Tartufai verificati';

  @override
  String get welcomeSelectedQuality => 'Qualità selezionata';

  @override
  String get welcomeProtectedPurchases => 'Acquisti protetti';

  @override
  String get onboardingNameTitle => 'Dicci come ti chiami';

  @override
  String get onboardingNameSubtitle =>
      'Queste informazioni verranno usate per completare i dettagli del tuo profilo.';

  @override
  String get onboardingFirstNameLabel => 'Nome';

  @override
  String get onboardingLastNameLabel => 'Cognome';

  @override
  String get onboardingFirstNameRequiredError => 'Il nome è obbligatorio.';

  @override
  String get onboardingFirstNameTooShortError =>
      'Il nome deve contenere almeno 2 caratteri.';

  @override
  String get onboardingLastNameRequiredError => 'Il cognome è obbligatorio.';

  @override
  String get onboardingLastNameTooShortError =>
      'Il cognome deve contenere almeno 2 caratteri.';

  @override
  String get onboardingBuyerLocationTitle => 'Da dove acquisti?';

  @override
  String get onboardingBuyerLocationSubtitle =>
      'Seleziona il tuo paese. Se scegli Italia, la regione diventa obbligatoria.';

  @override
  String get onboardingCountryLabel => 'Paese';

  @override
  String get onboardingCountryPlaceholder => 'Seleziona un paese';

  @override
  String get onboardingCountryRequiredError => 'Il paese è obbligatorio.';

  @override
  String get onboardingCountryInvalidError => 'Seleziona un paese valido.';

  @override
  String get onboardingRegionLabel => 'Regione';

  @override
  String get onboardingRegionPlaceholder => 'Seleziona una regione';

  @override
  String get onboardingRegionHint => 'TOSCANA';

  @override
  String get onboardingRegionNotRequiredHint => 'Non richiesta';

  @override
  String get onboardingRegionRequiredError => 'La regione è obbligatoria.';

  @override
  String get onboardingRegionAbruzzo => 'Abruzzo';

  @override
  String get onboardingRegionBasilicata => 'Basilicata';

  @override
  String get onboardingRegionCalabria => 'Calabria';

  @override
  String get onboardingRegionCampania => 'Campania';

  @override
  String get onboardingRegionEmiliaRomagna => 'Emilia-Romagna';

  @override
  String get onboardingRegionFriuliVeneziaGiulia => 'Friuli Venezia Giulia';

  @override
  String get onboardingRegionLazio => 'Lazio';

  @override
  String get onboardingRegionLiguria => 'Liguria';

  @override
  String get onboardingRegionLombardia => 'Lombardia';

  @override
  String get onboardingRegionMarche => 'Marche';

  @override
  String get onboardingRegionMolise => 'Molise';

  @override
  String get onboardingRegionPiemonte => 'Piemonte';

  @override
  String get onboardingRegionPuglia => 'Puglia';

  @override
  String get onboardingRegionSardegna => 'Sardegna';

  @override
  String get onboardingRegionSicilia => 'Sicilia';

  @override
  String get onboardingRegionToscana => 'Toscana';

  @override
  String get onboardingRegionTrentinoAltoAdige => 'Trentino-Alto Adige';

  @override
  String get onboardingRegionUmbria => 'Umbria';

  @override
  String get onboardingRegionValleDaosta => 'Valle d\'Aosta';

  @override
  String get onboardingRegionVeneto => 'Veneto';

  @override
  String get onboardingBuyerLocationRegionHelper =>
      'La regione è richiesta solo per gli acquirenti in Italia.';

  @override
  String get onboardingSellerRegionTitle => 'Seleziona la tua regione';

  @override
  String get onboardingSellerRegionSubtitle =>
      'Al momento, solo i tartufai residenti in Italia possono vendere su Truffly. Proseguendo, dichiari di risiedere in Italia.';

  @override
  String get onboardingSellerDocumentsTitle => 'Carica i documenti seller';

  @override
  String get onboardingSellerDocumentsSubtitle =>
      'Seleziona localmente i documenti richiesti. Durante l\'onboarding non viene caricato nulla fino al submit finale.';

  @override
  String get onboardingTesserinoNumberLabel => 'Numero tesserino';

  @override
  String get onboardingTesserinoNumberHint =>
      'Inserisci il numero del tesserino';

  @override
  String get onboardingTesserinoNumberRequiredError =>
      'Il numero del tesserino è obbligatorio.';

  @override
  String get onboardingIdentityDocumentTitle => 'Documento di identità';

  @override
  String get onboardingIdentityDocumentDescription =>
      'Seleziona un documento di identità valido per la verifica.';

  @override
  String get onboardingIdentityDocumentRequiredError =>
      'Il documento di identità è obbligatorio.';

  @override
  String get onboardingTesserinoDocumentTitle => 'Documento tesserino';

  @override
  String get onboardingTesserinoDocumentDescription =>
      'Seleziona il tuo tesserino o permesso per i tartufi.';

  @override
  String get onboardingTesserinoDocumentRequiredError =>
      'Il documento tesserino è obbligatorio.';

  @override
  String get onboardingDocumentPickButton => 'Seleziona file';

  @override
  String get onboardingDocumentReplaceButton => 'Sostituisci file';

  @override
  String get onboardingDocumentRemoveButton => 'Rimuovi';

  @override
  String get onboardingDocumentTakePhotoOption => 'Scatta foto';

  @override
  String get onboardingDocumentChooseFromGalleryOption =>
      'Scegli dalla galleria';

  @override
  String get onboardingDocumentSourceCancelOption => 'Annulla';

  @override
  String get onboardingDocumentNotSelected => 'Nessun file selezionato';

  @override
  String get onboardingDocumentPermissionDeniedError => 'Permesso negato.';

  @override
  String get onboardingDocumentCameraUnavailableError =>
      'Fotocamera non disponibile.';

  @override
  String get onboardingDocumentGalleryUnavailableError =>
      'Galleria non disponibile.';

  @override
  String get onboardingDocumentPickerUnavailableError =>
      'Impossibile selezionare un\'immagine ora.';

  @override
  String get onboardingSellerDocumentsLocalOnlyHelper =>
      'I file restano locali su questo dispositivo. Il caricamento avviene solo al submit finale.';

  @override
  String get onboardingNotificationsBuyerTitle => 'Attiva le notifiche';

  @override
  String get onboardingNotificationsBuyerSubtitle =>
      'Ricevi aggiornamenti sui tuoi ordini, spedizioni e tartufi preferiti.';

  @override
  String get onboardingNotificationsBuyerBenefit1 =>
      'Conferme ordine e aggiornamenti spedizione.';

  @override
  String get onboardingNotificationsBuyerBenefit2 =>
      'Notifiche su tracking e consegne.';

  @override
  String get onboardingNotificationsBuyerBenefit3 =>
      'Nuovi tartufi in linea con i tuoi interessi.';

  @override
  String get onboardingNotificationsSellerTitle =>
      'Non perdere nessuna vendita';

  @override
  String get onboardingNotificationsSellerSubtitle =>
      'Attiva le notifiche per ricevere aggiornamenti su ordini, spedizioni, pagamenti e attività del tuo account venditore.';

  @override
  String get onboardingNotificationsSellerBenefit1 =>
      'Notifiche immediate per nuovi ordini.';

  @override
  String get onboardingNotificationsSellerBenefit2 =>
      'Promemoria per spedizioni attive.';

  @override
  String get onboardingNotificationsSellerBenefit3 =>
      'Aggiornamenti su pagamenti e accrediti.';

  @override
  String get onboardingNotificationsEnableButton => 'Attiva notifiche';

  @override
  String get onboardingNotificationsContinueWithoutButton => 'Non ora';

  @override
  String get onboardingNotificationsFooter =>
      'Potrai sempre gestire le notifiche più tardi nelle impostazioni.';

  @override
  String get onboardingNotificationsStatusIdle =>
      'Le notifiche non sono ancora abilitate.';

  @override
  String get onboardingNotificationsStatusPending =>
      'Richiesta permesso in corso.';

  @override
  String get onboardingNotificationsStatusGranted =>
      'Notifiche abilitate correttamente.';

  @override
  String get onboardingNotificationsStatusProvisional =>
      'Le notifiche sono abilitate in modalità provvisoria su iOS.';

  @override
  String get onboardingNotificationsStatusNotDetermined =>
      'La scelta delle notifiche non è ancora stata effettuata.';

  @override
  String get onboardingNotificationsStatusDenied =>
      'Permesso negato. Puoi continuare e abilitare le notifiche più tardi dalle impostazioni.';

  @override
  String get onboardingNotificationsStatusSkipped =>
      'Hai scelto di continuare senza notifiche per ora.';

  @override
  String get onboardingNotificationsPermissionError =>
      'Impossibile richiedere il permesso notifiche in questo momento. Puoi continuare e riprovare più tardi.';

  @override
  String get onboardingWelcomeBuyerTitle =>
      'Inizia il tuo viaggio nel mondo del tartufo';

  @override
  String get onboardingWelcomeBuyerSubtitle =>
      'Il tuo onboarding acquirente è completo.';

  @override
  String get onboardingWelcomeBuyerMessage =>
      'Porta sulla tua tavola il sapore autentico del tartufo raccolto con passione dai migliori tartufai.';

  @override
  String get onboardingWelcomeBuyerReadyLabel => 'Sei pronto';

  @override
  String get onboardingWelcomeSellerTitle => 'Richiesta inviata';

  @override
  String get onboardingWelcomeSellerSubtitle =>
      'La tua richiesta seller è in revisione.';

  @override
  String get onboardingWelcomeSellerMessage =>
      'La tua richiesta seller è stata inviata correttamente ed è ora in revisione.\nRiceverai una notifica man mano che lo stato della tua candidatura progredisce.';

  @override
  String get onboardingWelcomeDefaultTitle => 'Benvenuto su Truffly';

  @override
  String get onboardingWelcomeDefaultSubtitle =>
      'Sei quasi pronto a entrare nell\'app.';

  @override
  String get onboardingWelcomeDefaultMessage =>
      'Controlla i dettagli dell\'onboarding e continua quando sei pronto.';

  @override
  String get onboardingBuyerInfo1Title => 'Il vero sapore del tartufo fresco';

  @override
  String get onboardingBuyerInfo1Description =>
      'Scopri il gusto e l\'aroma di tartufi appena raccolti, spediti direttamente dai tartufai.';

  @override
  String get onboardingBuyerInfo2Title =>
      'Tartufai verificati, recensioni reali';

  @override
  String get onboardingBuyerInfo2Description =>
      'Acquista in sicurezza da tartufai verificati e scopri recensioni autentiche lasciate da altri acquirenti.';

  @override
  String get onboardingBuyerInfo3Title => 'Pensiamo noi alla sicurezza';

  @override
  String get onboardingBuyerInfo3Description =>
      'Con Truffly il pagamento rimane protetto fino a quando il tuo ordine non arriva a destinazione.';

  @override
  String get onboardingSellerInfo1Title => 'Dai valore\nai tuoi tartufi';

  @override
  String get onboardingSellerInfo1Description =>
      'Vendi direttamente a una community di appassionati, senza intermediari. Decidi il tuo prezzo e raggiungi acquirenti pronti ad acquistare.';

  @override
  String get onboardingSellerInfo2Title => 'Nessun costo iniziale';

  @override
  String get onboardingSellerInfo2Description =>
      'Nessuna quota di iscrizione e nessun costo anticipato. Tratteniamo una commissione del 10% solo sulle vendite completate.';

  @override
  String get onboardingSellerInfo3Title =>
      'Un marketplace costruito intorno alla freschezza';

  @override
  String get onboardingSellerInfo3Description =>
      'Per preservare qualità e freschezza, gli annunci restano attivi per 5 giorni e gli ordini devono essere spediti entro 2 giorni lavorativi dalla vendita.';

  @override
  String get onboardingSellerInfo4Title => 'Una community verificata';

  @override
  String get onboardingSellerInfo4Description =>
      'Per vendere su Truffly dovrai verificare la tua identità e il tuo tesserino. I pagamenti vengono trasferiti tramite Stripe dopo la conferma di consegna dell\'ordine.';

  @override
  String get onboardingFlowTitleBuyer => 'Onboarding acquirente';

  @override
  String get onboardingFlowTitleSeller => 'Onboarding venditore';

  @override
  String get onboardingFlowTitleDefault => 'Onboarding';

  @override
  String onboardingFlowStepCounter(Object current, Object total) {
    return 'Step $current di $total';
  }

  @override
  String get onboardingFlowSubmissionError =>
      'Si è verificato un errore. Riprova.';

  @override
  String get onboardingSubmitNetworkError =>
      'Connessione di rete assente. Riprova.';

  @override
  String get onboardingSubmitValidationError =>
      'Alcuni dati dell\'onboarding non sono validi. Controlla i dettagli e riprova.';

  @override
  String get onboardingSubmitDocumentError =>
      'Non è stato possibile elaborare un documento selezionato. Controlla i file e riprova.';

  @override
  String get onboardingSubmitServerError =>
      'Server non disponibile in questo momento. Riprova.';

  @override
  String get onboardingSubmitUnavailableError =>
      'Questa azione non è disponibile in questo momento.';

  @override
  String get onboardingFlowBackButton => 'Indietro';

  @override
  String get onboardingFlowNextButton => 'Avanti';

  @override
  String get onboardingFlowEnterAppButton => 'Entra nell\'app';

  @override
  String get onboardingFlowSubmitButton => 'Invia';

  @override
  String onboardingProgressLabel(Object section) {
    return 'Progresso sezione: $section';
  }

  @override
  String get onboardingPlaceholderTitle => 'Step segnaposto';

  @override
  String onboardingPlaceholderStepId(Object stepId) {
    return 'ID step: $stepId';
  }

  @override
  String onboardingPlaceholderSection(Object section) {
    return 'Sezione: $section';
  }

  @override
  String get onboardingSectionAboutTruffly => 'Scopri Truffly';

  @override
  String get onboardingSectionYourDetails => 'I tuoi dati';

  @override
  String get onboardingSectionDocuments => 'Documenti';

  @override
  String get onboardingSectionNotifications => 'Notifiche';

  @override
  String get onboardingSectionWelcome => 'Benvenuto';

  @override
  String get onboardingCountryItaly => 'Italia';

  @override
  String get onboardingCountryFrance => 'Francia';

  @override
  String get onboardingCountryGermany => 'Germania';

  @override
  String get onboardingCountrySpain => 'Spagna';

  @override
  String get onboardingCountryUnitedKingdom => 'Regno Unito';

  @override
  String get onboardingCountryUnitedStates => 'Stati Uniti';

  @override
  String get onboardingRoleSelectionTitle => 'Come vuoi usare Truffly?';

  @override
  String get onboardingRoleSelectionSubtitle =>
      'Acquista tartufi freschi dai migliori tartufai o inizia a vendere i tuoi direttamente alla community.';

  @override
  String get onboardingRoleSelectionBuyerTitle => 'Compra tartufi';

  @override
  String get onboardingRoleSelectionBuyerDescription =>
      'Visualizza il flow onboarding buyer in 7 step.';

  @override
  String get onboardingRoleSelectionSellerTitle => 'Vendi tartufi';

  @override
  String get onboardingRoleSelectionSellerDescription =>
      'Visualizza il flow onboarding seller in 9 step.';

  @override
  String get onboardingExitTitle => 'Vuoi uscire dall\'onboarding?';

  @override
  String get onboardingExitMessage =>
      'I progressi dell\'onboarding resteranno salvati localmente per questa sessione, ma uscirai dal flow.';

  @override
  String get onboardingExitStayButton => 'Resta';

  @override
  String get onboardingExitLeaveButton => 'Esci';

  @override
  String get onboardingDocumentUnsupportedFormatError =>
      'Formato file non supportato. Usa PNG, JPG o JPEG.';

  @override
  String get onboardingDocumentFileNotFoundError =>
      'Impossibile trovare il file selezionato.';

  @override
  String get onboardingDocumentEmptyFileError => 'Il file selezionato è vuoto.';

  @override
  String get trufflePageTitle => 'Tartufi';

  @override
  String get truffleDetailTitle => 'Dettaglio tartufo';

  @override
  String get truffleDetailError => 'Impossibile caricare questo tartufo ora.';

  @override
  String get truffleDetailPricePerKg => 'Prezzo al kg';

  @override
  String get truffleSearchHint => 'Cosa stai cercando?';

  @override
  String get truffleSearchApply => 'Cerca';

  @override
  String get truffleLoadError => 'Impossibile caricare i tartufi. Riprova.';

  @override
  String get truffleRetry => 'Riprova';

  @override
  String get truffleEmptyTitle => 'Nessun prodotto corrispondente';

  @override
  String get truffleEmptySubtitle =>
      'Prova a cambiare filtri\noppure riprova più tardi.';

  @override
  String get truffleFiltersTitle => 'Filtri';

  @override
  String get truffleFiltersReset => 'Reset';

  @override
  String get truffleFiltersApply => 'Applica filtri';

  @override
  String get truffleFilterAll => 'Tutti';

  @override
  String get truffleFilterQuality => 'Qualità';

  @override
  String get truffleFilterPriceRange => 'Fascia prezzo';

  @override
  String get truffleFilterWeight => 'Peso';

  @override
  String get truffleFilterHarvestDate => 'Data di raccolta';

  @override
  String get truffleFilterRegion => 'Regione di raccolta';

  @override
  String get truffleHarvestToday => 'Oggi';

  @override
  String get truffleHarvestLast2Days => 'Ultimi 2 giorni';

  @override
  String get truffleHarvestLast3Days => 'Ultimi 3 giorni';

  @override
  String get truffleHarvestLast5Days => 'Ultimi 5 giorni';

  @override
  String get truffleQualityFirst => 'Prima scelta';

  @override
  String get truffleQualitySecond => 'Seconda scelta';

  @override
  String get truffleQualityThird => 'Terza scelta';

  @override
  String get truffleTypeMagnatum => 'Bianco pregiato';

  @override
  String get truffleTypeMelanosporum => 'Nero pregiato';

  @override
  String get truffleTypeAestivum => 'Scorzone';

  @override
  String get truffleTypeUncinatum => 'Uncinato';

  @override
  String get truffleTypeBorchii => 'Bianchetto';

  @override
  String get truffleTypeBrumale => 'Brumale';

  @override
  String get truffleTypeMacrosporum => 'Nero Liscio';

  @override
  String get truffleTypeBrumaleMoschatum => 'Brumale Moscato';

  @override
  String get truffleTypeMesentericum => 'Ordinario';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeGreetingPrefix => 'Ciao';

  @override
  String get homeLoadError => 'Impossibile caricare la home in questo momento.';

  @override
  String get homeSeasonalSectionTitle => 'In evidenza di stagione';

  @override
  String get homeSeasonalInSeasonLabel => 'Di stagione';

  @override
  String get homeSeasonalComingSoonLabel => 'Coming soon';

  @override
  String get homeSeasonalLoadingLabel => 'Caricamento stagionalità...';

  @override
  String homeSeasonalCountdownLine(int days, Object truffleName) {
    return 'Mancano $days giorni all\'inizio della stagione del $truffleName';
  }

  @override
  String get homeSeasonalEmptyText =>
      'Nessuna stagione disponibile al momento.';

  @override
  String get homeSeasonalErrorText =>
      'Impossibile caricare le informazioni stagionali.';

  @override
  String get homeSeasonalRetryLabel => 'Riprova';

  @override
  String get homeLatestNewsTitle => 'Ultime novità';

  @override
  String get homeTopSellersTitle => 'Tartufai consigliati';

  @override
  String get homeSeeAll => 'Vedi tutti';

  @override
  String get homeLatestNewsEmpty => 'Nessun tartufo disponibile al momento.';

  @override
  String get homeTopSellersEmpty => 'Nessun tartufaio disponibile al momento.';

  @override
  String get homeSectionErrorText => 'Impossibile caricare questa sezione ora.';

  @override
  String get homeSellerOrdersInProgress => 'Ordini in corso';

  @override
  String get homeSellerActiveTruffles => 'Tartufi attivi';

  @override
  String get seasonalTruffleNameMagnatum => 'Tartufo Bianco';

  @override
  String get seasonalTruffleNameMelanosporum => 'Nero Pregiato';

  @override
  String get seasonalTruffleNameAestivum => 'Scorzone';

  @override
  String get seasonalTruffleNameUncinatum => 'Uncinato';

  @override
  String get seasonalTruffleNameBorchii => 'Bianchetto';

  @override
  String get seasonalTruffleNameBrumale => 'Brumale';

  @override
  String get seasonalTruffleNameMacrosporum => 'Tartufo Nero Liscio';

  @override
  String get seasonalTruffleNameBrumaleMoschatum => 'Tartufo Brumale Moscato';

  @override
  String get seasonalTruffleNameMesentericum => 'Ordinario';

  @override
  String get guidesPageTitle => 'Guide ai tartufi';

  @override
  String get guidesLoadError =>
      'Impossibile caricare le guide in questo momento.';

  @override
  String get guidesRetry => 'Riprova';

  @override
  String get guidesEmpty => 'Nessuna guida disponibile al momento.';

  @override
  String get guidesDescription => 'Descrizione';

  @override
  String get guidesAroma => 'Aroma';

  @override
  String get guidesPriceRange => 'Fascia prezzo';

  @override
  String get guidesRarity => 'Rarita';

  @override
  String get guidesSymbioticPlants => 'Piante simbionti';

  @override
  String get guidesSoil => 'Suolo';

  @override
  String get guidesSoilComposition => 'Composizione';

  @override
  String get guidesSoilStructure => 'Struttura';

  @override
  String get guidesSoilPh => 'pH';

  @override
  String get guidesSoilAltitude => 'Altitudine';

  @override
  String get guidesSoilHumidity => 'Umidita';

  @override
  String get guidesSoilHelper =>
      'Scopri le caratteristiche dell\'ambiente in cui cresce questo tartufo: umidita, altitudine e tipologia di suolo.';

  @override
  String get guidesHarvestPeriod => 'Periodo di raccolta';

  @override
  String get guidesTruffleQualityMetric => 'Qualita del tartufo';

  @override
  String get guidesPriceRangeMetric => 'Fascia di prezzo';

  @override
  String get truffleShippingPlus => '+ spedizione';

  @override
  String get truffleShippingItaly => 'Italia';

  @override
  String get sellerPageTitle => 'Venditori';

  @override
  String get sellerSearchHint => 'Cerca per nome o cognome';

  @override
  String get sellerLoadError => 'Impossibile caricare i venditori. Riprova.';

  @override
  String get sellerEmptyTitle => 'Nessun venditore disponibile al momento';

  @override
  String get sellerEmptySubtitle =>
      'Torna più tardi per scoprire nuovi profili verificati.';

  @override
  String get sellerEmptyFilteredTitle =>
      'Nessun venditore corrisponde ai filtri attuali';

  @override
  String get sellerEmptyFilteredSubtitle =>
      'Prova a rimuovere qualche filtro o a cambiare ricerca.';

  @override
  String get sellerResetFilters => 'Resetta filtri';

  @override
  String get sellerFilterRatingTitle => 'Rating';

  @override
  String get sellerFilterCompletedOrdersTitle => 'Ordini completati';

  @override
  String get sellerFilterRatingThreePlus => '3+ stelle';

  @override
  String get sellerFilterRatingFourPlus => '4+ stelle';

  @override
  String get sellerFilterRatingFive => '5 stelle';

  @override
  String get sellerFilterCompletedOrdersFivePlus => '5+ ordini';

  @override
  String get sellerFilterCompletedOrdersTwentyPlus => '20+ ordini';

  @override
  String get sellerFilterCompletedOrdersFiftyPlus => '50+ ordini';

  @override
  String get sellerRatingNew => 'Nuovo';

  @override
  String get sellerRegionUnavailable => 'Regione non disponibile';

  @override
  String sellerActiveSearchFilter(Object query) {
    return 'Ricerca: $query';
  }

  @override
  String sellerReviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recensioni',
      one: '1 recensione',
      zero: 'Nessuna recensione',
    );
    return '$_temp0';
  }

  @override
  String sellerCompletedOrdersShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ordini',
      one: '1 ordine',
      zero: '0 ordini',
    );
    return '$_temp0';
  }

  @override
  String get sellerProfileInfoTab => 'Info';

  @override
  String get sellerProfileReviewsTab => 'Recensioni';

  @override
  String get sellerProfileTrufflesTab => 'Tartufi';

  @override
  String get sellerProfileRatingStarsLabel => 'Valutazione';

  @override
  String get sellerProfileOrdersLabel => 'Ordini';

  @override
  String get sellerProfileActiveTrufflesLabel => 'Tartufi attivi';

  @override
  String get sellerProfileBioFallback =>
      'Questo venditore non ha ancora aggiunto una descrizione.';

  @override
  String get sellerProfileJoinedPlatformLabel => 'Iscritto alla piattaforma';

  @override
  String get sellerProfileSummaryTitle => 'Riepilogo seller';

  @override
  String get sellerProfileJoinedLabel => 'Iscrizione';

  @override
  String get sellerProfileRegionLabel => 'Regione';

  @override
  String get sellerProfileUnavailable => 'Non disponibile';

  @override
  String get sellerProfileRecentReviewsTitle => 'Recensioni recenti';

  @override
  String get sellerProfileReadAll => 'Leggi tutti';

  @override
  String get sellerProfileNoReviews =>
      'Nessuna recensione per questo venditore.';

  @override
  String get sellerProfileActiveTrufflesTitle => 'Tartufi attivi';

  @override
  String get sellerProfileNoActiveTruffles =>
      'Questo venditore non ha tartufi attivi al momento.';

  @override
  String get sellerProfileUnableToLoadReviews =>
      'Impossibile caricare le recensioni al momento.';

  @override
  String get sellerProfileLoadError =>
      'Impossibile caricare questo profilo venditore al momento.';

  @override
  String get accountDetailsTitle => 'Dettagli account';

  @override
  String get accountDetailsSubtitle =>
      'Mantieni aggiornati i dati del tuo account. Se cambi email dovrai completare una nuova verifica.';

  @override
  String get accountDetailsSaveCta => 'Salva modifiche';

  @override
  String get accountDetailsPersonalSectionTitle => 'Dati personali';

  @override
  String get accountDetailsEmailSectionTitle => 'Email';

  @override
  String get accountDetailsLocationSectionTitle => 'Località';

  @override
  String get accountDetailsPhotoSectionTitle => 'Foto profilo';

  @override
  String get accountDetailsBioSectionTitle => 'Bio';

  @override
  String get accountDetailsBioPlaceholder =>
      'Racconta qualcosa in più su di te agli acquirenti';

  @override
  String get accountDetailsEmailVerified => 'Email verificata';

  @override
  String get accountDetailsEmailHelper =>
      'Se cambi email, ti invieremo un nuovo link di verifica e l\'app ti riporterà nella schermata di verifica email.';

  @override
  String get accountDetailsChangeEmailCta => 'Cambia email';

  @override
  String get accountDetailsSaveNewEmailCta => 'Salva nuova email';

  @override
  String get accountDetailsCancelEmailChangeCta => 'Annulla';

  @override
  String get accountDetailsPhotoHelper =>
      'Puoi aggiornare la tua foto profilo da camera o galleria. La nuova immagine viene caricata subito dopo la selezione.';

  @override
  String get accountDetailsPhotoUploadPending => 'Caricamento foto profilo...';

  @override
  String get accountDetailsPhotoUploadSuccess =>
      'Foto profilo aggiornata correttamente.';

  @override
  String get accountDetailsPhotoRemoveSuccess => 'Foto profilo rimossa.';

  @override
  String get accountDetailsPhotoPickerUnavailable =>
      'Impossibile selezionare un\'immagine in questo momento.';

  @override
  String get accountDetailsPhotoPermissionDeniedError =>
      'Permesso negato. Consenti l\'accesso a foto e file e riprova.';

  @override
  String get accountDetailsPhotoCameraUnavailableError =>
      'Fotocamera non disponibile al momento.';

  @override
  String get accountDetailsPhotoGalleryUnavailableError =>
      'Galleria non disponibile al momento.';

  @override
  String get accountDetailsPhotoFileNotFoundError =>
      'Impossibile trovare il file selezionato.';

  @override
  String get accountDetailsPhotoTooLargeError =>
      'L\'immagine selezionata deve essere al massimo di 5 MB.';

  @override
  String get accountDetailsPhotoUnsupportedFormatError =>
      'Usa un\'immagine JPG, PNG o WebP.';

  @override
  String get accountDetailsPhotoInvalidFileError =>
      'Non è stato possibile leggere l\'immagine selezionata.';

  @override
  String get accountDetailsPhotoUploadFailedError =>
      'Impossibile caricare la foto profilo in questo momento. Riprova.';

  @override
  String get accountDetailsPhotoDeleteFailedError =>
      'Impossibile rimuovere la foto profilo in questo momento. Riprova.';

  @override
  String get accountDetailsChangePhotoCta => 'Cambia foto';

  @override
  String get accountDetailsRemovePhotoCta => 'Rimuovi foto';

  @override
  String get accountDetailsTakePhotoOption => 'Scatta foto';

  @override
  String get accountDetailsChooseFromGalleryOption => 'Scegli dalla galleria';

  @override
  String get accountDetailsPhotoSourceCancelOption => 'Annulla';

  @override
  String get accountDetailsSellerCountryLockedHelper =>
      'Secondo le regole di dominio attuali, gli account seller restano collegati all\'Italia.';

  @override
  String get accountDetailsRegionHiddenHelper =>
      'La regione è richiesta solo quando il paese selezionato è Italia. Salvando con un altro paese la regione verrà rimossa.';

  @override
  String get accountDetailsRequiredFieldError => 'Questo campo è obbligatorio.';

  @override
  String get accountDetailsSellerCountryError =>
      'Gli account seller devono mantenere Italia come paese.';

  @override
  String get accountDetailsInvalidImageUrlError =>
      'Inserisci un URL immagine valido.';

  @override
  String get accountDetailsSessionExpired =>
      'La sessione è scaduta. Accedi di nuovo per continuare.';

  @override
  String get accountDetailsLoadError =>
      'Impossibile caricare i dettagli account in questo momento.';

  @override
  String get accountDetailsSaveError =>
      'Impossibile salvare i dettagli account in questo momento. Riprova.';

  @override
  String get accountDetailsSaveSuccess =>
      'Dettagli account aggiornati correttamente.';

  @override
  String get accountDetailsEmailVerificationSent =>
      'Controlla sia l\'indirizzo email attuale sia quello nuovo e conferma entrambi i link per completare il cambio.';

  @override
  String get shippingAddressesTitle => 'Spedizione';

  @override
  String get shippingAddressesSubtitle =>
      'Aggiungi e gestisci gli indirizzi di spedizione per i tuoi ordini.';

  @override
  String get shippingAddressesSectionTitle => 'Indirizzi salvati';

  @override
  String get shippingAddressesAddCta => 'Aggiungi indirizzo';

  @override
  String get shippingAddressesEmptyTitle => 'Nessun indirizzo salvato';

  @override
  String get shippingAddressesEmptySubtitle =>
      'Aggiungi il tuo primo indirizzo di spedizione così sarà pronto da usare durante il checkout.';

  @override
  String get shippingAddressesDefaultBadge => 'Predefinito';

  @override
  String get shippingAddressesLoadError =>
      'Impossibile caricare gli indirizzi di spedizione in questo momento.';

  @override
  String get shippingAddressesNetworkError =>
      'Errore di rete durante il caricamento degli indirizzi di spedizione. Riprova.';

  @override
  String get shippingAddressesUnauthorizedError =>
      'La sessione è scaduta. Accedi di nuovo per gestire gli indirizzi di spedizione.';

  @override
  String get shippingAddressesNotFoundError =>
      'Questo indirizzo di spedizione non è più disponibile.';

  @override
  String get shippingAddressesValidationError =>
      'Alcuni dati dell\'indirizzo non sono validi. Controlla il form e riprova.';

  @override
  String get shippingAddressAddTitle => 'Aggiungi indirizzo';

  @override
  String get shippingAddressEditTitle => 'Modifica indirizzo';

  @override
  String get shippingAddressFormSubtitle =>
      'Usa un indirizzo di spedizione dedicato per le consegne. L\'indirizzo predefinito verrà evidenziato e tenuto pronto per i futuri flow di checkout.';

  @override
  String get shippingAddressSaveCta => 'Salva indirizzo';

  @override
  String get shippingAddressDeleteCta => 'Elimina indirizzo';

  @override
  String get shippingAddressDeleteDialogTitle => 'Eliminare questo indirizzo?';

  @override
  String get shippingAddressDeleteDialogMessage =>
      'Questo indirizzo di spedizione verrà rimosso dall\'elenco salvato.';

  @override
  String get shippingAddressDeleteDialogCancel => 'Annulla';

  @override
  String get shippingAddressDeleteDialogConfirm => 'Elimina';

  @override
  String get shippingAddressFullNameLabel => 'Nome completo';

  @override
  String get shippingAddressFullNamePlaceholder => 'Inserisci nome completo';

  @override
  String get shippingAddressStreetLabel => 'Via';

  @override
  String get shippingAddressStreetPlaceholder => 'Via e numero civico';

  @override
  String get shippingAddressCityLabel => 'Città';

  @override
  String get shippingAddressCityPlaceholder => 'Inserisci città';

  @override
  String get shippingAddressPostalCodeLabel => 'CAP';

  @override
  String get shippingAddressPostalCodePlaceholder => 'Inserisci CAP';

  @override
  String get shippingAddressCountryLabel => 'Paese';

  @override
  String get shippingAddressCountryPlaceholder => 'Seleziona un paese';

  @override
  String get shippingAddressPhoneLabel => 'Telefono';

  @override
  String get shippingAddressPhonePlaceholder => 'Inserisci numero di telefono';

  @override
  String get shippingAddressDefaultToggleLabel =>
      'Imposta come indirizzo predefinito';

  @override
  String get shippingAddressDefaultToggleHelper =>
      'Gli indirizzi predefiniti vengono evidenziati nella lista e restano pronti per la selezione nei futuri checkout.';

  @override
  String get shippingAddressRequiredFieldError =>
      'Questo campo è obbligatorio.';

  @override
  String get shippingAddressFullNameRequiredError =>
      'Il nome completo è obbligatorio.';

  @override
  String get shippingAddressStreetRequiredError => 'La via è obbligatoria.';

  @override
  String get shippingAddressCityRequiredError => 'La città è obbligatoria.';

  @override
  String get shippingAddressCityInvalidError => 'Inserisci una città valida.';

  @override
  String get shippingAddressPostalCodeRequiredError => 'Il CAP è obbligatorio.';

  @override
  String get shippingAddressPostalCodeInvalidError =>
      'Inserisci un CAP valido.';

  @override
  String get shippingAddressCountryRequiredError => 'Il paese è obbligatorio.';

  @override
  String get shippingAddressCountryInvalidError => 'Seleziona un paese valido.';

  @override
  String get shippingAddressPhoneRequiredError => 'Il telefono è obbligatorio.';

  @override
  String get shippingAddressPhoneInvalidError =>
      'Inserisci un numero di telefono valido con prefisso.';

  @override
  String get shippingAddressValidationFallback =>
      'Controlla questo campo e riprova.';

  @override
  String get shippingAddressSaveError =>
      'Impossibile salvare questo indirizzo di spedizione in questo momento. Riprova.';

  @override
  String get shippingAddressSavedSuccess =>
      'Indirizzo di spedizione salvato correttamente.';

  @override
  String get shippingAddressDeletedSuccess =>
      'Indirizzo di spedizione eliminato correttamente.';

  @override
  String get publishTruffleTitle => 'Pubblica tartufo';

  @override
  String get publishTrufflePhotosTitle => 'Foto prodotto';

  @override
  String get publishTrufflePhotosSubtitle =>
      'Aggiungi da 1 a 3 foto. La prima foto verrà usata come vetrina del prodotto.';

  @override
  String get publishTruffleAddPhoto => 'Aggiungi foto';

  @override
  String get publishTruffleRemovePhoto => 'Rimuovi foto';

  @override
  String get publishTruffleQualityLabel => 'Qualità tartufo';

  @override
  String get publishTruffleTypeLabel => 'Tipologia tartufo';

  @override
  String get publishTruffleTypePlaceholder => 'Seleziona tipologia tartufo';

  @override
  String get publishTruffleLatinNameLabel => 'Nome latino';

  @override
  String get publishTrufflePricingTitle => 'Peso e prezzi';

  @override
  String get publishTruffleWeightLabel => 'Peso in grammi';

  @override
  String get publishTruffleTotalPriceLabel => 'Prezzo totale in EUR';

  @override
  String get publishTruffleShippingItalyLabel => 'Prezzo spedizione Italia';

  @override
  String get publishTruffleShippingAbroadLabel => 'Prezzo spedizione estero';

  @override
  String get publishTrufflePricePerKgPreviewLabel => 'Anteprima prezzo al kg';

  @override
  String get publishTrufflePricePerKgPreviewPlaceholder =>
      'Compila peso e prezzo totale';

  @override
  String get publishTruffleRegionLabel => 'Regione di raccolta';

  @override
  String get publishTruffleRegionPlaceholder => 'Seleziona regione di raccolta';

  @override
  String get publishTruffleHarvestDateLabel => 'Data di raccolta';

  @override
  String get publishTruffleCta => 'Pubblica tartufo';

  @override
  String get publishTruffleConfirmTitle => 'Pubblicare questo tartufo?';

  @override
  String get publishTruffleConfirmMessage =>
      'Dopo la pubblicazione, il tartufo sarà visibile nel marketplace e non potrà essere modificato.';

  @override
  String get publishTruffleCancelAction => 'Annulla';

  @override
  String get publishTruffleConfirmAction => 'Pubblica';

  @override
  String get publishTruffleTakePhoto => 'Scatta foto';

  @override
  String get publishTruffleChooseFromGallery => 'Scegli dalla galleria';

  @override
  String get publishTruffleValidationImagesRequired =>
      'Aggiungi almeno 1 foto del prodotto.';

  @override
  String get publishTruffleValidationImagesTooMany =>
      'Puoi caricare al massimo 3 foto del prodotto.';

  @override
  String get publishTruffleValidationQualityRequired =>
      'Seleziona la qualità del tartufo.';

  @override
  String get publishTruffleValidationTypeRequired =>
      'Seleziona la tipologia del tartufo.';

  @override
  String get publishTruffleValidationWeightRequired =>
      'Il peso è obbligatorio.';

  @override
  String get publishTruffleValidationWeightInvalid =>
      'Inserisci un peso maggiore di 0.';

  @override
  String get publishTruffleValidationPriceRequired =>
      'Il prezzo totale è obbligatorio.';

  @override
  String get publishTruffleValidationPriceInvalid =>
      'Inserisci un prezzo totale maggiore di 0.';

  @override
  String get publishTruffleValidationShippingItalyRequired =>
      'Il prezzo spedizione Italia è obbligatorio.';

  @override
  String get publishTruffleValidationShippingItalyInvalid =>
      'Inserisci un prezzo spedizione Italia uguale o maggiore di 0.';

  @override
  String get publishTruffleValidationShippingAbroadRequired =>
      'Il prezzo spedizione estero è obbligatorio.';

  @override
  String get publishTruffleValidationShippingAbroadInvalid =>
      'Inserisci un prezzo spedizione estero uguale o maggiore di 0.';

  @override
  String get publishTruffleValidationRegionRequired =>
      'Seleziona la regione di raccolta.';

  @override
  String get publishTruffleValidationHarvestDateRequired =>
      'La data di raccolta è obbligatoria.';

  @override
  String get publishTruffleValidationHarvestDateFuture =>
      'La data di raccolta non può essere futura.';

  @override
  String get publishTruffleValidationImageFormat =>
      'Formato immagine non supportato. Usa PNG, JPG o JPEG.';

  @override
  String get publishTruffleValidationImageMissing =>
      'Impossibile leggere l\'immagine selezionata.';

  @override
  String get publishTruffleValidationImageTooLarge =>
      'L\'immagine selezionata è ancora troppo grande dopo l\'ottimizzazione.';

  @override
  String get publishTruffleValidationImageProcessingFailed =>
      'Impossibile preparare questa immagine per il caricamento.';

  @override
  String get publishTruffleImagePickerUnavailable =>
      'Impossibile selezionare un\'immagine in questo momento.';

  @override
  String get publishTruffleSubmitUnauthenticated =>
      'La tua sessione è scaduta. Accedi di nuovo prima di pubblicare.';

  @override
  String get publishTruffleSubmitNotAllowed =>
      'Non puoi pubblicare questo tartufo in questo momento.';

  @override
  String get publishTruffleSubmitStripeVerificationPending =>
      'Stripe sta ancora verificando il tuo account. Puoi gestire la verifica da Stripe.';

  @override
  String get publishTruffleSubmitStripeOnboardingRequired =>
      'Completa la registrazione Stripe per pubblicare questo tartufo.';

  @override
  String get publishTruffleSubmitInProgress =>
      'Una richiesta di pubblicazione per questo tartufo è già in corso. Attendi qualche secondo e riprova.';

  @override
  String get publishTruffleSubmitValidation =>
      'Alcuni dati del prodotto non sono validi. Controlla il form e riprova.';

  @override
  String get publishTruffleSubmitInvalidImage =>
      'Una o più immagini selezionate non sono valide. Controllale e riprova.';

  @override
  String get publishTruffleSubmitNetwork =>
      'Errore di rete. Controlla la connessione e riprova.';

  @override
  String get publishTruffleSubmitImageUpload =>
      'Impossibile caricare una o più immagini del prodotto.';

  @override
  String get publishTruffleSubmitUnknown =>
      'Impossibile pubblicare questo tartufo in questo momento. Riprova.';

  @override
  String get publishTruffleAccessError =>
      'Impossibile verificare ora i permessi di pubblicazione. Aggiorna la pagina e riprova.';

  @override
  String get sellerMyTrufflesTitle => 'I miei tartufi';

  @override
  String get sellerMyTrufflesTabPublishing => 'Pubblicazione';

  @override
  String get sellerMyTrufflesTabActive => 'Attivi';

  @override
  String get sellerMyTrufflesTabReserved => 'Riservati';

  @override
  String get sellerMyTrufflesTabSold => 'Venduti';

  @override
  String get sellerMyTrufflesTabExpired => 'Scaduti';

  @override
  String get sellerMyTrufflesStatusPublishing => 'Pubblicazione';

  @override
  String get sellerMyTrufflesStatusReserved => 'Riservato';

  @override
  String get sellerMyTrufflesEmptyPublishingTitle =>
      'Nessun tartufo in pubblicazione';

  @override
  String get sellerMyTrufflesEmptyPublishingSubtitle =>
      'Qui vedrai i tartufi che stanno completando la pubblicazione e non sono ancora visibili ai buyer.';

  @override
  String get sellerMyTrufflesEmptyActiveTitle => 'Nessun tartufo attivo';

  @override
  String get sellerMyTrufflesEmptyActiveSubtitle =>
      'Pubblica un tartufo e lo troverai qui finché sarà disponibile.';

  @override
  String get sellerMyTrufflesEmptyReservedTitle => 'Nessun tartufo riservato';

  @override
  String get sellerMyTrufflesEmptyReservedSubtitle =>
      'I tartufi con un ordine aperto in corso appariranno qui finché la vendita non sarà completata o annullata.';

  @override
  String get sellerMyTrufflesEmptySoldTitle => 'Nessun tartufo venduto';

  @override
  String get sellerMyTrufflesEmptySoldSubtitle =>
      'Le vendite completate appariranno qui quando un tartufo sarà acquistato.';

  @override
  String get sellerMyTrufflesEmptyExpiredTitle => 'Nessun tartufo scaduto';

  @override
  String get sellerMyTrufflesEmptyExpiredSubtitle =>
      'I tartufi scaduti resteranno visibili qui per una consultazione rapida.';

  @override
  String get sellerMyTrufflesLoadError =>
      'Impossibile caricare i tuoi tartufi in questo momento.';

  @override
  String get sellerMyTrufflesRetry => 'Riprova';

  @override
  String get sellerMyTrufflesDeleteTitle => 'Eliminare questo tartufo?';

  @override
  String get sellerMyTrufflesDeleteMessage =>
      'Questa azione è irreversibile. Il tartufo, le sue immagini e i salvataggi collegati verranno rimossi.';

  @override
  String get sellerMyTrufflesDeleteCancel => 'Annulla';

  @override
  String get sellerMyTrufflesDeleteConfirm => 'Elimina';

  @override
  String get sellerMyTrufflesDeleteSuccess => 'Tartufo eliminato con successo.';

  @override
  String get sellerMyTrufflesDeleteForbidden =>
      'Questo tartufo non può più essere eliminato.';

  @override
  String get sellerMyTrufflesDeleteNetwork =>
      'Problema di connessione durante l\'eliminazione del tartufo. Riprova.';

  @override
  String get sellerMyTrufflesDeleteUnauthenticated =>
      'La sessione è scaduta. Accedi di nuovo prima di eliminare un tartufo.';

  @override
  String get sellerMyTrufflesDeleteUnknown =>
      'Impossibile eliminare il tartufo in questo momento.';

  @override
  String get accountLanguageItalian => 'Italiano';

  @override
  String get accountLanguageEnglish => 'English';

  @override
  String get accountSupportTitle => 'Supporto';

  @override
  String get accountSupportIntro =>
      'Trova risposte rapide su acquisti, vendite, pagamenti, spedizioni e account.';

  @override
  String get accountSupportFaqBuyingOrdersSection => 'Acquisti e ordini';

  @override
  String get accountSupportFaqBuyTruffleQuestion =>
      'Come posso acquistare un tartufo?';

  @override
  String get accountSupportFaqBuyTruffleAnswer =>
      'Esplora i tartufi disponibili, apri un annuncio, controlla i dettagli del prodotto, seleziona un indirizzo di spedizione e completa il pagamento in modo sicuro tramite Truffly.';

  @override
  String get accountSupportFaqTrackOrderQuestion =>
      'Come posso tracciare il mio ordine?';

  @override
  String get accountSupportFaqTrackOrderAnswer =>
      'Quando il venditore spedisce l\'ordine e inserisce il codice di tracciamento, questo apparirà nella pagina Dettagli ordine.';

  @override
  String get accountSupportFaqAfterOrderQuestion =>
      'Cosa succede dopo aver effettuato un ordine?';

  @override
  String get accountSupportFaqAfterOrderAnswer =>
      'Dopo il pagamento, il venditore ha fino a 48 ore per spedire i tartufi e fornire le informazioni di tracciamento. Riceverai aggiornamenti nell\'app e, se abilitate, tramite notifiche push.';

  @override
  String get accountSupportFaqSellerDoesNotShipQuestion =>
      'Cosa succede se il venditore non spedisce?';

  @override
  String get accountSupportFaqSellerDoesNotShipAnswer =>
      'Se il venditore non fornisce le informazioni di tracciamento entro il tempo previsto, l\'ordine può essere annullato e rimborsato automaticamente.';

  @override
  String get accountSupportFaqConfirmDeliveryQuestion =>
      'Come posso confermare la consegna?';

  @override
  String get accountSupportFaqConfirmDeliveryAnswer =>
      'Quando ricevi l\'ordine, apri la pagina Dettagli ordine e tocca \"Conferma consegna\". In questo modo confermi che l\'ordine è stato ricevuto correttamente.';

  @override
  String get accountSupportFaqTrufflesQualitySection => 'Tartufi e qualità';

  @override
  String get accountSupportFaqTrufflesFreshQuestion =>
      'I tartufi sono freschi?';

  @override
  String get accountSupportFaqTrufflesFreshAnswer =>
      'Sì. I venditori devono pubblicare tartufi appena raccolti e indicare la data di raccolta in ogni annuncio.';

  @override
  String get accountSupportFaqQualityGradesQuestion =>
      'Cosa indicano le categorie di qualità?';

  @override
  String get accountSupportFaqQualityGradesAnswer =>
      'Le categorie di qualità descrivono l\'aspetto e le condizioni dei tartufi. La Prima qualità comprende generalmente i tartufi più regolari e gradevoli esteticamente, mentre le categorie inferiori possono presentare imperfezioni estetiche pur rimanendo adatte al consumo.';

  @override
  String get accountSupportFaqStoreTrufflesQuestion =>
      'Come devo conservare i tartufi freschi?';

  @override
  String get accountSupportFaqStoreTrufflesAnswer =>
      'Conserva i tartufi freschi in frigorifero, in un contenitore chiuso con carta assorbente. Sostituisci la carta ogni giorno e consumali il prima possibile per apprezzarli al meglio.';

  @override
  String get accountSupportFaqDamagedOrderQuestion =>
      'Cosa devo fare se il mio ordine arriva danneggiato?';

  @override
  String get accountSupportFaqDamagedOrderAnswer =>
      'Contatta l\'assistenza il prima possibile e invia foto del prodotto, dell\'imballaggio e dell\'etichetta di spedizione. Esamineremo la situazione e ti aiuteremo dove possibile.';

  @override
  String get accountSupportFaqShippingDeliverySection =>
      'Spedizione e consegna';

  @override
  String get accountSupportFaqSupportedCountriesQuestion =>
      'Da quali Paesi posso ordinare?';

  @override
  String get accountSupportFaqSupportedCountriesAnswer =>
      'Gli acquirenti che si trovano nei Paesi europei supportati possono effettuare ordini tramite Truffly.';

  @override
  String get accountSupportFaqShippingCostQuestion =>
      'Quanto costa la spedizione?';

  @override
  String get accountSupportFaqShippingCostAnswer =>
      'I costi di spedizione sono stabiliti dal venditore e vengono mostrati prima del checkout.';

  @override
  String get accountSupportFaqTrackingNumberQuestion =>
      'Riceverò un codice di tracciamento?';

  @override
  String get accountSupportFaqTrackingNumberAnswer =>
      'Sì. I venditori devono fornire le informazioni di tracciamento quando spediscono un ordine.';

  @override
  String get accountSupportFaqPackageDelayedQuestion =>
      'Cosa succede se il pacco è in ritardo?';

  @override
  String get accountSupportFaqPackageDelayedAnswer =>
      'I tempi di consegna dipendono dal corriere. Se il pacco sembra in ritardo, controlla prima le informazioni di tracciamento. Se il problema persiste, contatta l\'assistenza.';

  @override
  String get accountSupportFaqPaymentsRefundsSection => 'Pagamenti e rimborsi';

  @override
  String get accountSupportFaqSecurePaymentsQuestion =>
      'I pagamenti sono sicuri?';

  @override
  String get accountSupportFaqSecurePaymentsAnswer =>
      'Sì. I pagamenti vengono elaborati in modo sicuro tramite Stripe. Truffly non conserva i dati completi della tua carta.';

  @override
  String get accountSupportFaqPaymentChargedQuestion =>
      'Quando viene addebitato il pagamento?';

  @override
  String get accountSupportFaqPaymentChargedAnswer =>
      'Il pagamento viene addebitato quando l\'ordine viene effettuato correttamente.';

  @override
  String get accountSupportFaqRefundsWorkQuestion =>
      'Come funzionano i rimborsi?';

  @override
  String get accountSupportFaqRefundsWorkAnswer =>
      'I rimborsi possono essere emessi in conformità con la Politica di rimborso e cancellazione. L\'idoneità al rimborso dipende dallo stato dell\'ordine e dalle circostanze della richiesta.';

  @override
  String get accountSupportFaqRefundTimingQuestion =>
      'Quanto tempo richiede un rimborso?';

  @override
  String get accountSupportFaqRefundTimingAnswer =>
      'I tempi di elaborazione dipendono dalla banca e dal fornitore di pagamento. La maggior parte dei rimborsi viene completata entro pochi giorni lavorativi.';

  @override
  String get accountSupportFaqSellingSection => 'Vendere su Truffly';

  @override
  String get accountSupportFaqBecomeSellerQuestion =>
      'Come posso diventare venditore?';

  @override
  String get accountSupportFaqBecomeSellerAnswer =>
      'Completa la richiesta per diventare venditore, carica i documenti richiesti e attendi l\'approvazione del team Truffly.';

  @override
  String get accountSupportFaqVerifyIdentityQuestion =>
      'Perché devo verificare la mia identità?';

  @override
  String get accountSupportFaqVerifyIdentityAnswer =>
      'La verifica contribuisce a mantenere la piattaforma affidabile e sicura e garantisce che solo i venditori idonei possano pubblicare prodotti.';

  @override
  String get accountSupportFaqSellerApprovalTimingQuestion =>
      'Quanto tempo richiede l\'approvazione come venditore?';

  @override
  String get accountSupportFaqSellerApprovalTimingAnswer =>
      'La maggior parte delle richieste viene esaminata entro pochi giorni lavorativi, anche se i tempi possono variare.';

  @override
  String get accountSupportFaqPublishAfterApprovalQuestion =>
      'Posso pubblicare tartufi subito dopo l\'approvazione?';

  @override
  String get accountSupportFaqPublishAfterApprovalAnswer =>
      'Prima di pubblicare, i venditori approvati devono completare la procedura di onboarding Stripe necessaria per ricevere i pagamenti.';

  @override
  String get accountSupportFaqSellerPaymentsSection => 'Pagamenti ai venditori';

  @override
  String get accountSupportFaqSellerPaymentTimingQuestion =>
      'Quando ricevo il pagamento?';

  @override
  String get accountSupportFaqSellerPaymentTimingAnswer =>
      'I pagamenti vengono rilasciati dopo il completamento dell\'ordine, secondo il processo di pagamento di Truffly.';

  @override
  String get accountSupportFaqStripeAccountQuestion =>
      'Perché ho bisogno di un account Stripe?';

  @override
  String get accountSupportFaqStripeAccountAnswer =>
      'Stripe gestisce in modo sicuro i pagamenti ai venditori e aiuta a verificare le informazioni di pagamento e i requisiti di identità.';

  @override
  String get accountSupportFaqCommissionQuestion =>
      'Qual è la commissione applicata da Truffly?';

  @override
  String get accountSupportFaqCommissionAnswer =>
      'Truffly applica una commissione fissa sulle vendite completate. La commissione attuale viene mostrata durante l\'onboarding del venditore.';

  @override
  String get accountSupportFaqAccountPrivacySection => 'Account e privacy';

  @override
  String get accountSupportFaqDeleteAccountQuestion =>
      'Come posso eliminare il mio account?';

  @override
  String get accountSupportFaqDeleteAccountAnswer =>
      'Puoi richiedere l\'eliminazione dell\'account dalla pagina Impostazioni dell\'app.';

  @override
  String get accountSupportFaqAfterDeleteAccountQuestion =>
      'Cosa succede quando elimino il mio account?';

  @override
  String get accountSupportFaqAfterDeleteAccountAnswer =>
      'I dati personali saranno eliminati o anonimizzati dove possibile. Alcuni dati possono essere conservati quando richiesto dalla legge o per esigenze di sicurezza, contabilità o prevenzione delle frodi.';

  @override
  String get accountSupportFaqProtectDataQuestion =>
      'Come protegge Truffly i miei dati?';

  @override
  String get accountSupportFaqProtectDataAnswer =>
      'Truffly utilizza autenticazione sicura, archiviazione protetta, controlli degli accessi e altre misure tecniche progettate per proteggere le informazioni degli utenti.';

  @override
  String get accountSupportContactTitle => 'Contatta il supporto';

  @override
  String get accountSupportContactBody =>
      'Se hai bisogno di aiuto con un ordine o una consegna, scrivici includendo i dettagli principali.';

  @override
  String get accountSupportContactCta => 'Scrivi al supporto';

  @override
  String get accountSupportEmailLaunchError =>
      'Impossibile aprire il client email in questo momento.';

  @override
  String get accountSettingsTitle => 'Impostazioni';

  @override
  String get accountSettingsIntro =>
      'Gestisci lingua, notifiche e informazioni account da un unico punto.';

  @override
  String get accountSettingsPreferencesSection => 'Preferenze';

  @override
  String get accountSettingsLanguageLabel => 'Lingua';

  @override
  String get accountSettingsNotificationsLabel => 'Notifiche';

  @override
  String get accountSettingsLanguageSheetTitle => 'Scegli una lingua';

  @override
  String get accountSettingsLanguageSheetBody =>
      'Questo aggiorna la lingua usata in tutta l\'app.';

  @override
  String get accountSettingsLegalSection => 'Legale';

  @override
  String get accountSettingsPrivacyPolicyLabel => 'Privacy Policy';

  @override
  String get accountSettingsTermsLabel => 'Termini e Condizioni';

  @override
  String get accountSettingsAccountSection => 'Account';

  @override
  String get accountSettingsDeleteAccountLabel => 'Elimina account';

  @override
  String get accountSettingsDeleteAccountDialogTitle =>
      'Eliminare il tuo account?';

  @override
  String get accountSettingsDeleteAccountDialogBody =>
      'Elimineremo il tuo account se non ci sono ordini o vendite. Se hai storico transazionale, lo disattiveremo e anonimizzeremo i dati non necessari.';

  @override
  String get accountSettingsDeleteAccountDialogCancel => 'Annulla';

  @override
  String get accountSettingsDeleteAccountDialogConfirm => 'Conferma';

  @override
  String get accountSettingsDeleteAccountDeletedMessage =>
      'Il tuo account è stato eliminato. Sei stato disconnesso.';

  @override
  String get accountSettingsDeleteAccountDeactivatedMessage =>
      'Il tuo account è stato disattivato per motivi di conformità. Sei stato disconnesso.';

  @override
  String get accountSettingsDeleteAccountUnauthorizedMessage =>
      'La sessione è scaduta. Accedi di nuovo per eliminare l\'account.';

  @override
  String get accountSettingsDeleteAccountInactiveMessage =>
      'Questo account è già inattivo.';

  @override
  String get accountSettingsDeleteAccountErrorMessage =>
      'Impossibile elaborare la richiesta dell\'account in questo momento. Riprova.';

  @override
  String get notificationsInboxTitle => 'Notifiche';

  @override
  String get notificationsMarkAllRead => 'Segna tutto come letto';

  @override
  String get notificationsUnreadLabel => 'Non letta';

  @override
  String get notificationsReadLabel => 'Letta';

  @override
  String get notificationsEmptyState =>
      'Sei aggiornato. Le nuove notifiche appariranno qui.';

  @override
  String get notificationsErrorState =>
      'Impossibile caricare le notifiche al momento.';

  @override
  String get notificationsRetryButton => 'Riprova';

  @override
  String get notificationGenericTitle => 'Notifica';

  @override
  String get notificationGenericMessage =>
      'Apri il centro notifiche per vedere l\'ultimo aggiornamento.';

  @override
  String get notificationFallbackTruffleName => 'il tuo tartufo';

  @override
  String get notificationFallbackSellerName => 'il venditore';

  @override
  String get notificationFallbackTrackingCode => 'tracking non disponibile';

  @override
  String get notificationFallbackSellerAmount => 'il tuo pagamento';

  @override
  String get notificationOrderConfirmedTitle => 'Ordine confermato';

  @override
  String notificationOrderConfirmedMessage(Object truffleName) {
    return 'Il tuo ordine “$truffleName” è stato confermato. Il venditore ha 48 ore per spedirlo.';
  }

  @override
  String get notificationPaymentFailedTitle => 'Pagamento non riuscito';

  @override
  String notificationPaymentFailedMessage(Object truffleName) {
    return 'Il pagamento per “$truffleName” non è andato a buon fine. Puoi riprovare dal checkout.';
  }

  @override
  String get notificationOrderShippedTitle => 'Ordine spedito';

  @override
  String notificationOrderShippedMessage(Object truffleName) {
    return 'Il tuo ordine “$truffleName” è stato spedito.';
  }

  @override
  String get notificationTrackingAvailableTitle => 'Tracking disponibile';

  @override
  String notificationTrackingAvailableMessage(
    Object truffleName,
    Object trackingCode,
  ) {
    return 'Tracking disponibile per “$truffleName”: $trackingCode.';
  }

  @override
  String get notificationDeliveryConfirmationReminderTitle =>
      'Conferma la consegna';

  @override
  String notificationDeliveryConfirmationReminderMessage(Object truffleName) {
    return 'Hai ricevuto “$truffleName”? Conferma la consegna per completare l’ordine.';
  }

  @override
  String get notificationOrderCompletedTitle => 'Ordine completato';

  @override
  String notificationOrderCompletedMessage(Object truffleName) {
    return 'L’ordine “$truffleName” è stato completato.';
  }

  @override
  String get notificationOrderAutoCompletedTitle =>
      'Ordine completato automaticamente';

  @override
  String notificationOrderAutoCompletedMessage(Object truffleName) {
    return 'L’ordine “$truffleName” è stato completato automaticamente.';
  }

  @override
  String get notificationOrderCancelledBySellerTitle => 'Ordine cancellato';

  @override
  String notificationOrderCancelledBySellerMessage(Object truffleName) {
    return 'L’ordine “$truffleName” è stato cancellato dal venditore. Il rimborso verrà avviato.';
  }

  @override
  String get notificationOrderAutoCancelledUnshippedTitle => 'Ordine annullato';

  @override
  String notificationOrderAutoCancelledUnshippedMessage(Object truffleName) {
    return 'L’ordine “$truffleName” è stato annullato perché non è stato spedito entro 48 ore.';
  }

  @override
  String get notificationRefundStartedTitle => 'Rimborso avviato';

  @override
  String notificationRefundStartedMessage(Object truffleName) {
    return 'Il rimborso per “$truffleName” è stato avviato.';
  }

  @override
  String get notificationRefundCompletedTitle => 'Rimborso completato';

  @override
  String notificationRefundCompletedMessage(Object truffleName) {
    return 'Il rimborso per “$truffleName” è stato completato.';
  }

  @override
  String get notificationReviewRequestTitle => 'Lascia una recensione';

  @override
  String notificationReviewRequestMessage(
    Object sellerName,
    Object truffleName,
  ) {
    return 'Com’è stata la tua esperienza con “$sellerName”? Lascia una recensione per “$truffleName”.';
  }

  @override
  String get notificationReviewAutoCreatedTitle => 'Recensione automatica';

  @override
  String notificationReviewAutoCreatedMessage(Object truffleName) {
    return 'Abbiamo completato automaticamente la recensione per “$truffleName”.';
  }

  @override
  String get notificationFavoriteTruffleUnavailableTitle =>
      'Tartufo non più disponibile';

  @override
  String notificationFavoriteTruffleUnavailableMessage(Object truffleName) {
    return '“$truffleName” non è più disponibile.';
  }

  @override
  String get notificationFavoriteTruffleExpiringTitle => 'Annuncio in scadenza';

  @override
  String notificationFavoriteTruffleExpiringMessage(Object truffleName) {
    return '“$truffleName” è ancora disponibile, ma l’annuncio sta per scadere.';
  }

  @override
  String get notificationSellerApplicationSubmittedTitle => 'Richiesta inviata';

  @override
  String get notificationSellerApplicationSubmittedMessage =>
      'La tua richiesta per vendere su Truffly è stata inviata. Ti avviseremo appena sarà revisionata.';

  @override
  String get notificationSellerApprovedTitle => 'Venditore approvato';

  @override
  String get notificationSellerApprovedMessage =>
      'Sei stato approvato come venditore. Completa Stripe per iniziare a pubblicare tartufi.';

  @override
  String get notificationSellerRejectedTitle => 'Richiesta non approvata';

  @override
  String get notificationSellerRejectedMessage =>
      'La tua richiesta venditore non è stata approvata. Controlla i dettagli o contatta il supporto.';

  @override
  String get notificationStripeOnboardingRequiredTitle =>
      'Configura i pagamenti';

  @override
  String get notificationStripeOnboardingRequiredMessage =>
      'Completa la configurazione dei pagamenti per iniziare a vendere su Truffly.';

  @override
  String get notificationStripeOnboardingCompletedTitle =>
      'Pagamenti configurati';

  @override
  String get notificationStripeOnboardingCompletedMessage =>
      'I pagamenti sono configurati. Ora puoi pubblicare i tuoi tartufi.';

  @override
  String get notificationTrufflePublishedTitle => 'Tartufo pubblicato';

  @override
  String notificationTrufflePublishedMessage(Object truffleName) {
    return '“$truffleName” è stato pubblicato ed è ora visibile agli utenti.';
  }

  @override
  String get notificationTruffleDeletedTitle => 'Tartufo eliminato';

  @override
  String notificationTruffleDeletedMessage(Object truffleName) {
    return '“$truffleName” è stato eliminato.';
  }

  @override
  String get notificationTruffleExpiredTitle => 'Annuncio scaduto';

  @override
  String notificationTruffleExpiredMessage(Object truffleName) {
    return 'L’annuncio “$truffleName” è scaduto e non è più visibile.';
  }

  @override
  String get notificationSellerNewOrderTitle => 'Nuovo ordine ricevuto';

  @override
  String notificationSellerNewOrderMessage(Object truffleName) {
    return 'Hai ricevuto un nuovo ordine per “$truffleName”. Spediscilo entro 48 ore.';
  }

  @override
  String get notificationSellerShipping24hReminderTitle => 'Ricorda di spedire';

  @override
  String notificationSellerShipping24hReminderMessage(Object truffleName) {
    return 'Ricorda di spedire “$truffleName”. Hai ancora 24 ore per inserire il tracking.';
  }

  @override
  String get notificationSellerShippingFinalReminderTitle =>
      'Ultime ore per spedire';

  @override
  String notificationSellerShippingFinalReminderMessage(Object truffleName) {
    return 'Ultime ore per spedire “$truffleName”. Se non inserisci il tracking, l’ordine sarà annullato.';
  }

  @override
  String get notificationSellerOrderCancelledUnshippedTitle =>
      'Ordine annullato';

  @override
  String notificationSellerOrderCancelledUnshippedMessage(Object truffleName) {
    return 'L’ordine “$truffleName” è stato annullato perché non è stato spedito entro 48 ore.';
  }

  @override
  String get notificationSellerOrderMarkedShippedTitle => 'Ordine spedito';

  @override
  String notificationSellerOrderMarkedShippedMessage(Object truffleName) {
    return 'Hai segnato “$truffleName” come spedito. Avviseremo il compratore.';
  }

  @override
  String get notificationSellerDeliveryConfirmedByBuyerTitle =>
      'Consegna confermata';

  @override
  String notificationSellerDeliveryConfirmedByBuyerMessage(Object truffleName) {
    return 'Il compratore ha confermato la consegna di “$truffleName”.';
  }

  @override
  String get notificationSellerOrderAutoCompletedTitle =>
      'Ordine completato automaticamente';

  @override
  String notificationSellerOrderAutoCompletedMessage(Object truffleName) {
    return 'L’ordine “$truffleName” è stato completato automaticamente.';
  }

  @override
  String get notificationSellerPaymentReleasedTitle => 'Pagamento rilasciato';

  @override
  String notificationSellerPaymentReleasedMessage(
    Object truffleName,
    Object sellerAmount,
  ) {
    return 'Il pagamento per “$truffleName” è stato rilasciato. Riceverai $sellerAmount.';
  }

  @override
  String get notificationSellerPaymentProcessingTitle =>
      'Pagamento in elaborazione';

  @override
  String notificationSellerPaymentProcessingMessage(Object truffleName) {
    return 'Il pagamento per “$truffleName” è in elaborazione.';
  }

  @override
  String get notificationSellerPaymentFailedTitle =>
      'Problema con il pagamento';

  @override
  String notificationSellerPaymentFailedMessage(Object truffleName) {
    return 'C’è un problema con il pagamento dell’ordine “$truffleName”. Stiamo verificando.';
  }

  @override
  String get notificationSellerNewReviewTitle => 'Nuova recensione';

  @override
  String notificationSellerNewReviewMessage(Object truffleName) {
    return 'Hai ricevuto una nuova recensione per “$truffleName”.';
  }

  @override
  String get notificationSellerAutoReviewReceivedTitle =>
      'Recensione automatica ricevuta';

  @override
  String notificationSellerAutoReviewReceivedMessage(Object truffleName) {
    return 'È stata aggiunta una recensione automatica per l’ordine “$truffleName”.';
  }

  @override
  String get notificationBuyerWelcomeTitle => 'Benvenuto su Truffly 👋';

  @override
  String get notificationBuyerWelcomeMessage =>
      'Esplora tartufi freschi, scopri nuovi tartufai e porta a casa il sapore autentico del tartufo.';

  @override
  String get notificationProfileUpdatedTitle => 'Profilo aggiornato';

  @override
  String get notificationProfileUpdatedMessage =>
      'Le modifiche al tuo profilo sono state salvate.';

  @override
  String get notificationSecurityNewLoginTitle => 'Nuovo accesso';

  @override
  String get notificationSecurityNewLoginMessage =>
      'È stato effettuato un nuovo accesso al tuo account.';

  @override
  String get notificationTitleGeneric => 'Notifica';

  @override
  String get notificationTitleOrderPlaced => 'Aggiornamento ordine';

  @override
  String get notificationTitleOrderShipped => 'Ordine spedito';

  @override
  String get notificationTitleOrderCompleted => 'Ordine completato';

  @override
  String get notificationTitleOrderCancelled => 'Ordine annullato';

  @override
  String get notificationTitleSellerApplicationSubmitted =>
      'Richiesta venditore';

  @override
  String get notificationTitleSellerApproved => 'Venditore approvato';

  @override
  String get notificationTitleSellerRejected => 'Venditore rifiutato';

  @override
  String get notificationTitlePayoutReleased => 'Payout rilasciato';

  @override
  String get notificationTitleFavoriteTruffleDeleted =>
      'Tartufo salvato non disponibile';

  @override
  String get notificationMessageOrderPlaced =>
      'Il tuo ordine è stato confermato. Il venditore può prepararlo.';

  @override
  String get notificationMessageOrderShipped =>
      'Il venditore ha spedito il tuo ordine.';

  @override
  String get notificationMessageOrderCompleted =>
      'Il tuo ordine è stato completato.';

  @override
  String get notificationMessageOrderCancelled =>
      'Il tuo ordine è stato annullato o rimborsato.';

  @override
  String get notificationMessageOrderAutoCancelledUnshippedBuyer =>
      'Il tuo ordine è stato annullato e rimborsato perché il venditore non lo ha spedito entro 48 ore.';

  @override
  String get notificationMessageOrderAutoCancelledUnshippedSeller =>
      'L\'ordine è stato annullato e rimborsato perché non è stato spedito entro 48 ore.';

  @override
  String get notificationTitleBuyerReviewCreated => 'Nuova recensione';

  @override
  String get notificationMessageBuyerReviewCreated =>
      'Un acquirente ha lasciato una recensione per uno dei tuoi ordini completati.';

  @override
  String get notificationTitleAutoReviewCreated => 'Recensione automatica';

  @override
  String get notificationMessageAutoReviewCreated =>
      'Una recensione automatica è stata creata allo scadere della finestra di recensione.';

  @override
  String get notificationTitleOrderDeliveryConfirmationReminder =>
      'Promemoria consegna';

  @override
  String get notificationMessageOrderDeliveryConfirmationReminder =>
      'Conferma la consegna entro 48 ore oppure l\'ordine verrà completato automaticamente.';

  @override
  String get notificationMessageSellerApplicationSubmitted =>
      'Abbiamo preso in carico la tua richiesta. I documenti sono in revisione.';

  @override
  String get notificationMessageSellerApproved =>
      'La tua richiesta per diventare venditore è stata approvata.';

  @override
  String get notificationMessageSellerRejected =>
      'La tua richiesta per diventare venditore non è stata approvata.';

  @override
  String get notificationMessagePayoutReleased =>
      'Un payout è stato rilasciato.';

  @override
  String get notificationMessageFavoriteTruffleDeleted =>
      'Un tartufo che hai salvato non è più disponibile.';

  @override
  String get reviewSectionTitle => 'Recensisci l\'ordine';

  @override
  String get reviewSectionCopy =>
      'La tua recensione aiuta altri acquirenti a scegliere con più fiducia e valorizza il lavoro del venditore.';

  @override
  String get reviewUnavailableCopy =>
      'La recensione non è più disponibile per questo ordine.';

  @override
  String get reviewLeaveCta => 'Lascia recensione';

  @override
  String get reviewSubmittedLabel => 'Recensione inviata';

  @override
  String get reviewSubmittedSnackBar => 'Grazie, recensione pubblicata.';

  @override
  String get reviewSubmitErrorMessage =>
      'Impossibile inviare la recensione in questo momento.';

  @override
  String get reviewSheetTitle => 'Com\'è stata la tua esperienza?';

  @override
  String get reviewSheetSubtitle =>
      'La tua recensione aiuta altri acquirenti a scegliere con più fiducia e valorizza il lavoro del venditore.';

  @override
  String get reviewRatingLabel => 'Punteggio';

  @override
  String get reviewCommentLabel => 'Commento';

  @override
  String get reviewCommentPlaceholder =>
      'Racconta com\'è andata: freschezza, spedizione, qualità del tartufo…';

  @override
  String get reviewWindowNote =>
      'Hai 48 ore per lasciare una recensione. Dopo verrà lasciata automaticamente una recensione di 5 stelle.';

  @override
  String get reviewSubmitCta => 'Pubblica recensione';

  @override
  String get reviewCancelCta => 'Più tardi';

  @override
  String get reviewRatingRequiredError => 'Scegli un punteggio.';

  @override
  String get reviewAutoLabel => 'Recensione creata automaticamente';

  @override
  String get reviewAutoCommentCompletedSuccess =>
      'Recensione automatica: ordine completato con successo.';

  @override
  String get reviewAutoCommentUnshipped48h =>
      'Recensione automatica: ordine non spedito entro 48 ore.';

  @override
  String get reviewWindowExpiredMessage =>
      'Il tempo per lasciare una recensione è scaduto. Se non hai recensito, verrà registrata la valutazione automatica prevista.';

  @override
  String get reviewAlreadySubmittedMessage =>
      'Hai già lasciato una recensione per questo ordine.';

  @override
  String get accountPrivacyPolicyTitle => 'Privacy Policy';

  @override
  String get accountPrivacyPolicyLeadTitle => 'La tua privacy su Truffly';

  @override
  String get accountPrivacyPolicyLeadBody =>
      'Questa sintesi spiega come Truffly gestisce le informazioni usate per creare l\'account, gestire gli ordini e supportare la tua attivita nell\'app.';

  @override
  String get accountPrivacyPolicySectionDataTitle => 'Quali dati raccogliamo';

  @override
  String get accountPrivacyPolicySectionDataBody =>
      'Possiamo raccogliere dati profilo, informazioni di spedizione, riferimenti ordine e messaggi inviati al supporto per erogare il servizio.';

  @override
  String get accountPrivacyPolicySectionUsageTitle => 'Come li usiamo';

  @override
  String get accountPrivacyPolicySectionUsageBody =>
      'Usiamo queste informazioni per gestire il tuo account, elaborare gli ordini, migliorare l\'esperienza marketplace e comunicare aggiornamenti importanti.';

  @override
  String get accountPrivacyPolicySectionSharingTitle =>
      'Quando i dati possono essere condivisi';

  @override
  String get accountPrivacyPolicySectionSharingBody =>
      'Le informazioni vengono condivise solo quando necessario per completare un ordine, gestire la piattaforma, rispettare obblighi legali o assisterti nelle richieste di supporto.';

  @override
  String get accountPrivacyPolicySectionRightsTitle => 'Le tue scelte';

  @override
  String get accountPrivacyPolicySectionRightsBody =>
      'Puoi rivedere e aggiornare le informazioni account disponibili nell\'app. Nelle prossime versioni aggiungeremo strumenti dedicati per le richieste privacy.';

  @override
  String get accountTermsTitle => 'Termini e Condizioni';

  @override
  String get accountTermsLeadTitle => 'Uso dell\'app Truffly';

  @override
  String get accountTermsLeadBody =>
      'Questi termini riassumono le regole base per esplorare il marketplace, effettuare ordini e interagire con i seller tramite Truffly.';

  @override
  String get accountTermsSectionOrdersTitle => 'Ordini e disponibilita';

  @override
  String get accountTermsSectionOrdersBody =>
      'La disponibilita dei prodotti puo cambiare rapidamente perche i tartufi freschi sono stagionali. La conferma ordine dipende dalla disponibilita e dalla validazione finale del seller.';

  @override
  String get accountTermsSectionShippingTitle => 'Spedizione e consegna';

  @override
  String get accountTermsSectionShippingBody =>
      'Le tempistiche di spedizione possono variare in base alla destinazione, ai requisiti di freschezza e all\'operativita del corriere. Quando possibile condividiamo gli aggiornamenti nel flusso ordine.';

  @override
  String get accountTermsSectionSupportTitle => 'Supporto e problemi';

  @override
  String get accountTermsSectionSupportBody =>
      'Se c\'e un problema con un ordine o con la consegna, contatta rapidamente il supporto cosi il team potra valutare la situazione e indicarti i prossimi passi.';

  @override
  String get accountTermsSectionUpdatesTitle => 'Aggiornamenti futuri';

  @override
  String get accountTermsSectionUpdatesBody =>
      'Questi testi sono una versione MVP e potranno essere aggiornati man mano che Truffly estendera i propri flussi legali e operativi.';

  @override
  String get accountSettingsRefundAndCancellationLabel =>
      'Rimborso e cancellazione';

  @override
  String get accountSettingsLegalInformationLabel => 'Informazioni legali';

  @override
  String get accountRefundAndCancellationTitle => 'Rimborso e cancellazione';

  @override
  String get accountLegalInformationTitle => 'Informazioni legali';

  @override
  String get accountPrivacyPolicyContent =>
      'Ultimo aggiornamento: [Data]\n\nTruffly rispetta la tua privacy e si impegna a proteggere i tuoi dati personali.\n\nLa presente Informativa sulla privacy spiega come Truffly raccoglie, utilizza, conserva, condivide e protegge le informazioni personali quando utilizzi l’app mobile Truffly e i relativi servizi.\n\n1. Titolare del trattamento\n\nIl titolare del trattamento è:\n\n[Titolare legale / Ragione sociale]\nIndirizzo: [Sede legale]\nPaese: Italia\nEmail: [Email privacy]\nEmail assistenza: truffly@gmail.com\n\n2. Cos’è Truffly\n\nTruffly è un marketplace che mette in contatto gli acquirenti con tartufai e venditori italiani verificati.\n\nTruffly fornisce la piattaforma digitale, la gestione degli account, il flusso dei pagamenti, gli strumenti per gli ordini, gli strumenti di verifica dei venditori, le notifiche e le funzionalità di assistenza.\n\nSalvo ove espressamente indicato diversamente, Truffly non vende direttamente i tartufi pubblicati dai venditori.\n\n3. Dati personali che raccogliamo\n\nQuando utilizzi Truffly, potremmo raccogliere i seguenti dati:\n\nDati dell’account\n• nome\n• cognome\n• indirizzo email\n• credenziali della password gestite tramite il nostro fornitore di autenticazione\n• Paese\n• regione, ove applicabile\n• immagine del profilo, se caricata\n• ruolo dell’account, ad esempio acquirente o venditore\n\nDati dell’acquirente\n• indirizzi di spedizione\n• numero di telefono per la consegna\n• cronologia degli ordini\n• prodotti preferiti\n• recensioni inviate\n• richieste di assistenza\n\nDati del venditore\n• informazioni del profilo venditore\n• regione\n• biografia\n• stato della richiesta venditore\n• informazioni sulla licenza o sul permesso per i tartufi\n• documenti di verifica del venditore\n• stato dell’onboarding Stripe Connect\n• prodotti pubblicati\n• cronologia delle vendite\n• recensioni ricevute\n\nDati relativi a ordini e pagamenti\n• prodotto acquistato\n• identificativi del venditore e dell’acquirente\n• importo dell’ordine\n• costo di spedizione\n• importo della commissione\n• stato del pagamento\n• stato del rimborso\n• identificativi delle transazioni Stripe\n• codice di tracciamento\n• stato dell’ordine\n\nTruffly non conserva i numeri completi delle carte né i dati completi delle carte di pagamento. I pagamenti sono elaborati da Stripe.\n\nDati tecnici\n• informazioni sul dispositivo\n• sistema operativo\n• indirizzo IP\n• log dell’app\n• log di sicurezza\n• token delle notifiche push\n• dati della sessione di autenticazione\n\n4. Perché utilizziamo i tuoi dati\n\nTrattiamo i dati personali per:\n• creare e gestire il tuo account\n• consentirti di acquistare e vendere tartufi\n• verificare le richieste dei venditori\n• elaborare pagamenti e rimborsi\n• gestire gli ordini e le informazioni di spedizione\n• inviare notifiche relative agli ordini\n• fornire assistenza clienti\n• prevenire frodi e usi impropri\n• proteggere la piattaforma\n• adempiere agli obblighi di legge\n• gestire la cancellazione dell’account e le richieste relative ai dati\n\n5. Base giuridica del trattamento\n\nTrattiamo i tuoi dati in base alle seguenti basi giuridiche:\n\nEsecuzione del contratto\nPer fornire il servizio Truffly, gestire gli account, elaborare gli ordini e consentire i pagamenti.\n\nObblighi di legge\nPer rispettare le leggi applicabili, gli obblighi contabili, le norme a tutela dei consumatori e le richieste delle autorità competenti.\n\nLegittimo interesse\nPer proteggere la piattaforma, prevenire le frodi, verificare i venditori, conservare i log di controllo e migliorare la sicurezza.\n\nConsenso\nPer le notifiche push e qualsiasi trattamento facoltativo per il quale sia richiesto il consenso.\n\nPuoi revocare in qualsiasi momento il consenso alle notifiche tramite le impostazioni del dispositivo o, ove disponibili, le impostazioni di Truffly.\n\n6. Documenti di verifica del venditore\n\nSe presenti una richiesta per diventare venditore, Truffly può richiedere documenti per verificare la tua identità e la tua idoneità a vendere tartufi.\n\nQuesti documenti sono utilizzati esclusivamente per la verifica e la sicurezza della piattaforma.\n\nOve possibile, i documenti di identità vengono eliminati al termine del processo di verifica, salvo che la loro conservazione sia richiesta dalla legge o necessaria per proteggere Truffly da frodi, controversie o pretese legali.\n\nLe informazioni relative alla licenza o al permesso del venditore possono essere conservate per tutta la durata dell’account venditore e per ogni ulteriore periodo richiesto dalla legge o da legittime esigenze di conformità.\n\n7. Pagamenti\n\nI pagamenti sono elaborati tramite Stripe.\n\nStripe può raccogliere e trattare dati di pagamento, dati di verifica dell’identità, informazioni fiscali, coordinate bancarie e altre informazioni necessarie per fornire i servizi di pagamento.\n\nTruffly può ricevere e conservare identificativi di pagamento, stato dell’ordine, stato del rimborso e stato del pagamento al venditore, ma non conserva i dati completi delle carte di pagamento.\n\n8. Notifiche push\n\nTruffly può inviare notifiche push relative a:\n• conferme degli ordini\n• aggiornamenti sulla spedizione\n• aggiornamenti sui rimborsi\n• approvazione o rifiuto del venditore\n• rilascio dei pagamenti\n• avvisi importanti relativi all’account o alla sicurezza\n\nPuoi disabilitare le notifiche push tramite le impostazioni del dispositivo.\n\nAlcune comunicazioni importanti di servizio potrebbero comunque essere mostrate all’interno dell’app.\n\n9. Con chi condividiamo i dati\n\nPotremmo condividere i dati con:\n• Stripe, per i pagamenti e l’onboarding dei venditori\n• Supabase, per autenticazione, database e archiviazione\n• Firebase Cloud Messaging, per le notifiche push\n• fornitori di hosting, infrastruttura, sicurezza e servizi tecnici\n• autorità competenti, ove richiesto dalla legge\n• acquirenti e venditori, solo quando necessario per completare un ordine\n\nAd esempio, un venditore può ricevere le informazioni di spedizione necessarie per evadere un ordine. Un acquirente può visualizzare le informazioni del profilo venditore, le valutazioni e i dettagli relativi all’ordine.\n\n10. Trasferimenti internazionali\n\nAlcuni fornitori di servizi possono trattare dati al di fuori dello Spazio economico europeo.\n\nIn tali casi, Truffly si avvale di garanzie adeguate, come le Clausole contrattuali standard o altri meccanismi di trasferimento leciti previsti dalle leggi applicabili in materia di protezione dei dati.\n\n11. Conservazione dei dati\n\nConserviamo i dati personali solo per il tempo necessario.\n\nIn linea indicativa:\n• dati dell’account: per tutta la durata dell’account\n• dati degli ordini: per il periodo richiesto dalla legge e dagli obblighi contabili\n• dati di verifica del venditore: per il tempo necessario alla verifica e alla conformità\n• richieste di assistenza: per il tempo necessario a gestire la richiesta e tutelare i diritti legali\n• log di sicurezza: per finalità di sicurezza, prevenzione delle frodi e controllo\n• account eliminati: i dati vengono eliminati o anonimizzati, salvo che la conservazione sia richiesta dalla legge\n\nSe un account ha completato ordini, recensioni, pagamenti, rimborsi o attività di vendita, alcuni dati potrebbero dover essere conservati per adempiere agli obblighi di legge e proteggere i diritti degli utenti e di Truffly.\n\n12. Cancellazione dell’account\n\nPuoi richiedere la cancellazione del tuo account dall’interno dell’app.\n\nQuando elimini il tuo account, Truffly eliminerà o anonimizzerà i dati personali ove possibile.\n\nAlcuni dati possono essere conservati quando necessario per:\n• adempiere agli obblighi di legge\n• conservare le registrazioni contabili\n• gestire controversie\n• prevenire frodi\n• proteggere i diritti di Truffly, degli acquirenti o dei venditori\n\nSe sei un venditore o hai completato transazioni, le registrazioni degli ordini possono essere conservate in forma anonimizzata o limitata.\n\n13. I tuoi diritti\n\nAi sensi delle leggi applicabili in materia di protezione dei dati, potresti avere il diritto di:\n• accedere ai tuoi dati personali\n• correggere i dati inesatti\n• richiedere la cancellazione dei tuoi dati\n• limitare il trattamento\n• opporti al trattamento\n• richiedere la portabilità dei dati\n• revocare il consenso\n• proporre reclamo a un’autorità di protezione dei dati\n\nPer esercitare i tuoi diritti, contattaci all’indirizzo:\n\n[Email privacy]\n\n14. Sicurezza\n\nTruffly utilizza misure tecniche e organizzative progettate per proteggere i dati personali, tra cui controlli degli accessi, sistemi di autenticazione, archiviazione protetta, logica aziendale lato server e log di sicurezza.\n\nNessun sistema digitale può essere garantito come completamente sicuro.\n\n15. Minori\n\nTruffly non è destinato a utenti di età inferiore ai 18 anni.\n\nSe veniamo a conoscenza del fatto che un minore ha creato un account, possiamo eliminare l’account e i dati associati.\n\n16. Modifiche alla presente Informativa sulla privacy\n\nPotremmo aggiornare periodicamente la presente Informativa sulla privacy.\n\nQuando le modifiche sono significative, potremmo informare gli utenti tramite l’app o altri canali appropriati.\n\n17. Contatti\n\nPer richieste relative alla privacy:\n[Email privacy]\n\nPer assistenza generale:\ntruffly@gmail.com';

  @override
  String get accountTermsContent =>
      'Ultimo aggiornamento: [Data]\n\nBenvenuto su Truffly.\n\nI presenti Termini e condizioni disciplinano l’accesso e l’utilizzo dell’app mobile Truffly e dei relativi servizi.\n\nCreando un account o utilizzando Truffly, accetti i presenti Termini.\n\n1. Gestore della piattaforma\n\nTruffly è gestita da:\n\n[Titolare legale / Ragione sociale]\nIndirizzo: [Sede legale]\nPaese: Italia\nEmail assistenza: truffly@gmail.com\n\n2. Cosa fa Truffly\n\nTruffly è un marketplace digitale che consente agli acquirenti di acquistare tartufi freschi da venditori italiani verificati.\n\nTruffly fornisce:\n• la piattaforma mobile\n• la registrazione dell’account\n• gli strumenti di verifica dei venditori\n• gli strumenti per pubblicare i prodotti\n• la gestione degli ordini\n• il flusso di pagamento tramite Stripe\n• le notifiche\n• gli strumenti per le recensioni\n• gli strumenti di assistenza\n\nSalvo ove espressamente indicato diversamente, Truffly non è il venditore diretto dei prodotti pubblicati sulla piattaforma.\n\nIl contratto di vendita del prodotto è concluso tra l’acquirente e il venditore.\n\n3. Requisiti degli utenti\n\nPer utilizzare Truffly devi:\n• avere almeno 18 anni\n• fornire informazioni accurate\n• mantenere al sicuro le credenziali del tuo account\n• utilizzare la piattaforma in modo lecito\n• rispettare i presenti Termini\n\nTruffly può sospendere o chiudere gli account che violano i presenti Termini o la legge applicabile.\n\n4. Account acquirente\n\nGli acquirenti possono:\n• esplorare i tartufi\n• visualizzare i profili dei venditori\n• acquistare i prodotti disponibili\n• gestire gli indirizzi di spedizione\n• tracciare gli ordini\n• confermare la consegna\n• lasciare recensioni\n• contattare l’assistenza\n\nGli acquirenti devono fornire informazioni di spedizione e di contatto accurate.\n\nTruffly non è responsabile delle consegne non riuscite a causa di informazioni errate o incomplete fornite dall’acquirente.\n\n5. Account venditore\n\nSolo i venditori approvati possono pubblicare tartufi su Truffly.\n\nI venditori devono:\n• avere sede in Italia\n• fornire informazioni accurate sulla propria identità e idoneità\n• possedere ogni licenza, permesso, autorizzazione o requisito applicabile alla raccolta e alla vendita dei tartufi\n• pubblicare informazioni veritiere sui prodotti\n• utilizzare immagini reali dei prodotti\n• spedire i prodotti entro i tempi richiesti\n• fornire informazioni di tracciamento valide\n• rispettare le leggi fiscali, alimentari, commerciali e a tutela dei consumatori applicabili alla propria attività\n\nI venditori sono responsabili dei prodotti che pubblicano e vendono.\n\nTruffly può approvare, rifiutare, sospendere o rimuovere l’accesso del venditore quando necessario per proteggere gli utenti, rispettare la legge o preservare l’affidabilità della piattaforma.\n\n6. Inserzioni dei prodotti\n\nOgni inserzione deve contenere informazioni accurate, incluse, ove applicabili:\n• tipologia di tartufo\n• qualità\n• peso\n• prezzo\n• data di raccolta\n• regione\n• costo di spedizione\n• immagini\n\nI venditori non devono pubblicare prodotti ingannevoli, falsi, illegali, non sicuri o non disponibili.\n\nTruffly può rimuovere le inserzioni che violano i presenti Termini o le regole della piattaforma.\n\n7. Freschezza e disponibilità dei prodotti\n\nI tartufi sono prodotti freschi e deperibili.\n\nLa disponibilità può essere limitata e soggetta a variazioni rapide.\n\nUn prodotto può diventare non disponibile se viene venduto, scade, viene rimosso o cancellato secondo le regole della piattaforma.\n\n8. Ordini\n\nQuando un acquirente completa il pagamento, l’ordine viene creato e il venditore deve spedire il prodotto secondo le regole mostrate nell’app.\n\nIl venditore deve inserire le informazioni di tracciamento entro il tempo richiesto.\n\nGli stati dell’ordine possono includere:\n• pagato\n• spedito\n• completato\n• cancellato\n\nTruffly può utilizzare sistemi automatizzati per aggiornare lo stato dell’ordine secondo le regole della piattaforma.\n\n9. Pagamenti\n\nI pagamenti sono elaborati tramite Stripe.\n\nQuando un acquirente acquista un prodotto, il pagamento viene riscosso in modo sicuro e trattenuto secondo il flusso di pagamento della piattaforma.\n\nI pagamenti ai venditori vengono rilasciati secondo le regole di completamento dell’ordine.\n\nTruffly applica una commissione fissa del [10%] sulle transazioni completate, salvo ove diversamente indicato.\n\nLa commissione è calcolata dalla piattaforma.\n\n10. Spedizione\n\nIl venditore è responsabile della corretta preparazione e spedizione del prodotto.\n\nI venditori devono utilizzare imballaggi adatti ai tartufi freschi e rispettare i requisiti applicabili in materia di spedizione e sicurezza alimentare.\n\nTempi e costi di spedizione possono variare in base alla destinazione e alle impostazioni del venditore.\n\nTruffly non è responsabile dei ritardi causati dai corrieri, da indirizzi errati, da cause di forza maggiore o da eventi al di fuori del ragionevole controllo di Truffly.\n\n11. Conferma dell’acquirente e completamento automatico\n\nDopo la spedizione, l’acquirente può confermare la consegna nell’app.\n\nSe l’acquirente non conferma entro il termine mostrato nell’app, l’ordine può essere completato automaticamente dopo il periodo di attesa applicabile.\n\nQuando un ordine è completato, il pagamento al venditore può essere rilasciato secondo il flusso di pagamento.\n\n12. Cancellazioni\n\nGli ordini possono essere cancellati nei casi descritti nella Politica di rimborso e cancellazione.\n\nSe il venditore non spedisce entro il tempo richiesto, l’ordine può essere cancellato e rimborsato automaticamente.\n\nGli acquirenti non possono cancellare liberamente un ordine dopo il pagamento, salvo che ciò sia consentito dalla legge, dalle politiche della piattaforma o a seguito di una valutazione dell’assistenza.\n\n13. Diritto di recesso\n\nI tartufi freschi sono prodotti alimentari deperibili.\n\nPer questo motivo, il diritto di recesso potrebbe non applicarsi agli acquisti di tartufi freschi quando il prodotto è soggetto a deteriorarsi o scadere rapidamente.\n\nCiò non pregiudica eventuali diritti inderogabili dei consumatori che non possono essere esclusi dalla legge.\n\n14. Recensioni\n\nGli acquirenti possono lasciare una recensione per ogni ordine completato.\n\nLe recensioni devono essere oneste, pertinenti e basate su un acquisto reale.\n\nGli utenti non possono pubblicare:\n• recensioni false\n• contenuti offensivi\n• contenuti discriminatori\n• spam\n• dati personali privati\n• minacce\n• contenuti illegali\n\nTruffly può rimuovere le recensioni che violano i presenti Termini o la legge applicabile.\n\nSe l’app prevede recensioni automatiche dopo un determinato periodo, ciò verrà indicato nell’app.\n\n15. Contenuti degli utenti\n\nGli utenti possono caricare o pubblicare contenuti quali informazioni del profilo, immagini dei prodotti, descrizioni e recensioni.\n\nCaricando un contenuto, confermi che:\n• hai il diritto di utilizzarlo\n• è accurato e lecito\n• non viola diritti di terzi\n• non contiene materiale illegale, dannoso o ingannevole\n\nTruffly può rimuovere i contenuti che violano i presenti Termini.\n\n16. Usi vietati\n\nNon devi:\n• creare account falsi\n• impersonare un’altra persona\n• pubblicare informazioni false sui prodotti\n• manipolare le recensioni\n• tentare di aggirare i sistemi di pagamento\n• molestare altri utenti\n• caricare contenuti illegali o dannosi\n• interferire con la sicurezza della piattaforma\n• utilizzare Truffly per frodi o attività illecite\n\n17. Ruolo della piattaforma e limitazione di responsabilità\n\nTruffly opera come piattaforma marketplace e intermediario tecnologico.\n\nI venditori sono responsabili dei prodotti che pubblicano e vendono.\n\nAcquirenti e venditori sono responsabili del rispetto delle leggi applicabili alla propria condotta.\n\nNella misura massima consentita dalla legge, Truffly non è responsabile per:\n• informazioni false fornite dagli utenti\n• problemi di qualità dei prodotti causati dai venditori\n• uso improprio dei prodotti\n• ritardi dei corrieri\n• informazioni di spedizione errate\n• obblighi fiscali dei venditori\n• controversie non causate da una violazione di Truffly\n\nNessuna disposizione dei presenti Termini limita i diritti che non possono essere esclusi ai sensi della normativa applicabile a tutela dei consumatori.\n\n18. Imposte\n\nI venditori sono responsabili della determinazione e dell’adempimento dei propri obblighi fiscali, di fatturazione, contabili e dichiarativi.\n\nTruffly non fornisce consulenza fiscale.\n\nAcquirenti e venditori dovrebbero consultare un professionista qualificato ove necessario.\n\n19. Sospensione o chiusura dell’account\n\nTruffly può sospendere o chiudere un account se:\n• l’utente viola i presenti Termini\n• l’utente fornisce informazioni false\n• si sospettano frodi o abusi\n• è richiesto dalla legge\n• è necessario per proteggere gli utenti o la piattaforma\n\nGli utenti possono eliminare il proprio account dall’interno dell’app, fatti salvi gli obblighi legali di conservazione.\n\n20. Modifiche al servizio\n\nTruffly può aggiornare, modificare, sospendere o interrompere parti della piattaforma.\n\nQuando le modifiche incidono in modo sostanziale sugli utenti, Truffly può fornire un avviso tramite l’app o altri canali appropriati.\n\n21. Legge applicabile\n\nI presenti Termini sono disciplinati dalla legge italiana, fatti salvi i diritti inderogabili a tutela dei consumatori eventualmente applicabili nel Paese di residenza dell’acquirente.\n\n22. Contatti\n\nPer assistenza:\ntruffly@gmail.com\n\nPer richieste legali:\n[Email legale]';

  @override
  String get accountRefundAndCancellationContent =>
      'Ultimo aggiornamento: [Data]\n\nLa presente Politica di rimborso e cancellazione spiega come funzionano su Truffly le cancellazioni, i rimborsi, i termini di spedizione e il rilascio dei pagamenti.\n\n1. Principio generale\n\nTruffly è un marketplace di tartufi freschi venduti da venditori italiani verificati.\n\nI tartufi freschi sono prodotti deperibili. Per questo motivo, rimborsi e cancellazioni sono gestiti in base alla freschezza del prodotto, allo stato della spedizione, agli obblighi del venditore e alle leggi applicabili a tutela dei consumatori.\n\n2. Protezione del pagamento\n\nQuando un acquirente paga un ordine, il pagamento viene elaborato in modo sicuro tramite Stripe.\n\nIl pagamento può essere trattenuto secondo il flusso di pagamento di Truffly fino a quando l’ordine non viene spedito, confermato, completato, cancellato o rimborsato.\n\n3. Termine di spedizione del venditore\n\nI venditori devono spedire il prodotto e fornire le informazioni di tracciamento entro il termine mostrato nell’app.\n\nNel flusso standard di Truffly, i venditori devono spedire entro 48 ore dalla conferma dell’ordine, salvo ove diversamente indicato.\n\n4. Cancellazione automatica se il venditore non spedisce\n\nSe il venditore non fornisce le informazioni di tracciamento entro il termine richiesto, Truffly può cancellare automaticamente l’ordine.\n\nIn questo caso:\n• l’acquirente riceve un rimborso\n• il venditore non riceve il pagamento\n• il prodotto può tornare disponibile, ove applicabile\n\n5. Cancellazione da parte dell’acquirente\n\nPoiché i tartufi freschi sono prodotti deperibili e soggetti a tempi ristretti, in genere gli acquirenti non possono cancellare un ordine dopo il pagamento una volta che il venditore ha iniziato a preparare o spedire il prodotto.\n\nUn acquirente può contattare l’assistenza se:\n• l’ordine è stato effettuato per errore\n• l’indirizzo di spedizione non è corretto\n• il venditore non ha ancora spedito\n• esiste un altro problema grave\n\nTruffly valuterà la richiesta, ma non può garantire la cancellazione in ogni caso.\n\n6. Cancellazione da parte del venditore\n\nUn venditore può cancellare un ordine prima della spedizione solo quando consentito dal flusso dell’app o dall’assistenza Truffly.\n\nI motivi possono includere:\n• prodotto non più idoneo alla vendita\n• problema di qualità del prodotto\n• impossibilità di spedire\n• informazioni errate nell’inserzione\n\nSe il venditore cancella prima della spedizione, l’acquirente riceverà un rimborso.\n\nCancellazioni ripetute da parte del venditore possono comportare la revisione o la sospensione dell’account.\n\n7. Rimborso dopo la spedizione\n\nDopo la spedizione di un ordine, i rimborsi non sono automatici.\n\nUn acquirente può contattare l’assistenza se:\n• il prodotto non è stato consegnato\n• il prodotto è arrivato danneggiato\n• il prodotto è sostanzialmente diverso dall’inserzione\n• esiste un problema grave di freschezza o qualità\n• le informazioni di tracciamento mostrano un problema di consegna\n\nTruffly può chiedere all’acquirente di fornire prove, quali fotografie, informazioni di tracciamento o dettagli dell’ordine.\n\n8. Conferma della consegna\n\nQuando l’acquirente riceve il prodotto, può confermare la consegna nell’app.\n\nUna volta confermata la consegna, l’ordine può essere completato e il pagamento al venditore può essere rilasciato.\n\n9. Completamento automatico\n\nSe l’acquirente non conferma la consegna o non segnala un problema entro il termine mostrato nell’app, l’ordine può essere completato automaticamente.\n\nDopo il completamento automatico, il pagamento al venditore può essere rilasciato.\n\nCiò non elimina i diritti inderogabili previsti dalla legge.\n\n10. Diritto di recesso\n\nI tartufi freschi sono prodotti alimentari deperibili e possono deteriorarsi o scadere rapidamente.\n\nPer questo motivo, il diritto legale di recesso potrebbe non applicarsi agli acquisti di tartufi freschi.\n\nCiò non pregiudica eventuali diritti inderogabili riconosciuti ai consumatori dalla legge applicabile, inclusi i diritti relativi a prodotti difettosi, danneggiati o non conformi.\n\n11. Metodo e tempi del rimborso\n\nOve possibile, i rimborsi vengono elaborati sul metodo di pagamento originale.\n\nI tempi del rimborso possono dipendere da:\n• tempi di elaborazione di Stripe\n• banca o emittente della carta dell’acquirente\n• metodo di pagamento utilizzato\n• controlli antifrode o di conformità\n\nTruffly non può controllare i ritardi causati dalle banche o dai fornitori di pagamento.\n\n12. Costi di spedizione\n\nQuando un ordine viene cancellato prima della spedizione per inadempimento del venditore, i costi di spedizione pagati dall’acquirente possono essere rimborsati.\n\nQuando viene richiesto un rimborso dopo la spedizione, i costi di spedizione possono essere rimborsati o esclusi in base al motivo del rimborso, alla legge applicabile e alla valutazione dell’assistenza.\n\n13. Controversie\n\nIn caso di problemi con un ordine, l’acquirente deve contattare l’assistenza il prima possibile.\n\nEmail assistenza:\ntruffly@gmail.com\n\nL’acquirente deve includere:\n• numero dell’ordine\n• descrizione del problema\n• fotografie, se pertinenti\n• dettagli di tracciamento, se disponibili\n\n14. Abusi\n\nTruffly può rifiutare rimborsi, sospendere account o limitare l’accesso quando sospetta frodi, abusi, dichiarazioni false o un uso improprio ripetuto della procedura di rimborso.\n\n15. Contatti\n\nPer richieste di rimborso e cancellazione:\ntruffly@gmail.com';

  @override
  String get accountLegalInformationContent =>
      'Ultimo aggiornamento: [Data]\n\nQuesta pagina fornisce informazioni legali su Truffly e sul gestore della piattaforma.\n\nGestore della piattaforma\n\nTruffly è gestita da:\n\n[Titolare legale / Ragione sociale]\nIndirizzo: [Sede legale]\nPaese: Italia\nEmail: [Email legale]\nEmail assistenza: truffly@gmail.com\n\nInformazioni fiscali / Partita IVA:\n[Partita IVA / Codice fiscale / Non applicabile / Da aggiungere]\n\nNatura del servizio\n\nTruffly è un marketplace digitale che mette in contatto gli acquirenti con venditori italiani verificati di tartufi freschi.\n\nSalvo ove espressamente indicato diversamente, Truffly non vende direttamente i prodotti pubblicati nell’app.\n\nIl contratto di vendita di ciascun prodotto è concluso tra l’acquirente e il venditore.\n\nResponsabilità del venditore\n\nI venditori sono responsabili per:\n• l’accuratezza delle proprie inserzioni\n• la qualità e le condizioni dei prodotti venduti\n• il rispetto delle leggi applicabili in materia di raccolta, alimenti, fiscalità, commercio e tutela dei consumatori\n• il corretto imballaggio e la corretta spedizione del prodotto\n• la fornitura di informazioni di tracciamento valide\n\nResponsabilità dell’acquirente\n\nGli acquirenti sono responsabili per:\n• la fornitura di informazioni accurate sull’account\n• la fornitura di un indirizzo di spedizione corretto\n• il controllo dei dettagli dell’ordine prima del pagamento\n• la tempestiva segnalazione di problemi relativi alla consegna o al prodotto\n• l’utilizzo lecito della piattaforma\n\nPagamenti\n\nI pagamenti sono elaborati in modo sicuro tramite Stripe.\n\nTruffly può applicare una commissione della piattaforma alle transazioni completate.\n\nI pagamenti ai venditori, i rimborsi e il rilascio dei pagamenti sono gestiti secondo il flusso di pagamento e le politiche della piattaforma applicabili.\n\nInformazioni per i consumatori\n\nPrima di completare un acquisto, agli acquirenti vengono mostrate le principali informazioni sull’ordine, tra cui i dettagli del prodotto, il prezzo, il costo di spedizione, le informazioni sul venditore ove disponibili e l’importo totale.\n\nI tartufi freschi sono prodotti alimentari deperibili. Il diritto di recesso potrebbe non applicarsi quando i prodotti sono soggetti a deteriorarsi o scadere rapidamente.\n\nCancellazione dell’account e richieste sui dati\n\nGli utenti possono richiedere la cancellazione dell’account dall’interno dell’app.\n\nAlcuni dati possono essere conservati quando richiesto dalla legge o quando necessario per sicurezza, contabilità, prevenzione delle frodi, controversie o pretese legali.\n\nLe richieste relative alla privacy possono essere inviate a:\n[Email privacy]\n\nAssistenza\n\nPer assistenza generale:\ntruffly@gmail.com\n\nNote legali\n\nTutti i marchi, loghi, design dell’app, testi, immagini e materiali della piattaforma sono di proprietà di Truffly o utilizzati con autorizzazione, salvo ove diversamente indicato.\n\nGli utenti non possono copiare, riprodurre, distribuire o utilizzare impropriamente i contenuti di Truffly senza autorizzazione.\n\nLegge applicabile\n\nLa piattaforma è gestita dall’Italia.\n\nLe presenti note legali sono disciplinate dalla legge italiana, fatti salvi i diritti inderogabili a tutela dei consumatori eventualmente applicabili nel Paese di residenza dell’utente.';
}
