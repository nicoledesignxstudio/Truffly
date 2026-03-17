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
  String get truffleQualitySecond => 'Seconda';

  @override
  String get truffleQualityThird => 'Terza';

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
  String get truffleShippingPlus => '+ spedizione';

  @override
  String get truffleShippingItaly => 'Italia';

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
}
