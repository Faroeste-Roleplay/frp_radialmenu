game.menuEntries["blips"] = {
    {
        id = "blips_on_map",
        -- icon = 'handcuffs',
        label = _t("show_stores_on_map"),
        onEvent = 'properties:Client:checkStoresBlips'
    },
    {
        id = "blips_on_map_animals",
        -- icon = 'handcuffs',
        label = _t("show_animals_on_map"),
        onEvent = 'blips:client:addAnimalsBlips'
    },
}
