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
  String get authVerifyEmailRecheckButton => 'Ho verificato la mia email';

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
      'Email di verifica inviata nuovamente.';

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
      'Se l\'email esiste, è stato inviato un link di reset.';

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
  String get authWelcomeTitleLeading => 'Compra e vendi';

  @override
  String get authWelcomeTitleAccent => 'tartufi premium';

  @override
  String get authWelcomeSubtitle =>
      'Entra in un marketplace affidabile costruito su\nqualità, trasparenza e recensioni reali.';

  @override
  String get authWelcomeCreateAccountButton => 'Crea account';

  @override
  String get authWelcomeGoogleButton => 'Continua con Google';

  @override
  String get authWelcomeLoginButton => 'Ho già un account';

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
      'Nel flow seller il paese è considerato Italia, quindi qui è richiesta solo la regione.';

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
  String get onboardingNotificationsTitle =>
      'Resta aggiornato con le notifiche';

  @override
  String get onboardingNotificationsSubtitle =>
      'Le notifiche ti aiutano a seguire i momenti più importanti della tua esperienza su Truffly.';

  @override
  String get onboardingNotificationsBenefitOrderUpdates =>
      'Aggiornamenti sugli ordini dall\'acquisto alla conclusione.';

  @override
  String get onboardingNotificationsBenefitShippingUpdates =>
      'Aggiornamenti su spedizione e consegna per gli ordini attivi.';

  @override
  String get onboardingNotificationsBenefitSellerApproval =>
      'Aggiornamenti sull\'approvazione seller se richiedi di vendere su Truffly.';

  @override
  String get onboardingNotificationsBenefitPayments =>
      'Aggiornamenti relativi a pagamenti e payout quando rilevanti.';

  @override
  String get onboardingNotificationsEnableButton => 'Abilita notifiche';

  @override
  String get onboardingNotificationsContinueWithoutButton =>
      'Continua senza notifiche';

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
  String get onboardingNotificationsStatusDenied =>
      'Permesso negato. Puoi continuare e abilitare le notifiche più tardi dalle impostazioni.';

  @override
  String get onboardingNotificationsStatusSkipped =>
      'Hai scelto di continuare senza notifiche per ora.';

  @override
  String get onboardingNotificationsPermissionError =>
      'Impossibile richiedere il permesso notifiche in questo momento. Puoi continuare e riprovare più tardi.';

  @override
  String get onboardingWelcomeBuyerTitle => 'Benvenuto su Truffly';

  @override
  String get onboardingWelcomeBuyerSubtitle =>
      'Il tuo onboarding acquirente è completo.';

  @override
  String get onboardingWelcomeBuyerMessage =>
      'Ora puoi iniziare a scoprire tartufi premium, seller verificati e acquisti protetti direttamente nell\'app.';

  @override
  String get onboardingWelcomeSellerTitle => 'Il tuo profilo Truffly è pronto';

  @override
  String get onboardingWelcomeSellerSubtitle =>
      'Sei pronto a completare l\'onboarding seller.';

  @override
  String get onboardingWelcomeSellerMessage =>
      'Entra nell\'app per continuare con il tuo account. La revisione seller resta separata dall\'approvazione finale e ti aggiorneremo man mano che procede.';

  @override
  String get onboardingWelcomeDefaultTitle => 'Benvenuto su Truffly';

  @override
  String get onboardingWelcomeDefaultSubtitle =>
      'Sei quasi pronto a entrare nell\'app.';

  @override
  String get onboardingWelcomeDefaultMessage =>
      'Controlla i dettagli dell\'onboarding e continua quando sei pronto.';

  @override
  String get onboardingBuyerInfo1Title =>
      'Tartufi freschi, selezionati per qualità';

  @override
  String get onboardingBuyerInfo1Description =>
      'Truffly è pensata per chi vuole accedere a tartufi premium con un\'esperienza mobile semplice, focalizzata su freschezza, provenienza e qualità del prodotto.';

  @override
  String get onboardingBuyerInfo2Title => 'Acquisti sicuri con logica escrow';

  @override
  String get onboardingBuyerInfo2Description =>
      'I pagamenti seguono un flusso d\'ordine protetto. Truffly mantiene l\'esperienza di acquisto chiara e sicura mentre l\'ordine passa da pagamento a spedizione fino al completamento.';

  @override
  String get onboardingBuyerInfo3Title =>
      'Seller verificati e segnali di fiducia';

  @override
  String get onboardingBuyerInfo3Description =>
      'Gli acquirenti possono esplorare un marketplace costruito attorno a seller verificati, profili trasparenti, recensioni e un livello di fiducia più forte in tutta la community.';

  @override
  String get onboardingSellerInfo1Title =>
      'Vendi i tuoi tartufi a un mercato mirato';

  @override
  String get onboardingSellerInfo1Description =>
      'Truffly aiuta i cavatori di tartufi a raggiungere gli acquirenti tramite un marketplace mobile dedicato, progettato attorno a qualità, fiducia e gestione chiara degli ordini.';

  @override
  String get onboardingSellerInfo2Title => 'Un modello commissionale chiaro';

  @override
  String get onboardingSellerInfo2Description =>
      'Truffly applica una commissione del 10% sulle vendite completate. L\'obiettivo è mantenere l\'economia del seller semplice e prevedibile fin dall\'inizio.';

  @override
  String get onboardingSellerInfo3Title => 'La tempistica di spedizione conta';

  @override
  String get onboardingSellerInfo3Description =>
      'Gli ordini seguono aspettative di tempo rigorose. I seller devono spedire rapidamente e il flow MVP attuale è costruito attorno a una regola di spedizione entro 48 ore.';

  @override
  String get onboardingSellerInfo4Title =>
      'Aspettative su approvazione, escrow e payout';

  @override
  String get onboardingSellerInfo4Description =>
      'L\'onboarding seller include step di revisione e approvazione. Pagamenti e payout seguono un flusso strutturato e la configurazione collegata a Stripe avviene solo dopo l\'approvazione.';

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
  String get onboardingRoleSelectionTitle => 'Come vuoi usare Truffly';

  @override
  String get onboardingRoleSelectionSubtitle =>
      'Scegli come vuoi iniziare.\nPotrai sempre cambiare questa scelta più avanti.';

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
  String get truffleSearchHint => 'Cerca per nome o nome latino';

  @override
  String get truffleSearchApply => 'Cerca';

  @override
  String get truffleLoadError => 'Impossibile caricare i tartufi. Riprova.';

  @override
  String get truffleRetry => 'Riprova';

  @override
  String get truffleEmptyTitle =>
      'Nessun prodotto corrisponde alla tua ricerca';

  @override
  String get truffleEmptySubtitle =>
      'Prova a cambiare filtri oppure riprova più tardi.';

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
  String get truffleTypeMacrosporum => 'Tartufo Nero Liscio';

  @override
  String get truffleTypeBrumaleMoschatum => 'Tartufo Brumale Moscato';

  @override
  String get truffleTypeMesentericum => 'Tartufo Mesenterico';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeGreetingPrefix => 'Ciao';

  @override
  String get homeLoadError => 'Impossibile caricare la home in questo momento.';

  @override
  String get homeSeasonalSectionTitle => 'In evidenza di stagione';

  @override
  String get homeSeasonalInSeasonLabel => 'In season';

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
  String get seasonalTruffleNameMesentericum => 'Tartufo Mesenterico';

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
      'Puoi aggiornare l\'avatar del seller da camera o galleria. Se rimuovi la foto esistente, il profilo tornerà alle iniziali.';

  @override
  String get accountDetailsPhotoPendingHelper =>
      'Hai selezionato una nuova foto in locale. Il collegamento all\'upload definitivo verrà aggiunto nel prossimo step senza sporcare il modello dati attuale.';

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
  String get accountDetailsPhotoUploadPending =>
      'La nuova foto è pronta in anteprima locale. Completiamo l\'upload definitivo nel prossimo step tecnico.';

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
      'Ti abbiamo inviato un link di verifica al nuovo indirizzo email. Verifica l\'email per continuare.';

  @override
  String get shippingAddressesTitle => 'Indirizzi di spedizione';

  @override
  String get shippingAddressesSubtitle =>
      'Scegli quale indirizzo tenere pronto per il checkout e aggiornalo quando cambiano i dettagli di consegna.';

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
      'Aggiungi da 1 a 3 foto. La prima foto verrà usata come cover del prodotto.';

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
      'Solo i seller approvati con onboarding Stripe completato possono pubblicare tartufi.';

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
      'Trova risposte rapide su ordini, spedizioni e assistenza alla consegna.';

  @override
  String get accountSupportFaqSection => 'FAQ';

  @override
  String get accountSupportFaqOrderFlowQuestion =>
      'Come funziona un ordine su Truffly?';

  @override
  String get accountSupportFaqOrderFlowAnswer =>
      'Scegli il tartufo, conferma l\'ordine e ti aggiorneremo fino alla consegna.';

  @override
  String get accountSupportFaqShippingTimingQuestion =>
      'Quando viene spedito il tartufo?';

  @override
  String get accountSupportFaqShippingTimingAnswer =>
      'I tartufi freschi vengono preparati e spediti il prima possibile dopo la conferma dell\'ordine.';

  @override
  String get accountSupportFaqOrderTrackingQuestion =>
      'Come posso seguire lo stato del mio ordine?';

  @override
  String get accountSupportFaqOrderTrackingAnswer =>
      'Puoi controllare l\'ultimo aggiornamento dalla sezione I miei ordini del tuo account.';

  @override
  String get accountSupportFaqCancellationQuestion =>
      'Posso annullare un ordine?';

  @override
  String get accountSupportFaqCancellationAnswer =>
      'Se hai bisogno di annullare un ordine, contatta il supporto il prima possibile e valuteremo la richiesta.';

  @override
  String get accountSupportFaqDeliveryIssueQuestion =>
      'Cosa succede se c\'è un problema con la consegna?';

  @override
  String get accountSupportFaqDeliveryIssueAnswer =>
      'Scrivi al supporto con i dettagli dell\'ordine e ti aiuteremo a risolvere il problema rapidamente.';

  @override
  String get accountSupportFaqContactQuestion =>
      'Come posso contattare l\'assistenza?';

  @override
  String get accountSupportFaqContactAnswer =>
      'Usa l\'email qui sotto per contattare direttamente il team Truffly.';

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
      'Questa azione non è ancora disponibile dall\'app. Conferma solo se vuoi proseguire non appena il flusso sarà pronto.';

  @override
  String get accountSettingsDeleteAccountDialogCancel => 'Annulla';

  @override
  String get accountSettingsDeleteAccountDialogConfirm => 'Conferma';

  @override
  String get accountSettingsDeleteAccountPendingMessage =>
      'La cancellazione account non è ancora disponibile in-app. Contatta il supporto se hai bisogno di aiuto immediato.';

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
}
