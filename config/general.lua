game.menuEntries["general"] = {
    {
        id = "emotes:openmenu",
        label = "Emotes",
        icon = "smile",
        onEvent = "animations:client:ToggleMenu",
        isEnabled = function( pEntity )
            return not IsEntityDead(PlayerPedId())
        end
    },
    {
        icon = 'user',
        id = 'names',
        label = _t("names"),
        onEvent = 'nxt_admin:client:toggleNames',
        isEnabled = function ( pEntity ) 
            return LocalPlayer["state"]["staff"]
        end
    },
    {
        icon = 'star',
        id = 'admin_menu',
        label = _t("admin_menu"),
        onEvent = 'nxt_admin/client/try-open-menu',
        isEnabled = function ( pEntity ) 
            return LocalPlayer["state"]["staff"]
        end
    },
    {
        id = 'deescort',
        label = "Telegrama",
        icon = 'envelope',
        onEvent = 'telegram:client:openUi'
    },
    {
        id = 'walkstyle_menu',
        label = _t("walkstyle"),
        icon = 'walking',
        onEvent = "open:walkStyleMenu",
    },
    {
        id = 'mood_menu',
        label = _t("mood"),
        icon = 'smile',
        onEvent = "open:emotesMenu",
    },
    {
        id = 'clothes_list',
        label = _t("clothes"),
        icon = 'shirt',
        onEvent = "open:clothesList",
    },
    {
        id = 'blips_menu',
        label = _t("blips_menu"),
        menu = "blips",
        icon = 'map'
    },
    {
        id = 'police_menu',
        label = _t("officer_menu"),
        menu = "police",
        icon = 'handcuffs',
        isEnabled = function( pEntity )
            return Business.hasClassePermission("police")
        end
    },
    {
        id = 'crafting_recipes',
        label = _t("crafting_recipes"),
        icon = 'clipboard',
        onEvent = 'open_crafting_food_menu',
        isEnabled = function( pEntity )
            local closest = Property.closestProperty() and Property.isPropertyOwner()
            local hasPerm = Business.hasClassePermission("saloon") or Business.hasClassePermission("bar")
            return (closest ~= nil and closest) and hasPerm
        end
    },
    {
        id = 'drug:seller',
        label = _t("drug_sell"),
        icon = 'vial',
        onEvent = "drugs:client:cornerselling",
        isEnabled = function( pEntity )
            return hasDrugs()
        end
    },
    {
        id = 'house:mainmenu',
        label = _t("properties"),
        icon = 'house',
        onEvent = "properties.managerProperty",
        isEnabled = function( pEntity )
            local closest = Property.closestProperty() and Property.isPropertyOwner()
            return closest ~= nil and closest
        end
    },
    {
        id = 'business',
        label = _t("business"),
        icon = 'briefcase',
        onEvent = "tablet:tryOpen",
        isEnabled = function( pEntity )
            local perms = Business.getAllPermissions()
            return #perms > 0
        end
    },
    {
        id = 'water_wash',
        label = _t("water_wash"),
        icon = 'water',
        onEvent = "banhorio:ok",
        isEnabled = function(  )
            local playerBusy = exports.manager_small_resources:playerBusy()
            local playerInWater = exports.manager_small_resources:playerInWater()

            return not playerBusy and playerInWater
        end
    },
    {
        id = 'water_drink',
        label = _t("water_drink"),
        icon = 'water',
        onEvent = "drp:rio",
        isEnabled = function( )
            local playerBusy = exports.manager_small_resources:playerBusy()
            local playerInWater = exports.manager_small_resources:playerInWater()

            return not playerBusy and playerInWater
        end
    },
}
