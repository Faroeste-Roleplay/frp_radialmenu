---@class RadialItem
---@field icon string | {[1]: IconProp, [2]: string};
---@field label string
---@field menu? string
---@field onSelect? fun(currentMenu: string | nil, itemIndex: number) | string
---@field [string] any
---@field keepOpen? boolean
---@field iconWidth? number
---@field iconHeight? number
---@field isEnabled? fun(pEntity: number | nil) | boolean

---@class RadialMenuItem: RadialItem
---@field id string

---@class RadialMenuProps
---@field id string
---@field items RadialItem[]
---@field isEnabled? fun(pEntity: number | nil) | boolean
---@field [string] any

local isOpen = false

---@type table<string, RadialMenuProps>
local menus = {}

---@type RadialMenuItem[]
local menuItems = {}

---@type table<{id: string, option: string}>
local menuHistory = {}

---@type RadialMenuProps?
local currentRadial = nil

---Open a the global radial menu or a registered radial submenu with the given id.
---@param id string?
---@param option number?
local function showRadial(id, option)
    local radial = id and menus[id]

    if id and not radial then
        return error('No radial menu with such id found.')
    end

    currentRadial = radial

    -- Hide current menu and allow for transition
    SendNUIMessage({
        action = 'openRadialMenu',
        data = false
    })

    Wait(100)

    local radialItems = radial and radial.items or menuItems

    -- If menu was closed during transition, don't open the submenu
    if not isOpen then return end

    SendNUIMessage({
        action = 'openRadialMenu',
        data = {
            items = getMenuItemsWithoutDisabled(radialItems),
            sub = radial and true or nil,
            option = option
        }
    })
end

---Refresh the current menu items or return from a submenu to its parent.
local function refreshRadial(menuId)
    if not isOpen then return end

    if currentRadial and menuId then
        if menuId == currentRadial.id then
            return showRadial(menuId)
        else
            for i = 1, #menuHistory do
                local subMenu = menuHistory[i]

                if subMenu.id == menuId then
                    local parent = menus[subMenu.id]

                    for j = 1, #parent.items do
                        -- If we still have a path to the current submenu, refresh instead of returning
                        if parent.items[j].menu == currentRadial.id then
                            return -- showRadial(currentRadial.id)
                        end
                    end

                    currentRadial = parent

                    for j = #menuHistory, i, -1 do
                        menuHistory[j] = nil
                    end

                    return showRadial(currentRadial.id)
                end
            end
        end

        return
    end

    table.wipe(menuHistory)
    showRadial()
end

function getMenuItemsWithoutDisabled(items)
    local itemsCloned = deepClone(items)
    local deepCloneTable = {}

    for id, item in pairs(itemsCloned) do
        local isEnabled = item.isEnabled

        if isEnabled and type(isEnabled) ~= "boolean" then
            item.isEnabled = isEnabled(game.currentEntityTarget)
        end

        table.insert(deepCloneTable, item)
    end

    return deepCloneTable
end

function deepClone(orig)
    local origType = type(orig)
    local copy
    if origType == 'table' then
        copy = {}
        for key, value in pairs(orig) do
            copy[key] = deepClone(value) -- Recursivamente clona sub-tabelas
        end
        setmetatable(copy, deepClone(getmetatable(orig))) -- Clona metatable (se existir)
    else
        copy = orig -- Para tipos primitivos, apenas copia o valor
    end
    return copy
end


---Registers a radial sub menu with predefined options.
---@param radial RadialMenuProps
function game.registerRadial(radial)
    menus[radial.id] = radial
    radial.resource = GetInvokingResource()

    if currentRadial then
        refreshRadial(radial.id)
    end
end

function game.getCurrentRadialId()
    return currentRadial and currentRadial.id
end

function game.hideRadial()
    if not isOpen then return end

    SendNUIMessage({
        action = 'openRadialMenu',
        data = false
    })

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    table.wipe(menuHistory)

    isOpen = false
    currentRadial = nil
end

---Registers an item or array of items in the global radial menu.
---@param items RadialMenuItem | RadialMenuItem[]
function game.addRadialItem(items)
    local menuSize = #menuItems
    local invokingResource = GetInvokingResource()

    items = table.type(items) == 'array' and items or { items }

    for i = 1, #items do
        local item = items[i]
        item.resource = invokingResource

        -- if item.isEnabled == nil then
        --     item.isEnabled = true
        -- end

        if menuSize == 0 then
            menuSize += 1
            menuItems[menuSize] = item
        else
            for j = 1, menuSize do
                if menuItems[j].id == item.id then
                    menuItems[j] = item
                    break
                end

                if j == menuSize then
                    menuSize += 1
                    menuItems[menuSize] = item
                end
            end
        end
    end

    if isOpen and not currentRadial then
        refreshRadial()
    end
end

---Removes an item from the global radial menu with the given id.
---@param id string
function game.removeRadialItem(id)
    local menuItem

    for i = 1, #menuItems do
        menuItem = menuItems[i]

        if menuItem.id == id then
            table.remove(menuItems, i)
            break
        end
    end

    if not isOpen then return end

    refreshRadial(id)
end

---Removes all items from the global radial menu.
function game.clearRadialItems()
    table.wipe(menuItems)

    if isOpen then
        refreshRadial()
    end
end

RegisterNUICallback('radialClick', function(index, cb)
    cb(true)

    local itemIndex = index + 1
    local item, currentMenu

    if currentRadial then
        item = currentRadial.items[itemIndex]
        currentMenu = currentRadial.id
    else
        item = menuItems[itemIndex]
    end

    local menuResource = currentRadial and currentRadial.resource or item.resource

    if item.menu then
        menuHistory[#menuHistory + 1] = { id = currentRadial and currentRadial.id, option = item.menu }
        showRadial(item.menu)
    elseif not item.keepOpen then
        game.hideRadial()
    end

    local onSelect = item.onSelect

    if onSelect then
        if type(onSelect) == 'string' then
            return exports[menuResource][onSelect](0, currentMenu, itemIndex)
        end

        onSelect(currentMenu, itemIndex)
    end

    local onEvent = item.onEvent
    local arguments = item.arguments

    if onEvent then
        if type(onEvent) == "string" then
            TriggerEvent(onEvent, arguments)
        end
    end
end)

RegisterNUICallback('radialBack', function(_, cb)
    cb(true)

    local numHistory = #menuHistory
    local lastMenu = numHistory > 0 and menuHistory[numHistory]

    if not lastMenu then return end

    menuHistory[numHistory] = nil

    if lastMenu.id then
        return showRadial(lastMenu.id, lastMenu.option)
    end

    currentRadial = nil

    -- Hide current menu and allow for transition
    SendNUIMessage({
        action = 'openRadialMenu',
        data = false
    })

    Wait(100)

    -- If menu was closed during transition, don't open the submenu
    if not isOpen then return end

    SendNUIMessage({
        action = 'openRadialMenu',
        data = {
            items = menuItems,
            option = lastMenu.option
        }
    })
end)

RegisterNUICallback('radialClose', function(_, cb)
    cb(true)

    if not isOpen then return end

    SetNuiFocus(false, false)

    isOpen = false
    currentRadial = nil
end)

RegisterNUICallback('radialTransition', function(_, cb)
    Wait(100)

    -- If menu was closed during transition, don't open the submenu
    if not isOpen then return cb(false) end

    cb(true)
end)

local isDisabled = false

---Disallow players from opening the radial menu.
---@param state boolean
function game.disableRadial(state)
    isDisabled = state

    if isOpen and state then
        return game.hideRadial()
    end
end

-- RegisterKeyMapping("openRadialMenu", _t("open_radial_menu"), "KEYBOARD", "x")

CreateThread(function()
    while true do
        if not isOpen then
            if 
                -- IsDisabledControlJustPressed(0, `INPUT_INTERACT_OPTION1`) or 
                -- IsDisabledControlJustPressed(0, `INPUT_INTERACT_ANIMAL`) or 
                IsDisabledControlJustPressed(0, `INPUT_SELECT_ITEM_WHEEL`) 
            then -- G
                ExecuteCommand("openRadialMenu")
            end
        end

        if isOpen then
            DisableControlAction(0, `INPUT_FRONTEND_PAUSE_ALTERNATE` , true)
            if IsDisabledControlJustPressed(0, `INPUT_FRONTEND_PAUSE_ALTERNATE`) then
                game.hideRadial()
            end
        end

        Wait(0)
    end
end)

local function NativeIsPedLassoed(ped)
    return Citizen.InvokeNative(0x9682F850056C9ADE, ped)
end

local function radialIsBlocked( ped )
    return IsPedFatallyInjured(ped)
        or IsEntityPlayingAnim(ped, 'dead', 'dead_a', 3)
        or IsPedCuffed(ped)
        or NativeIsPedLassoed(ped)
        or N_0xb655db7582aec805(ped) ~= 0
        or IsPedDeadOrDying( ped )
        or IsEntityPlayingAnim(ped, 'mp_arresting', 'idle', 3)
        or IsEntityPlayingAnim(ped, 'missminuteman_1ig_2', 'handsup_base', 3)
        or IsEntityPlayingAnim(ped, 'missminuteman_1ig_2', 'handsup_enter', 3)
        or IsEntityPlayingAnim(ped, 'random@mugging3', 'handsup_standing_base', 3)
        or IsEntityPlayingAnim(ped, 'script_proc@robberies@shop@rhodes@gunsmith@inside_upstairs', 'handsup_register_owner', 3)
end

RegisterCommand("openRadialMenu", function()
    if isDisabled then return end

    if isOpen then
        return game.hideRadial()
    end

    if #menuItems == 0 or IsNuiFocused() or IsPauseMenuActive() then return end

    isOpen = true

    local blocked = radialIsBlocked( PlayerPedId() )
    
    if blocked then
        return game.hideRadial()
    end

    SendNUIMessage({
        action = 'openRadialMenu',
        data = {
            items = getMenuItemsWithoutDisabled(menuItems)
        }
    })

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)
    SetCursorLocation(0.5, 0.5)

    while isOpen do
        DisablePlayerFiring(PlayerId(), true)
        DisableControlAction(0, 1, true)
        DisableControlAction(0, 2, true)
        DisableControlAction(0, 142, true)
        DisableControlAction(2, 199, true)
        DisableControlAction(2, 200, true)
        Wait(0)
    end
end)


AddEventHandler('onClientResourceStop', function(resource)
    for i = #menuItems, 1, -1 do
        local item = menuItems[i]

        if item.resource == resource then
            table.remove(menuItems, i)
        end
    end
end)
