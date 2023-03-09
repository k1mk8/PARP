/* Letho, królobójca, by KSP. */

:- dynamic obecna_lokalizacja/1, posiadasz/1, finished/1, przedmioty_lokalizacje/2, potwory_lokalizacje/3, ostrzezenie/1, pomoc/1.
:- discontiguous(dostepne_lokacje/2).

%%%%%% Connections Graph %%%%%
% starting point
obecna_lokalizacja(ogrody).

/* Brzeg rzeki */
dostepne_lokacje(brzeg_rzeki, kanaly).
dostepne_lokacje(brzeg_rzeki, szopa).
dostepne_lokacje(brzeg_rzeki, lodka).
:- assertz(ostrzezenie(0)).

/* Łódka */
dostepne_lokacje(lodka, brzeg_rzeki).

/* Szopa */
dostepne_lokacje(szopa, brzeg_rzeki).
dostepne_lokacje(szopa, skrzynia).
dostepne_lokacje(szopa, stol_rzemieslniczy).

/* Skrzynia */
dostepne_lokacje(skrzynia, szopa).
:- assertz(przedmioty_lokalizacje(klucz, skrzynia)).

/* Stół rzemieślniczy */
dostepne_lokacje(stol_rzemieslniczy, szopa).
:- assertz(przedmioty_lokalizacje(obcegi, stol_rzemieslniczy)).
:- assertz(przedmioty_lokalizacje(lom, stol_rzemieslniczy)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AKT 1
/* Kanały */

dostepne_lokacje(kanaly, drzwi_prowadzace_na_przedmiescia).
:- assertz(potwory_lokalizacje(kanaly, utopiec, 4, mozg_utopca)).
dostepne_lokacje(kanaly, miejsce_mocy).
:- assertz(potwory_lokalizacje(miejsce_mocy, baba_wodna, 6, aard)).
dostepne_lokacje(miejsce_mocy, kanaly).
dostepne_lokacje(drzwi_prowadzace_na_przedmiescia, kanaly).


/* Przedmieścia */
dostepne_lokacje(przedmiescia, handlarz).
dostepne_lokacje(przedmiescia, dom_handlarza).
dostepne_lokacje(przedmiescia, ogrody).
dostepne_lokacje(przedmiescia, zamek). %death or back

/* Handlarz */
dostepne_lokacje(handlarz, przedmiescia).
:- assertz(handlarz(0)).


/* Dom Handlarza */
dostepne_lokacje(dom_handlarza, przedmiescia).

/* Ogrody */
dostepne_lokacje(ogrody, rabatka).
dostepne_lokacje(ogrody, ognisko).
dostepne_lokacje(rabatka, ogrody).
dostepne_lokacje(ognisko, ogrody).
:- assertz(przedmioty_lokalizacje(jaskolcze_ziele, rabatka)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AKT2
/* Zamek */
dostepne_lokacje(zamek, balkon).
dostepne_lokacje(zamek, pokoj_dzieci).
dostepne_lokacje(zamek, salon).
dostepne_lokacje(zamek, korytarz).
dostepne_lokacje(zamek, straznica).
% powroty
dostepne_lokacje(balkon, zamek).
dostepne_lokacje(pokoj_dzieci, zamek).
dostepne_lokacje(salon, zamek).
dostepne_lokacje(korytarz, zamek).
dostepne_lokacje(straznica, zamek).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% Locations descriptions %%%%%
/* These rules describe the various rooms.
 * Depending on circumstances, a room may have more than one description. */

/* Akt 0 Prolog */
opis(brzeg_rzeki)                              :- write('Stoisz na brzegu rzeki przy łódce którą przypłynąłeś, w oddali widzisz zejście do kanałów oraz starą szopę nieopodal.'), nl.
opis(lodka)                                    :- 
        ostrzezenie(0) ->                             retract(ostrzezenie(0)), assertz(ostrzezenie(1)), write('Jesteś w łódce, którą przypłynąłeś do doków Remisu. Nie ma czasu do stracenia, zaraz będą tu ludzie Foltesta otaczający oblegane miasto.'), nl, !;
        ostrzezenie(1) ->                             retract(ostrzezenie(1)), assertz(ostrzezenie(2)), write('Żołnierze króla nadchodzą! Brzeg zaraz zostanie odcięty!'), nl, !;
        ostrzezenie(2) ->                             write('Podbiega do Ciebie grupa żołnierzy Foltesta. Wyciągasz miecz i próbujesz się bronić, jednak strzały kuszników były zdecydowanie zbyt szybkie...'), nl, porazka, !.
opis(szopa)                                    :- 
        ostrzezenie(0) ->                             retract(ostrzezenie(0)), assertz(ostrzezenie(1)), write('Poczułeś zapach zatęchłego, dawno zapomnianego warsztatu. Twoim oczom ukazuje się stara drewniana skrzynia oraz stół rzemieślniczy z zardzewiałymi narzędziami.'), nl, !;
        ostrzezenie(1) ->                             retract(ostrzezenie(1)), assertz(ostrzezenie(2)), write('Żołnierze króla nadchodzą! Brzeg zaraz zostanie odcięty!'), nl, !;
        ostrzezenie(2) ->                             write('Słyszysz jak armia Foltesta wybiega nad rzekę. Znaleźli Twoją łódź, a teraz zmierzają w stronę szopy. Czekasz aż podejdą i rzucasz się na nich.\n Kilkunastu żołnierzy zginęło z Twoich rąk, ale odniosłeś poważne rany. Kolejne oddziały przybyły, by zakończyć Twój żywot...'), nl, porazka, !.
opis(kanaly)                                   :- 
        write('Stoisz po pas w ściekach Remisu. Słyszysz jak grupa utopców biegnie w Twoją stronę, co robisz?!'), 
        nl.
opis(skrzynia)                                 :- write('Przeczesując rozmaite rupiecie w skrzyni zauważasz coś ciekawego... To klucz, być może przy odrobinie szczęścia uda Ci się znaleźć pasujący do niego zamek!'), nl.
opis(stol_rzemieslniczy)                       :- write('Na stole leżą wielkie zardzewiałe obcęgi oraz łom, mający swoje najlepsze lata już dawno za sobą.'), nl.
/* Akt 1 Kanały */
opis(drzwi_prowadzace_na_przedmiescia)         :- write('Stoją przed Tobą wrota prowadzące na przedmieścia Remisu. Próbujesz je otworzyć, ale potężne metalowe zawiasy trzymają je w ryzach. Może spróbuj czegoś innego...'), nl.
opis(miejsce_mocy)                             :- write('Twój medalion drży. Już miałeś zaczerpnąć energii z miejsca mocy, gdy z odmętów wodnych nieopodal wynurzyła się ociekająca szlamem baba wodna.'), nl.
/* Akt 2 Miasto */
opis(przedmiescia)                             :- write('Przed Twoimi oczami rysują się pełne gwaru i chaosu przedmieścia Remisu. Biegający w popłochu mieszkańcy próbują dostać się do twierdzy zamku poszukując schronienia.\nW tej chmarze ploretariatu udaje Ci się dostrzec wyróżniające się ogniwo. Jest to kupiec próbujący przedrzeć się przez drzwi domu.\nCiężko będzie odnaleźć w tym zamieszaniu Foltesta, przydałoby się jakoś przeniknąć niepostrzeżenie do twierdzy i za wczasu przygotować się do zasadzki.\nW oddali zauważasz również ogrody księżnej.'), nl.
opis(handlarz)                                 :- 
        handlarz(0) -> retract(handlarz(0)), assertz(handlarz(1)), write('Pomocy wiedźminie! W moim domu uwięziona jest córka! Szafa zablokowała drzwi od środka po uderzeniu głazu w dom sąsiada, który cisnięty został przez katapulty Foltesta.\nNa tyłach domu jest jeszcze jedno wejście, pijani maruderzy próbują się dostać do mojej Hanusi. Pośpiesz się prędko!'), nl, !;
        handlarz(1), not(posiadasz(hanusia)) -> retract(handlarz(1)), assertz(handlarz(3)),assertz(potwory_lokalizacje(handlarz, handlarz, 1, biala_mewa)), write('Wiedźminie! Dlaczego pozwoliłeś mojej Hanusi zginąć?!.'), nl, potwory_w_poblizu(handlarz), !;
        handlarz(2), not(posiadasz(hanusia)) -> retract(handlarz(2)), assertz(handlarz(3)),assertz(potwory_lokalizacje(handlarz, handlarz, 1, biala_mewa)), retract(przedmioty_lokalizacje(hanusia, dom_handlarza)), write('Wiedźminie! Dlaczego pozwoliłeś mojej Hanusi zginąć?!.'), nl, potwory_w_poblizu(handlarz), !;
        handlarz(2), posiadasz(hanusia) -> retract(handlarz(2)), assertz(handlarz(3)), assertz(przedmioty_lokalizacje(biala_mewa, handlarz)),write('Wiedźminie! Dzięki Ci po stokroć! Proszę, słyszałem, że to bezcenny alkohol do warzenia eliksirów. Może Ci się przyda.'), nl, assertz(pomoc(1)), !;
        write('Nic Tu po Tobie! Lepiej się pośpiesz!'), nl.

opis(dom_handlarza)                            :-
        handlarz(1) -> write('Drzwi do domu są otwarte na ościerz, a ze środka dobiegają krzyki młodej dziewczyny. Jeśli chcesz coś zrobić lepiej zrób to teraz!'), nl, assertz(potwory_lokalizacje(dom_handlarza, maruderzy, 5, hanusia)),retract(handlarz(1)), assertz(handlarz(2)), !;
        write('Nic Tu po Tobie! Lepiej się pośpiesz!'), nl.
opis(ogrody)                                   :- write('Woń kwiatów pozwala Ci zapomnieć na chwilę, że miasto znajduje się pod szturmem armi Foltesta. Jedna z kwiatowych rabat pobudza Twój medalion do drgania.\nO ścianę zamku rozbił się płonący pocisk katapult, z odłamków możnaby utworzyć ognisko. A w samej ścianie dostrzegasz szczelinę, którą z pewnością mógłbyś się przecisnąć.'), nl.
opis(ognisko)                                  :- write('Płomień tańczy wysoko ogrzewając okolicę. Gdyby był tu Vesemir na pewno przypomniałby Ci nie jeden wykład z alchemii.\nMożnaby spróbować wytworzyć jakąś mikstruę, która ułatwiłaby Ci przedostanie się za mury zamku.'), nl.
opis(rabatka)                                  :- write('Między ozdobnymi kwiatami dostrzegasz kilka Jaskółczych Ziel.'), nl.
/* Akt 3 Zamek */
opis(zamek)                                    :- write('XD.'), nl.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/* These rules describe how to pick up an object. */

wez(X) :-
        obecna_lokalizacja(Place),
        przedmioty_lokalizacje(X, Place),
        not(posiadasz(X)),
        assertz(posiadasz(X)),
        retract(przedmioty_lokalizacje(X, Place)),
        write('Chowasz '),
        write(X),
        write(' do ekwipunku.'),
        !, nl.

        %write('Handlarz w ramach wdzięczności za pomoc jego córce wręcza Ci wyśmienity alkohol - Białą Mewę.'),
        %write('Chowasz Jaskółcze Ziele do ekwipunku.'),


wez(_) :-
        write('Nie ma tu już nic do nic do podniesienia.'),
        nl.

uzyj(klucz) :-
        obecna_lokalizacja(drzwi_prowadzace_na_przedmiescia),
        posiadasz(klucz),
        write('Włożyłeś klucz do zamka i z nadzieją spróbowałeś przekręcić go w dziurce. Ku twojemu zaskoczeniu pasował jak ulał!'),
        nl,
        write('Wielkie wrota stanęły przed Tobą otworem, wybiegasz na przedmieścia, czując oddech zbliżających się żołnierzy Foltesta na plecach.'),
        nl,
        zostaw(klucz),
        !,
        idz(przedmiescia).

uzyj(lom) :-
        obecna_lokalizacja(drzwi_prowadzace_na_przedmiescia),
        posiadasz(lom),
        write('Wsunąłeś zardzewiały łom między dzwi, a futrynę. Z całych sił próbujesz pokonać nieugiętego przeciewnika.'),
        nl,
        write('Niestety łom pęka, a Ty wpadasz po szyję w ściekowy szlam. Ledwie zdąrzyłeś się w pełni wynużyć na brzeg, a kolejne utopce przyszły złożyć Ci wizytę...'),
        nl,
        zostaw(lom),
        !,
        idz(kanaly).

uzyj(klucz) :-
        obecna_lokalizacja(drzwi_prowadzace_na_przedmiescia),
        posiadasz(klucz),
        write('Włożyłeś klucz do zamka i z nadzieją spróbowałeś przekręcić go w dziurce. Ku twojemu zaskoczeniu pasował jak ulał!'),
        nl,
        write('Wielkie wrota stanęły przed Tobą otworem, wybiegasz na przedmieścia, czując oddech zbliżających się żołnierzy Foltesta na plecach.'),
        nl,
        zostaw(klucz),
        retract(obecna_lokalizacja(drzwi_prowadzace_na_przedmiescia)),
        assertz(obecna_lokalizacja(przedmiescia)),
        rozejrzyj_sie,
        !.

uzyj(aard) :-
        obecna_lokalizacja(drzwi_prowadzace_na_przedmiescia),
        posiadasz(aard),
        write('Zebrałeś w sobie wewnętrzną siłę i przy użyciu wiedźmińskiego znaku Aard udało Ci się roztrzaskać drzwi na strzępy!'),
        nl,
        write('Wybiegasz na przedmieścia, obtrzepujesz się z pozostałych jeszcze drzazg i kurzu, czując oddech zbliżających się żołnierzy Foltesta na plecach.'),
        nl,
        zostaw(aard),
        retract(obecna_lokalizacja(drzwi_prowadzace_na_przedmiescia)),
        assertz(obecna_lokalizacja(przedmiescia)),
        rozejrzyj_sie,
        !.

uzyj(dekokt_raffarda_bialego) :-
        obecna_lokalizacja(ogrody),
        posiadasz(dekokt_raffarda_bialego),
        write('Wypijasz Dekokt Raffarda Bialego i natychmiast przemieniasz się w piękną opiekunkę dzieci Foltesta. Niepostrzeżenie przechodzisz przez otwór w ścianie i przedostajesz się do zamku.'),
        nl,
        zostaw(dekokt_raffarda_bialego),
        retract(obecna_lokalizacja(ogrody)),
        assertz(obecna_lokalizacja(zamek)),
        rozejrzyj_sie,
        !.

uzyj(_) :-
        write('Nie masz pomysłu jak użyć tutaj tego przedmiotu.'),
        nl.

uzyj(biala_mewa, jaskolcze_ziele, mozg_utopca) :-
        obecna_lokalizacja(ognisko),
        posiadasz(biala_mewa),
        posiadasz(jaskolcze_ziele),
        posiadasz(mozg_utopca),
        write('Nareszcie udało Ci się przypomnieć sobie odpowiednią kombinację składników! Eliksir jest już gotowy!'),
        nl,
        assertz(przedmioty_lokalizacje(dekokt_raffarda_bialego, ognisko)),
        wez(dekokt_raffarda_bialego),
        nl,
        zostaw(biala_mewa),
        zostaw(jaskolcze_ziele),
        zostaw(mozg_utopca),
        !.

uzyj(_, _, _) :-
        write('Nie, to nie tak...'),
        nl.

/* These rules describe how to put down an object. */
zostaw(X) :-
        obecna_lokalizacja(Place),
        posiadasz(X),
        retract(posiadasz(X)),
        assertz(przedmioty_lokalizacje(X, Place)),
        write('Upuszczono: '),
        write(X),
        write('.'),
        nl,
        !.

zostaw(_) :-
        write('Nie masz tego przy sobie!'),
        nl.

/* write where you can go from current place. */
destynacje(Place) :-
        write("Dostępne lokacje z "), write(Place), write(":"), nl,
        dostepne_lokacje(Place, X), write(X), nl, fail.
destynacje(_).

/* This rule tells how to move in a given direction. */
idz(_) :-
        obecna_lokalizacja(Here),
        potwory_lokalizacje(Here, _, _, _),
        write('No chyba cie pojebalo.'),
        !.

idz(Place) :-
        obecna_lokalizacja(Here),
        dostepne_lokacje(Here, Place),
        retract(obecna_lokalizacja(Here)),
        assertz(obecna_lokalizacja(Place)),
        !, rozejrzyj_sie.

idz(_) :-
        write('Nie możesz tam pójść z tego miejsca.'),
        fail.

/* This rule lists out what you are posiadasz. */
trzymasz :-
        write('Trzymasz:'), nl,
        trzymasz.

trzymasz_lista :-
        posiadasz(X),
        write('-'), write(X), nl,
        fail.
trzymasz_lista.
/* This rule tells how to look about you. */

rozejrzyj_sie :-
        nl,
        obecna_lokalizacja(Place),
        opis(Place),
        nl,
        destynacje(Place),
        nl,
        przedmioty_w_poblizu(Place),
        potwory_w_poblizu(Place),
        nl.


/* These rules set up a loop to mention all the objects
   in your vicinity. */

przedmioty_w_poblizu(Place) :-
        przedmioty_lokalizacje(X, Place),
        write('Jest tutaj: '), write(X), write('.'), nl, fail.

przedmioty_w_poblizu(_).

potwory_w_poblizu(Place) :-
        potwory_lokalizacje(Place, X, _, _),
        write('Twoim przeciwnikiem jest: '), write(X), write('.'), nl, fail.

potwory_w_poblizu(_).

atakuj :-
        obecna_lokalizacja(Place),
        potwory_lokalizacje(Place, X, Y, _),
        random(2, 12, Z),
        write('Wylosowałeś: '),
        write(Z),
        write('.'),
        nl,
        wynik_walki(Z, Y, X, Place).

wynik_walki(Z, Y, X, Place) :-
        Z > Y, 
        write('Wygrałeś walkę z: '),
        write(X),
        write('!'),
        nl,
        retract(potwory_lokalizacje(Place, _, _, Item)),
        assertz(przedmioty_lokalizacje(Item, Place)),
        nl,
        przedmioty_w_poblizu(Place).

wynik_walki(Z, Y, X) :-
        Z =< Y,
        write('Przegrałeś walkę z: '),
        write(X),
        write('!'),
        nl.

/* This rule just writes out game instructions. */
komendy :-
        nl,
        write('Komendy wpisuj przy użyciu standardowej składni Prologa.'), nl,
        write('Większość komend ma swoje skróty.'), nl,
        write('Np. r[ozejrzyj_sie]. oznacza, że wystarczy wpisać "r.", aby wykonać "rozejrzyj_sie."'), nl,
        write('Dostępne komendy to:'), nl,
        write('start.               -- aby rozpocząć grę.'), nl,
        write('i[dz](Miejsce)       -- aby pójść do tego miejsca.'), nl,
        write('w[ez](obiekt).       -- aby podnieść ten obiekt.'), nl,
        write('u[zyj](obiekt).      -- aby użyć tego obiektu.'), nl,
        write('z[ostaw](obiekt).    -- aby odłożyć ten obiekt.'), nl,
        write('t[rzymasz_lista].    -- aby wypisać przedmioty, które się trzyma.'), nl,
        write('r[ozejrzyj_sie].     -- aby rozejrzeć się dookoła.'), nl,
        write('d[estynacje].        -- aby zobaczyć, gdzie możesz się dostać z miejsca, w którym jesteś.'), nl,
        write('k[omendy].           -- aby ponownie zobaczyć listę dostępnych komend.'), nl,
        write('halt.                -- aby zakończyć grę i z niej wyjść.'), nl,
        nl.

%%%%% Shortcuts %%%%%
i(Place)  :- idz(Place).
w(Object) :- wez(Object).
z(Object) :- zostaw(Object).
u(Object) :- uzyj(Object).
t         :- trzymasz.
r         :- rozejrzyj_sie.
d         :- destynacje.
k         :- komendy.
a         :- atakuj.
%%%%%%%%%%%%%%%%%%%%%


/* This rule prints out instructions and tells where you are. */

start :-
        komendy,
        write('Nareszcie dotarłeś do przedmieści Remisu, gdzie masz nadzieję zgładzić tyrana Foltesta.'),
        nl,
        write('Niestety podróż zajęła dłużej niż oczekiwałeś, a wymarsz armii króla nastąpi za około 25minut.'),
        nl,
        write('Wykorzystaj ten czas mądrze i przygotuj się najlepiej jak potrafisz. Jesteś wiedźminem, sam powinieneś wiedzieć najlepiej czego Ci potrzeba!'),
        nl,
        rozejrzyj_sie.

porazka :-
        write('Niestety Twoja misja zakończyła się klęską.'),
        nl,
        halt.

zwyciestwo :-
        write('Gratulacje, Foltest nie żyje, a Ty liczysz browary, które możesz kupić za pieniądze z nagrody.'),
        nl,
        halt.