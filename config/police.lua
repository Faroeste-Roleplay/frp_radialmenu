game.menuEntries["police"] = {
    {
        id = "apreender",
        label = "Prender",
        icon = 'handcuffs',
        onEvent = 'police:client:SendToJail',
    },
    {
        id = "mdt",
        label = "MDT",
        icon = 'clipboard',
        onEvent = "police:client:openMdt"
    },
    {
        id = 'release',
        label = "Soltar",
        icon = 'hands',
        onEvent = 'interact:player:tryEscort',
    },
}
