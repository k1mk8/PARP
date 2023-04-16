-- Letho, królobójca, Dyszewski Szymon, Kasperek Karol, Kosmala Piotr

import System.IO
import Text.Read
import Data.Bits
import System.Random
import System.Exit (exitWith, ExitCode(..))

-- dane
data Location = Location {loc_name :: String, connections :: [String], item_list :: [String], monsters :: [(String, Int)]} deriving (Show, Eq)

data Command = Command {com_name :: String, params :: [String]} deriving (Show)

data State = State {location :: Location, all_locations :: [Location], inventory :: [String], variables :: [GameVar]} deriving (Show)

data GameVar = GameVar {var_name :: String, var_value :: Int} deriving (Eq, Show)

introductionText = [
    "Nareszcie dotarłeś do przedmieści Remisu, gdzie masz nadzieję zgładzić tyrana Foltesta." ,
    "Niestety podróż zajęła dłużej niż oczekiwałeś, a wymarsz armii króla nastąpi za około 25 minut."   , 
    "Wykorzystaj ten czas mądrze i przygotuj się najlepiej jak potrafisz. Jesteś wiedźminem, sam powinieneś wiedzieć najlepiej czego Ci potrzeba!"
    ]

instructionsText = [
    "Dostępne komendy:",
    "",
        "i[dz](Miejsce)       -- aby pójść do tego miejsca",
        "w[ez](obiekt).       -- aby podnieść ten obiekt",
        "u[zyj](obiekt).      -- aby użyć tego obiektu",
        "z[ostaw](obiekt).    -- aby odłożyć ten obiekt",
        "e[kwipunek].         -- aby wypisać przedmioty, które się trzymasz",
        "r[ozejrzyj_sie].     -- aby rozejrzeć się dookoła",
        "k[omendy].           -- aby ponownie zobaczyć listę dostępnych komend",
        "z[astaw_pulapke].    -- aby zastawić pułapke (dostępne tylko w zamku)",
        "halt.                -- aby zakończyć grę i z niej wyjść."
    ]

-- data types


brzeg_rzeki = Location "brzeg_rzeki" ["kanaly","szopa","lodka"] [] []
szopa = Location "szopa" ["brzeg_rzeki","skrzynia","stol_rzemieslniczy"] [] []
skrzynia = Location "skrzynia" ["szopa"] ["klucz"] []
stol_rzemieslniczy = Location "stol_rzemieslniczy" ["szopa"] ["lom", "obcegi"] []

kanaly = Location "kanaly" ["drzwi_prowadzace_na_przedmiescia","miejsce_mocy"] ["mozg_utopca"] [("Utopiec", 4)]
miejsce_mocy = Location "miejsce_mocy" ["kanaly"] ["aard"] [("Baba wodna", 6)]
drzwi_prowadzace_na_przedmiescia = Location "drzwi_prowadzace_na_przedmiescia" ["kanaly"] [] []

przedmiescia = Location "przedmiescia" ["handlarz", "dom_handlarza", "ogrody"] [] []
handlarz = Location "handlarz" ["przedmiescia"] ["biala_mewa"] []
dom_handlarza = Location "dom_handlarza" ["przedmiescia"] ["hanusia"] [("maruderzy", 5)]

ogrody = Location "ogrody" ["rabatka", "ognisko", "przedmiescia"] [] []
rabatka = Location "rabatka" ["ogrody"] ["jaskolcze_ziele"] []
ognisko = Location "ognisko" ["ogrody"] [] []

zamek = Location "zamek" ["balkon", "pokoj_dzieci", "salon", "korytarz", "straznica"] [] []
balkon = Location "balkon" ["zamek"] [] []
pokoj_dzieci = Location "pokoj_dzieci" ["zamek"] [] []
salon = Location "salon" ["zamek"] [] []
korytarz = Location "korytarz" ["zamek"] [] []
straznica = Location "straznica" ["zamek"] [] []

loc_list = [brzeg_rzeki, szopa, skrzynia, stol_rzemieslniczy, kanaly, miejsce_mocy, drzwi_prowadzace_na_przedmiescia, przedmiescia, handlarz, dom_handlarza, ogrody, rabatka, ognisko, zamek, balkon, pokoj_dzieci, salon, korytarz, straznica]


describeLocation :: Location -> String
describeLocation l = (base_desc ++ "\n" ++ item_desc ++ "\n" ++ conn_desc ++ mons_desc)
    where
        base_desc = case (loc_name l) of
         "brzeg_rzeki" -> "Stoisz na brzegu rzeki przy łódce którą przypłynąłeś, w oddali widzisz zejście do kanałów oraz starą szopę nieopodal\n"
         "lodka" -> "Jesteś w łódce, którą przypłynąłeś do doków Remisu. Nie ma czasu do stracenia, zaraz będą tu ludzie Foltesta otaczający oblegane miasto.\n"
         "szopa" -> "Poczułeś zapach zatęchłego, dawno zapomnianego warsztatu. Twoim oczom ukazuje się stara drewniana skrzynia oraz stół rzemieślniczy z zardzewiałymi narzędziami.\n"
         "kanaly" -> "Stoisz po pas w ściekach Remisu. Słyszysz jak grupa utopców biegnie w Twoją stronę, co robisz?!\n"

         "skrzynia" -> "Przeczesując rozmaite rupiecie w skrzyni zauważasz coś ciekawego... To klucz, być może przy odrobinie szczęścia uda Ci się znaleźć pasujący do niego zamek!\n"
         "stol_rzemieslniczy" -> "Na stole leżą wielkie zardzewiałe obcęgi oraz łom, mający swoje najlepsze lata już dawno za sobą.\n"

         "drzwi_prowadzace_na_przedmiescia" -> "Stoją przed Tobą wrota prowadzące na przedmieścia Remisu. Próbujesz je otworzyć, ale potężne metalowe zawiasy trzymają je w ryzach. Może spróbuj czegoś innego...\n"
         "miejsce_mocy" -> "Twój medalion drży. Już miałeś zaczerpnąć energii z miejsca mocy, gdy z odmętów wodnych nieopodal wynurzyła się ociekająca szlamem baba wodna.\n"
         "przedmiescia" -> "Przed Twoimi oczami rysują się pełne gwaru i chaosu przedmieścia Remisu. Biegający w popłochu mieszkańcy próbują dostać się do twierdzy zamku poszukując schronienia.\nW tej chmarze ploretariatu udaje Ci się dostrzec wyróżniające się ogniwo. Jest to kupiec próbujący przedrzeć się przez drzwi domu.\nCiężko będzie odnaleźć w tym zamieszaniu Foltesta, przydałoby się jakoś przeniknąć niepostrzeżenie do twierdzy i za wczasu przygotować się do zasadzki.\nW oddali zauważasz również ogrody księżnej.\n"

         "handlarz" -> "Pomocy wiedźminie! W moim domu uwięziona jest córka! Szafa zablokowała drzwi od środka po uderzeniu głazu w dom sąsiada, który cisnięty został przez katapulty Foltesta.\nNa tyłach domu jest jeszcze jedno wejście, pijani maruderzy próbują się dostać do mojej Hanusi. Pośpiesz się prędko!\n"
         "dom_handlarza" -> "Drzwi do domu są otwarte na ościerz, a ze środka dobiegają krzyki młodej dziewczyny. Jeśli chcesz coś zrobić lepiej zrób to teraz!\n"
         "ogrody" -> "Woń kwiatów pozwala Ci zapomnieć na chwilę, że miasto znajduje się pod szturmem armi Foltesta. Jedna z kwiatowych rabat pobudza Twój medalion do drgania.\nO ścianę zamku rozbił się płonący pocisk katapult, z odłamków możnaby utworzyć ognisko. A w samej ścianie dostrzegasz szczelinę, którą z pewnością mógłbyś się przecisnąć.\n"
         "ognisko" -> "Płomień tańczy wysoko ogrzewając okolicę. Gdyby był tu Vesemir na pewno przypomniałby Ci nie jeden wykład z alchemii.\nMożnaby spróbować wytworzyć jakąś miksturę, która ułatwiłaby Ci przedostanie się za mury zamku.\n"
         "rabatka" -> "Między ozdobnymi kwiatami dostrzegasz kilka Jaskółczych Ziel.\n"

         "zamek"            -> "Wchodzisz w bezkres sal i korytarzy potężnego zamku. Rozglądasz się w każdą stronę, w poszukiwaniu pokoju Twoich podopiecznych. \nPotrzebujesz informacji na temat miejsca, w którym najcześciej pojawia się Foltest.\n"
         "pokoj_dzieci"     -> "Przekraczając próg, słyszysz głośny chichot dzieci. Rzucają Ci się na szyję, w końcu jesteś ich opiekunką! Twój podstęp działa, jesteś w stanie zdobyć potrzebne informacje.\n"
         "salon"            -> "Patrzysz w górę, kryształowy żyrandol rozświetla pomieszczenie mogące pomieścić setki gości. \nNa cokole stoi złoty posąg Foltesta. Jesteś jeszcze pewniejszy swojej decyzji.\n"
         "korytarz" -> "Od Twoich butów rozlega się głośne echo. Jednak nie masz pojęcia dokąd prowadzi ta ścieżka. \nCzas goni, a w oddali słychać już armię wroga. Znajdź inną drogę.\n"
         "straznica"          -> "Oczy kilkunastu strażników skierowane są na Ciebie od kiedy tylko przekroczyłaś próg stażnicy. \nPóki co, wydaje się, że nikt nie wie kim tak naprawdę jesteś. Eliksir działa, ale lepiej trzymaj fason!\n"
         "balkon"          -> "Panorama miasta maluje się pod Twoimi stopami, a powiew świeżego wiatru muska blizny na Twojej twarzy. \nWydaje Ci się, że to dobre miejsce na zakończenie żywota Twojego celu.\n"

         _ -> "Jestes w jakims nieznanym miejcu... Powinienes pic nieco mniej piwa\n"
        item_desc = if (length (item_list l)) == 0 then "Nie ma tu zadnej ciekawej rzeczy\n" else "Jest tu:\n" ++ numberedList (item_list l) ++ "\n"
        conn_desc = if (length (connections l)) == 0 then "Nie mozesz stad isc do innego miejsca. Wyglada na to, ze tu utknales\n" else "Z tego miejsca mozesz isc do:\n" ++ numberedList (connections l)
        mons_desc = if (length (monsters l)) == 0 then "Nie ma tutaj przeciwnika\n" else "Twoim przeciwnikiem jest: \n" ++ numberedList (map fst (monsters l)) ++ "\nWpisz \"a\", żeby zaatakować przeciwnika \n"


checkFlag :: State -> String -> Bool
checkFlag state n = var_value (getVariable state n) /= 0



insertValueIntoVariables :: [GameVar] -> String -> Int -> [GameVar]
insertValueIntoVariables gv v nv =
    insertValueIntoVariablesLoop gv v nv []
    where
        insertValueIntoVariablesLoop [] varname nvalue newgamevars = newgamevars
        insertValueIntoVariablesLoop (g : gamevars) varname nvalue newgamevars | (var_name g) == varname = newgamevars ++ [GameVar varname nvalue] ++ gamevars
                                                                               | otherwise = insertValueIntoVariablesLoop gamevars varname nvalue (newgamevars ++ [g])

insertValuesIntoVariables :: [GameVar] -> [(String, Int)] -> [GameVar]
insertValuesIntoVariables vars [] = vars
insertValuesIntoVariables vars (x:xs) = insertValuesIntoVariables (insertValueIntoVariables vars (fst x) (snd x)) xs


getVariable :: State -> String -> GameVar
getVariable state name = getVariableLoop (variables state) name
    where getVariableLoop [] _ = GameVar "unknown" 0
          getVariableLoop (x:xs) name | (var_name x) == name = x
                                      | otherwise = getVariableLoop xs name

seeInventory :: State -> IO State
seeInventory state | (length (inventory state)) == 0 = printMessage state "Nie posiadasz żadnego przedmiotu\n"
                   | otherwise = printMessage state ("Posiadasz następujące przedmioty:\n" ++ (numberedList (inventory state)))

numberedList' :: Int -> [String] -> String
numberedList' i [one]   = (show i) ++ ". " ++ one ++ "\n"
numberedList' i (l:ls) = (numberedList' i [l]) ++ (numberedList' (i+1) ls)


numberedList :: [String] -> String
numberedList = numberedList' 1 -- point free style!!


getLocationFromString :: String -> [Location] -> Location
getLocationFromString s [] = Location "" [] [] []
getLocationFromString s (l:ls) |  loc_name l == s = l
                               | otherwise = getLocationFromString s ls


getElementAtIndex :: [a] -> String -> Maybe a -- returns from [a] if valid index (1-indexed)
getElementAtIndex lst indexString = do
    let index = readMaybe indexString  :: Maybe Int
    let element = case index of
                Nothing -> Nothing
                Just valid ->   if valid-1 >= 0 && valid-1 < length lst
                                then Just (lst !! (valid-1))
                                else Nothing
    element


descLoop []     fs = fs ++ "\n"
descLoop (l:ls) s = descLoop ls (s ++ " " ++ l)


printMessage :: State -> String -> IO State
printMessage state m = do
    putStr m
    return state


-- print strings from list in separate lines
printLines :: [String] -> IO ()
printLines xs = putStr (unlines xs)

printIntroduction = printLines introductionText
printInstructions = printLines instructionsText

readCommand :: IO String
readCommand = do
    putStr "> "
    hFlush stdout
    xs <- getLine
    return xs

-- starting state and vars
win_state = GameVar "win" 0
trader_flag = GameVar "handlarz" 0
visits_flag = GameVar "odwiedzenia" 0

vars = [win_state, trader_flag, visits_flag]


canGoTo :: Location -> Location -> Bool
canGoTo a b =
    elem (loc_name b) loc_names
    where
        loc_names = (connections a)


goToLocation :: State -> String -> IO State
goToLocation (State source all_loc i v) raw_dest = do
    let indexTry = getElementAtIndex (connections source) raw_dest
    let dest = case indexTry of
                Just a -> getLocationFromString a all_loc
                Nothing -> getLocationFromString raw_dest all_loc
    let Location _ _ _ monsters = source
    let Location a b c d = dest
    let variables = if(a == "handlarz") then insertValueIntoVariables v "odwiedzenia" ((var_value (getVariable (State source all_loc i v) "odwiedzenia")) + 1) else insertValueIntoVariables v "odwiedzenia" (var_value (getVariable (State source all_loc i v) "odwiedzenia"))
    if (var_value (getVariable (State source all_loc i v) "odwiedzenia") == 1 && a == "handlarz") then printMessage (State (Location a b c [("handlarz", 7)]) all_loc i variables)(describeLocation (Location a b c [("handlarz", 7)]))
    else if (var_value (getVariable (State source all_loc i v) "odwiedzenia") == 0 && a == "handlarz") then printMessage (State (Location a b [] d) all_loc i variables)(describeLocation (Location a b [] d))
    else if length monsters > 0 then printMessage (State source all_loc i v) "Zanim przejdziesz dalej musisz pokonać swojego przeciwnika!!!\n"
    else
            case canGoTo source dest of
                True    -> printMessage (State dest all_loc i variables) (describeLocation dest)
                False   -> if (dest == source) then printMessage (State source all_loc i v) "Juz tutaj jestes\n" else printMessage (State source all_loc i v) "Nie mozesz tam isc z tego miejsca\n"


takeItem :: State -> String -> IO State
takeItem (State l al inventory v) item = do     
    let Location loc _ _ monsters = l
    if length monsters > 0 
        then printMessage (State l al inventory v) "Zanim podniesiesz przedmiot musisz pokonać swojego przeciwnika!!!\n"
    else if elem item (item_list l)
        then printMessage (State (removeItemFromLoc l) (removeItemFromLocList al []) (item:inventory) v) (if item /= "hanusia" then "Udało Ci się podnieść przedmiot\n" else "Hanusia idzie z Tobą!\n")
        else if indexElement /= "" 
            then takeItem (State l al inventory v) indexElement
            else printMessage (State l al inventory v) "Nie możesz podnieść tego przedmiotu, bo tu go nie ma.\n"
    where
        removeItemFromLoc (Location name conns items monsters) = Location name conns [i | i <- items, i /= item] monsters
        removeItemFromLocList [] locs = locs
        removeItemFromLocList (loc : xloc) locs
            | loc == l = locs ++ [(removeItemFromLoc loc)] ++ xloc
            | otherwise = removeItemFromLocList xloc (locs ++ [loc])
        indexElement = case getElementAtIndex (item_list l) item of
                            Just a -> a
                            Nothing -> ""


useItem :: State -> String -> IO State
useItem (State l al inventory v) item = do
    if(item == "klucz" && l == getLocationFromString "drzwi_prowadzace_na_przedmiescia" loc_list) then printMessage (State klucz_dest al (removeItemFromEQ inventory item) v) (describeLocation klucz_dest)
    else if(item == "aard" && l == getLocationFromString "drzwi_prowadzace_na_przedmiescia" loc_list) then printMessage (State aard_dest al (removeItemFromEQ inventory item) v) (describeLocation aard_dest)
    else if(item == "dekokt_raffarda_bialego" && l == getLocationFromString "ogrody" loc_list) then printMessage (State dekokt_dest al (removeItemFromEQ inventory item) v) (describeLocation dekokt_dest)
    else if(item == "lom" && l == getLocationFromString "drzwi_prowadzace_na_przedmiescia" loc_list) then printMessage (State l al (removeItemFromEQ inventory item) v) (describeLocation l)
    else if(item == "hanusia" && a == "handlarz") then printMessage (State (Location a b c []) (Location a b c [] :(removeMonsterFromLocList al l)) (removeItemFromEQ inventory item) variables) "Dziekuje Ci wiedźminie, za uratowanie mojej corki, oto biala mewa - może Ci się przydac w alchemii!\n"
    else printMessage (State l al inventory v) "Nie mozesz uzyc tego w tym miejscu!\n"
        where
            removeItemFromEQ items item = [i | i <- items, i /= item]
            klucz_dest = getLocationFromString "przedmiescia" loc_list
            aard_dest = getLocationFromString "przedmiescia" loc_list
            dekokt_dest = getLocationFromString "zamek" loc_list
            variables = insertValueIntoVariables v "handlarz" 1
            Location a b c _ = l
            removeMonsterFromLocList al l = [i | i <- al, i /= l]


makePotion :: State -> String -> String -> String -> IO State
makePotion (State l al inventory v) item1 item2 item3
    | elem item1 inventory == True && elem item2 inventory == True && elem item3 inventory == True && l == getLocationFromString "ognisko" loc_list && item1 == "biala_mewa" && item2 == "jaskolcze_ziele" && item3 == "mozg_utopca" =
        printMessage (State l al ("dekokt_raffarda_bialego":newInventory inventory item1 item2 item3) v) "Udało Ci sie sporzadzic eliksir przemiany! Uzyj go madrze\n"
    | otherwise = printMessage (State l al inventory v) "Sprobuj w innym miejscu lub polacz rzeczy w innej kolejnosci\n"
    where
        newInventory items item1 item2 item3 = [i | i <- items, i /= item1, i /= item2, i /= item3]

attackMonster :: State -> IO State
attackMonster (State l al inventory v) = do
        let Location loc conns items mons = l
        let new_al = copyListWithoutElement al l
        if null mons then do
            putStrLn "Nie ma potwora do pokonania w tym miejscu.\n"
            return (State (Location loc conns items []) ((Location loc conns items []) : new_al) inventory v)
        else do
            randomNumber <- randomRIO (2, 12)
            let monsterPower = sum $ map snd mons
            case randomNumber > monsterPower of
                True -> do
                    putStrLn "Pokonales potwora! Rozejrzyj się!\n"
                    return (State (Location loc conns items []) ((Location loc conns items []) : new_al) inventory v)
                False -> do
                    putStrLn "Pojedynek zakończył się klęską... Zostajesz zabity.\n"
                    halt (State l al inventory v) (-1)
    where
        copyListWithoutElement :: Eq a => [a] -> a -> [a]
        copyListWithoutElement al l = [y | y <- al, y /= l]

setTrap :: State -> IO State
setTrap (State l al inventory v) = do
    let Location loc conns items mons = l
    if(loc == "straznica") then halt (State l al inventory v) (-1)
    else if(loc == "zamek") then halt (State l al inventory v) (-1)
    else if(loc == "balkon") then halt (State l al inventory v) 1
    else if(loc == "pokoj_dzieci") then printMessage (State l al inventory v) "Zabicie ojca na oczach jego własnych dzieci nawet Tobie wydaje się być zbyt okrutne...\n"
    else if(loc == "korytarz" && (var_value (getVariable (State l al inventory v) "handlarz") == 1)) then halt (State l al inventory v) 1
    else if(loc == "korytarz" && (var_value (getVariable (State l al inventory v) "handlarz") == 0)) then halt (State l al inventory v) (-1)
    else if(loc == "salon" && (var_value (getVariable (State l al inventory v) "handlarz") == 1)) then halt (State l al inventory v) 1
    else if(loc == "salon" && (var_value (getVariable (State l al inventory v) "handlarz") == 0)) then halt (State l al inventory v) (-1)
    else printMessage (State l al inventory v) "Komenda jeszcze niedostępna\n"

halt :: State -> Int -> IO State
halt (State l al i v) gameresult = return (State l al i newv)
    where
        newv = insertValueIntoVariables v "win" (gameresult)



execCommand :: Command -> State -> IO State
execCommand cmd gameState = do
    case (com_name cmd) of
        "komendy"           ->   printInstructions >> return gameState
        "k"                 ->   printInstructions >> return gameState
        "idz"               -> if (length (params cmd) == 1) then goToLocation gameState ((params cmd) !! 0) else printMessage gameState "Niewlasciwe uzycie komendy: go <lokacja|nr>\n"
        "i"                 -> if (length (params cmd) == 1) then goToLocation gameState ((params cmd) !! 0) else printMessage gameState "Niewlasciwe uzycie komendy: go <lokacja|nr>\n"
        "wez"               -> if (length (params cmd) == 1) then takeItem gameState ((params cmd) !! 0) else printMessage gameState "Niewlasciwe uzycie komendy: take <przedmiot|nr>\n"
        "w"                 -> if (length (params cmd) == 1) then takeItem gameState ((params cmd) !! 0) else printMessage gameState "Niewlasciwe uzycie komendy: take <przedmiot|nr>\n"
        "ekwipunek"         -> if (length (params cmd) == 0) then seeInventory gameState else printMessage gameState "Komenda 'inventory' nie przyjmuje żadnyh parametrów\n"
        "e"                 -> if (length (params cmd) == 0) then seeInventory gameState else printMessage gameState "Komenda 'inventory' nie przyjmuje żadnyh parametrów\n"
        "halt"              -> if (length (params cmd) == 0) then halt gameState (-1) else printMessage gameState "Komenda 'halt' nie przyjmuje żadnyh parametrów\n"
        "rozejrzyj_sie"     -> if (length (params cmd) == 0) then printMessage gameState (describeLocation (location gameState)) else printMessage gameState "Komenda 'look' nie przyjmuje żadnyh parametrów\n"
        "r"                 -> if (length (params cmd) == 0) then printMessage gameState (describeLocation (location gameState)) else printMessage gameState "Komenda 'look' nie przyjmuje żadnyh parametrów\n"
        "uzyj"              -> if (length (params cmd) == 1) then useItem gameState ((params cmd) !! 0) else printMessage gameState "Niewlasciwe uzycie komendy: uzyj <przedmiot|nr>\n"
        "u"                 -> if (length (params cmd) == 1) then useItem gameState ((params cmd) !! 0) else printMessage gameState "Niewlasciwe uzycie komendy: uzyj <przedmiot|nr>\n"
        "przygotuj_eliksir" -> if(length (params cmd) == 3) then makePotion gameState ((params cmd) !! 0) ((params cmd) !! 1) ((params cmd) !! 2) else printMessage gameState "Niewlasciwe uzycie komendy: przygotuj_eliksir <przedmiot|nr> <przedmiot|nr> <przedmiot|nr>\n"
        "p"                 -> if(length (params cmd) == 3) then makePotion gameState ((params cmd) !! 0) ((params cmd) !! 1) ((params cmd) !! 2) else printMessage gameState "Niewlasciwe uzycie komendy: przygotuj_eliksir <przedmiot|nr> <przedmiot|nr> <przedmiot|nr>\n"    
        "atakuj"            -> if(length (params cmd) == 0) then attackMonster gameState else printMessage gameState "Niewlasciwe uzycie komendy: przygotuj_eliksir <przedmiot|nr> <przedmiot|nr> <przedmiot|nr>\n"
        "a"                 -> if(length (params cmd) == 0) then attackMonster gameState else printMessage gameState "Niewlasciwe uzycie komendy: przygotuj_eliksir <przedmiot|nr> <przedmiot|nr> <przedmiot|nr>\n"    
        "zastaw_pulapke"    -> if(length (params cmd) == 0) then setTrap gameState else printMessage gameState "Niewlasciwe uzycie komendy: przygotuj_eliksir <przedmiot|nr> <przedmiot|nr> <przedmiot|nr>\n"
        "z"                 -> if(length (params cmd) == 0) then setTrap gameState else printMessage gameState "Niewlasciwe uzycie komendy: przygotuj_eliksir <przedmiot|nr> <przedmiot|nr> <przedmiot|nr>\n"
        _                   -> printMessage gameState "Nieznana komenda, wpisz \"help\"\n" --unknown command

createCommand :: String -> Command
createCommand s = createCommandLoop s [] []

createCommandLoop [] cc cs = finalizeCreateCommand (cs ++ [cc])
createCommandLoop xs cc cs | head xs == ' ' = createCommandLoop (tail xs) [] (cs ++ [cc])
                               | otherwise = createCommandLoop (tail xs) (cc ++ [head xs]) cs

finalizeCreateCommand list = Command (head parsed_list) (tail parsed_list)
    where
        parsed_list = filter (\e -> e/=[]) list


finishGame :: State -> IO Bool
finishGame state = do
    let winState = case (var_value (getVariable state "win")) of
                    1 -> (True, "Wygrałeś grę.\n")
                    0 -> (False, "")
                    -1 -> (True, "Przegrałeś grę!\n")
    putStr (snd winState)
    return (fst winState)


stateManager :: State -> IO ()
stateManager (State s a i variables) = do
    let newv = insertValueIntoVariables variables "beer_flag" (1)
    raw_cmd <- readCommand
    let cmd = createCommand raw_cmd
    newState <- execCommand cmd (State s a i newv)
    finishFlag <- finishGame newState
    if finishFlag == False then stateManager newState else putStrLn "\nKoniec gry"


gameLoop :: IO ()
gameLoop = do
    let initState = State przedmiescia loc_list [] vars
    putStrLn (describeLocation (location initState))
    stateManager initState
    

main = do
    printIntroduction
    printInstructions
    gameLoop
