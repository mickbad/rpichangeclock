# rpichangeclock

Change Clock on system

## Getting Started

Projet à destination des Linux/Raspberry Pi qui ont un problème de réglage d'heure avant la connexion à internet.

En effet sur certaines instances, la connexion wifi se fait par un réseau public et des authentifications en https ont lieu.
Si la machine n'est pas à l'heure, la certification SSL peut ne pas être correcte et empêcher sa connexion définitive.

Ce mini logiciel permet à l'utilisateur d'établir lui même la date et l'heure de la mini-machine et ainsi procéder à la connexion sur une borne publique.

L'option ``Temporary stop NTP Service`` permet d'interrompre le service raspios de synchronisation du temps avec un serveur distant. 
Logiquement s'il n'y a pas de connexion, il n'a pas lieu d'éteindre le service qui est en timeout lors de son exécution normale.

*Une compilation pour RaspberryPi/arm64 est présent dans /distribution du projet*
