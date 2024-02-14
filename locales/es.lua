local Translations = {
    notify = {
        no_keys = 'No tienes las llaves de este vehículo',
        not_near = 'No hay nadie cerca a quién darle las llaves',
        vehicle_locked = 'Vehículo cerrado',
        vehicle_unlocked = 'Vehículo abierto',
        vehicle_lockedpick = 'Lograste abrir la cerradura',
        failed_lockedpick = 'No logras encontrar las llaves y te frustras',
        gave_keys = 'Has entregado las llaves',
        keys_taken = 'Has recibido las llaves del vehículo',
        fpid = 'Rellene el ID de jugador',
        carjack_failed = '¡Robo de carro falló!',
    },
    progress = {
        takekeys = 'Obteniendo las llaves del cuerpo...',
        searching_keys = 'Buscando las llaves del carro...',
        attempting_carjack = 'Intentando robar carro...',
    },
    info = {
        search_keys = '[H] - Buscar llaves',
        toggle_locks = 'Habilitar/deshabilitar seguro de carro',
        vehicle_theft = 'Robo de vehículo en progreso. Tipo: ',
        engine = 'Encender/apagar motor',
    },
    addcom = {
        givekeys = 'Entregar llaves a alguien. Si no hay ID, entregar a la persona más cercana o a todos en el vehículo.',
        givekeys_id = 'id',
        givekeys_id_help = 'ID de jugador',
        addkeys = 'Agrega llaves a un vehículo para alguien.',
        addkeys_id = 'id',
        addkeys_id_help = 'ID de jugador',
        remove_keys = 'Quitar llaves de un vehículo a alguien.',
        remove_keys_id = 'id',
        remove_keys_id_help = 'ID de jugador',
        remove_keys_plate = 'placa',
        remove_keys_plate_help = 'Placa',
    }

}

if GetConvar('qb_locale', 'en') == 'es' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
