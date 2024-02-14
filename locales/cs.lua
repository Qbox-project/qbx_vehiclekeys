local Translations = {
    notify = {
        no_keys = 'Od tohoto vozidla nemáte klíče.',
        not_near = 'V blízkosti není nikdo, komu by bylo možné předat klíče',
        vehicle_locked = 'Vozidlo je zamčené!',
        vehicle_unlocked = 'Vozidlo odemčeno!',
        vehicle_lockedpick = 'Podařilo se ti otevřít zámek dveří!',
        failed_lockedpick = 'Nedaří se vám najít klíče a jste zklamaní.',
        gave_keys = 'Předáš klíče.',
        keys_taken = 'Dostanete klíčky od vozidla!',
        fpid = 'Vyplňte ID hráče',
        carjack_failed = 'Krádež auta se nezdařila!',
    },
    progress = {
        takekeys = 'Odebírání klíčů z těla...',
        searching_keys = 'Hledání klíčů od auta...',
        attempting_carjack = 'Pokus o krádež auta...',
    },
    info = {
        search_keys = '~g~[H]~w~ - Hledat klíče',
        toggle_locks = 'Zámek od vozidla',
        vehicle_theft = 'Probíhající krádež vozidla. Typ: ',
        engine = 'Zapnout motor',
    },
    addcom = {
        givekeys = 'Předejte někomu klíče. Pokud nemáte průkaz totožnosti, dejte je nejbližší osobě nebo všem ve vozidle.',
        givekeys_id = 'ID',
        givekeys_id_help = 'ID hráče',
        addkeys = 'Přidá někomu klíče od vozidla.',
        addkeys_id = 'ID',
        addkeys_id_help = 'ID hráče',
        remove_keys = 'Odebrat někomu klíče od vozidla.',
        remove_keys_id = 'id',
        remove_keys_id_help = 'ID hráče',
        remove_keys_plate = 'SPZ',
        remove_keys_plate_help = 'SPZ',
    }

}

if GetConvar('qb_locale', 'en') == 'cs' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end