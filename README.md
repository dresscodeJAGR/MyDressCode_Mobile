# MyDressCode_Mobile
Repository de l'application mobile

## Installation de flutter

👉🏼 Télécharger le fichier ZIP de flutter ( dernière version à l’heure de la documentation )
https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.3.9-stable.zip

👉🏼 Se rendre sur le dossier où vous voulez mettre Flutter dans le terminal à l’aide du cd Puis dé-ziper le fichier dans ce dossier
💻 unzip ~/Downloads/flutter_macos_arm64_3.3.9-stable.zip

👉🏼 Puis l’ajouter au PATH
💻 export PATH="$PATH:pwd/flutter/bin”

👉🏼 Après ces étapes, tester si Flutter à bien été installé dans le cmd :
💻 flutter doctor
Si vous obtenez “zsh: command not found: flutter” il faut continuer
Sinon tant mieux vous avez Flutter

👉🏼 Exécuter la commande suivante
💻 vim $HOME/.zshrc

Cliquer sur i afin de rentrer dans le mode insert et copier coller l’export suivant
💻 export PATH=$PATH:/~/flutter/bin
Afin de quitter le .zshrc cliquer appuyer sur echap ( esc ) et écrire la commande suivante
et appuyer sur Enter
💻 :wq!

Normalement flutter s’est installé
💻 flutter
