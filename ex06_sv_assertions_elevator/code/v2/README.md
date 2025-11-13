Formal Verification : Elevator FSM
==================================

This folder contains formal verification of an elevator FSM.
To run the example with QuestaFormal, go into the
comp folder. Then run the following command:

qverify -do ../scripts/check.do

## Cahier des charge
### Fonctionnement
Nous souhaitons vérifier la correction d’une machine à états finis modélisant le comportement d’un ascenseur.
Son entité est la suivante :
```vhdl
entity elevator_fsm is
port(
    clk_i     : in  std_logic;
    rst_i     : in  std_logic;

    call0_i   : in  std_logic;
    call1_i   : in  std_logic;

    open_o    : out std_logic;
    floor0_o  : out std_logic;
    floor1_o  : out std_logic
);
end elevator_fsm;
```
call0_i, call1_i
- Deux entrées permettent d’appeler l’ascenseur depuis l’étage 0 et l’étage 1.

L’appel n’est effectif que si l’ascenseur a sa porte fermée et est en attente à un étage.

Appeler l’ascenseur depuis l’étage où il se trouve ouvre simplement la porte.
La porte reste ouverte tant que le bouton de l’étage est pressé.

Lorsque l’ascenseur se déplace vers un autre étage, il passe par un état où il est en train d’arriver à l’étage correspondant. À ce moment-là, les sorties des deux étages sont à ‘0’, car l’ascenseur n’est pas réellement sur un étage.

La réinitialisation asynchrone place l’ascenseur à l’étage 0, porte fermée.

Les signaux de sortie obéissent aux règles suivantes :

door_o vaut ‘1’ dans les états F0OPEN et F1OPEN, sinon ‘0’.

floor0_o vaut ‘1’ dans les états F0CLOSE et F0OPEN, sinon ‘0’.

floor1_o vaut ‘1’ dans les états F1CLOSE et F1OPEN, sinon ‘0’.

### Code PSL
Ajoutez du code dans le fichier .psl afin de vérifier le comportement correct de la FSM.
Commencez par le faire en utilisant uniquement les ports d’entrée/sortie.
Ensuite, comme vous avez accès à l’architecture (et donc aux états internes du système), ajoutez des assertions vérifiant les transitions de la FSM.

Un paramètre générique ERRNO permet d’injecter des erreurs dans le design.
Son comportement est le suivant :

Lorsque ERRNO = 0, le résultat est valide.

Lorsque ERRNO est dans l’intervalle [1,6], le résultat est invalide.

Ce paramètre générique permet de tester vos assertions en essayant différentes valeurs de ERRNO.
Vous pouvez modifier sa valeur dans le fichier check.do.

Utilisez le code du dossier v1.

### Deuxième version 
Afin de rendre notre FSM d’ascenseur plus réaliste, nous avons modifié son comportement pour que la porte reste ouverte pendant 10 cycles d’horloge.
Ainsi, lorsque la porte s’ouvre, elle reste ouverte pendant 10 cycles.
Si le bouton de l’étage courant est pressé pendant que la porte est ouverte, alors la porte reste ouverte pendant 10 cycles à partir du moment où le bouton est pressé.

Le code correspondant se trouve dans le dossier v2.
Vous pouvez commencer par copier-coller vos assertions précédentes, certaines restant valides, puis modifier celles qui doivent l’être.

Un paramètre générique ERRNO permet toujours d’injecter des erreurs dans le design :
1. Lorsque ERRNO = 0, le résultat est valide.
2. Lorsque ERRNO est dans l’intervalle [1,6], le résultat est invalide.
