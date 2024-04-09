# Benutzerkonten für DPV

Liebe Mitglieder des Deutschen Parkour Verbandes,

ich freue mich, euch eine kurze Einführung in die Nutzung unseres neuen Nextcloud-Servers und E-Mail-Dienstes zu geben.

## Nextcloud [share.parkour-deutschland.de](https://share.parkour-deutschland.de/)

1. **Anmeldung bei Nextcloud:**

    - Jeder Benutzer erhält in Kürze einen eigenen Benutzernamen und ein Passwort, um sich beim Nextcloud-Server unter **[share.parkour-deutschland.de](https://share.parkour-deutschland.de/)** anzumelden.
    - **Passwort ändern:** Benutzer können ihr Nextcloud-Passwort direkt über Nextcloud ändern.

2. **Verwendung von Nextcloud auf verschiedenen Plattformen:**

    - **Nextcloud-App:** Benutzer können die Nextcloud-App auf ihren Mobilgeräten installieren, um einfach auf ihre Dateien zuzugreifen und sie zu bearbeiten.
    - **WebDAV:** Für Windows, Linux, MacOS und ähnliche Systeme können Benutzer WebDAV verwenden, um Dateien über den Datei-Explorer hochzuladen und herunterzuladen.

3. **Nextcloud für die Teamdateifreigabe nutzen:**

    - **Dateien hochladen und teilen:** Mit Nextcloud können Sie Dateien hochladen und sie mit anderen Benutzern teilen. Klicken Sie auf die Schaltfläche “Hochladen” und wählen Sie die Datei aus, die Sie teilen möchten. Anschließend können Sie den Link zur Freigabe an andere senden.
    - **Freigegebene Ordner:** Jeder Benutzer ist automatisch Mitglied der Gruppe “Initiative”. In dieser Gruppe können Sie gemeinsam genutzte Ordner sehen. Wenn Sie eine Datei in einem freigegebenen Ordner ablegen, können andere Benutzer darauf zugreifen.
    - **Zusammenarbeit in Echtzeit:** Auch Termine, Aufgaben und Kontakte können in der Gruppe geteilt und gemeinsam verwaltet werden.

## Email-Postfach [mail.8bj.de](https://mail.8bj.de/)

1. **Kontodetails für E-Mails:**

    - Jeder Benutzer erhält eine eigene **E-Mail-Adresse** im Format **benutzername@parkour-deutschland.de**. Diese Adresse wird für den Zugriff auf den E-Mail-Server verwendet.
    - Das Passwort für den E-Mail-Server können Benutzer unter [https://8bj.de/mail/](https://8bj.de/mail/) ändern. Klicken Sie auf “Passwort ändern” und folgen Sie den Anweisungen.

2. **Zugriff auf E-Mails:**

    - Benutzer können ihre E-Mails über verschiedene Protokolle abrufen:
      - **POP3 (SSL, verschlüsselt, Port 995):** Zum Herunterladen von E-Mails auf Ihr Gerät.
      - **IMAP (SSL, verschlüsselt, Port 993):** Zum Anzeigen und Verwalten von E-Mails auf dem Server.
      - **SMTP (ebenfalls verschlüsselt, Port 465):** Zum Senden von E-Mails.
    - Stellen Sie sicher, dass Sie Ihre **vollständige E-Mail-Adresse** als Benutzernamen verwenden und **[8bj.de](https://8bj.de/)** als den Mailserver-Hostname auswählen.
    - Beachten Sie bitte folgende **Einschränkungen,** wenn Sie **POP3** verwenden:
      - Die Emails werden auf dem Gerät lokal gespeichert und werden dann nicht mehr auf andere Geräte synchronisiert.
      - Es gibt keinen Zugriff auf den Team-Posteingang (siehe unten)
      - Diese Einschränkungen gelten auch, wenn Sie **Google Mail** verwenden.

3. **Webmail über Snappymail:**

    - Wenn Sie Ihre E-Mails über einen Webmailer abrufen möchten, besuchen Sie [https://mail.8bj.de/](https://mail.8bj.de/) und melden Sie sich mit Ihrer vollständigen E-Mail-Adresse und Ihrem Passwort an. Der Snappymail-Webmailer ist bereits fertig für Sie eingerichtet und verbindet sich automatisch über IMAP und SMTP mit Ihrem Email-Konto.

4. **Team-Posteingang im IMAP-Ordner:**

    - Der Team-Posteingang ist ein spezieller Ordner, der alle eingehenden E-Mails sammelt, die an **info** gesendet werden. Jeder Benutzer kann auch E-Mails im Namen von **info** senden. Wenn Sie auf eine E-Mail antworten möchten, wird empfohlen, die **Reply-To:**-Adresse standardmäßig auf **info** zu setzen und diese E-Mail zusätzlich in **bcc:** zu setzen, damit andere Teammitglieder die Antworten sehen können. Natürlich gefolgt vom At-Zeichen und parkour-deutschland.de hinterher.
    - Falls dies nicht geschieht, können Benutzer ihre Antworten aus dem **Gesendet**:-Ordner zurück in den Teamordner verschieben.

5. **Einrichtung verschiedener Mailclients:**

    - **Outlook:**
      - Starten Sie Outlook und wählen Sie **Datei > Konto hinzufügen**.
      - Geben Sie Ihre **E-Mail-Adresse** ein (z.B. **benutzername@parkour-deutschland.de**).
      - Wählen Sie **Manuelle Konfiguration oder zusätzliche Servertypen** und klicken Sie auf **Weiter**.
      - Wählen Sie **IMAP** und geben Sie die Serverdetails ein:
        - **Server**: **8bj.de**
        - **Port**: **993** (SSL verschlüsselt)
        - **Benutzername**: Ihre vollständige E-Mail-Adresse
      - Klicken Sie auf **Weiter**, geben Sie Ihr **Passwort** ein und klicken Sie auf **Fertig stellen**.
      - Sollten SMTP-Einstellungen angepasst werden, folgen Sie den Schritten in Punkt 2 (ich freue mich auf Feedback!)
    - **Thunderbird:**
      - Klicken Sie auf **Datei > Neu > Bestehendes E-Mail-Konto**.
      - Geben Sie Ihren **Namen**, Ihre **E-Mail-Adresse** und Ihr **Passwort** ein.
      - Klicken Sie auf **Manuell konfigurieren** und wählen Sie **IMAP**.
      - Geben Sie die Serverdetails ein:
        - **Server**: **8bj.de**
        - **Port**: **993** (SSL verschlüsselt)
        - **Benutzername**: Ihre vollständige E-Mail-Adresse
      - Klicken Sie auf **Fertig stellen**.
      - Sollten SMTP-Einstellungen angepasst werden, folgen Sie den Schritten in Punkt 2 (ich freue mich auf Feedback!)
    - **Google Mail**:
      - Melden Sie sich in Ihrem Google-Mail-Konto an.
      - Gehen Sie zu den Einstellungen und wählen Sie **Konten und Import**.
      - Klicken Sie auf **E-Mail von anderen Konten importieren**.
      - Geben Sie Ihre **E-Mail-Adresse** und Ihr **Passwort** ein.
      - Wählen Sie als Server-Typ **POP3** und die Servereinstellungen:
        - **Server**: **8bj.de**
        - **Port**: **995** (SSL verschlüsselt)
        - **Benutzername**: Ihre vollständige E-Mail-Adresse
      - Klicken Sie auf **Konto hinzufügen**.
      - Um E-Mails zu versenden, müssen auch die SMTP-Einstellungen hinterlegt werden, dazu folgen Sie den Schritten in Punkt 2 (ich freue mich auf Feedback!)
      - Um wie in Punkt 4 im Namen einer anderen E-Mail-Adresse Mails zu verschicken, geben Sie diese im ersten Schritt als E-Mail-Adresse ein, im späteren Verlauf aber Ihre persönlich zugeteilte E-Mail-Adresse.
    - **GMX, Web.de, mailbox.org**:
      - Melden Sie sich in Ihrem Webmail-Konto an.
      - Gehen Sie zu den Einstellungen und suchen Sie den Bereich **E-Mail-Konten**.
      - Klicken Sie auf **weiteres E-Mail-Konto hinzufügen**.
      - Folgen Sie den restlichen Schritten wie bei **Google Mail**

Falls weiterhin Fragen bestehen, ist die IT-Abteilung immer für Sie da!
