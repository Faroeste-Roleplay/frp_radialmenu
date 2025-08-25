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
        id = 'drug:seller',
        label = _t("drug_sell"),
        icon = 'vial',
        onEvent = "drugs:client:cornerselling",
        isEnabled = function( pEntity )
            return hasDrugs()
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
            local playerBusy = exports.frp_manager_snippets:playerBusy()
            local playerInWater = exports.frp_manager_snippets:playerInWater()

            return not playerBusy and playerInWater
        end
    },
    {
        id = 'water_drink',
        label = _t("water_drink"),
        icon = 'water',
        onEvent = "drp:rio",
        isEnabled = function( )
            local playerBusy = exports.frp_manager_snippets:playerBusy()
            local playerInWater = exports.frp_manager_snippets:playerInWater()

            return not playerBusy and playerInWater
        end
    },
}
