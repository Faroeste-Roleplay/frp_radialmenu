game = {}
game.menuEntries = {}
game.currentEntityTarget = nil

local Tunnel = module("frp_lib", "lib/Tunnel")
local Proxy = module("frp_lib", "lib/Proxy")

Business = Proxy.getInterface("business")
Inventory = Tunnel.getInterface("inventory")

function playerHasItem( item, amount )
    local itemCount = exports.ox_inventory:Search('count', item)
    
    return itemCount >= ( amount or 1 )
end

function hasDrugs()
    return playerHasItem( "weed_bag" ) or
    playerHasItem( "opio_bottle" ) or
    playerHasItem( "weed_joint" ) or
    playerHasItem( "moonshine_bottle" ) or
    playerHasItem( "cocaina" ) or
    playerHasItem( "morfina" ) or
    playerHasItem( "presa_del_lobo" ) or
    playerHasItem( "moonshine_rubro" ) or
    playerHasItem( "rubromiralis_do_pantano" ) or
    playerHasItem( "codeina" ) or
    playerHasItem( "eter" ) or
    playerHasItem( "lagrima_da_deusa" ) or
    playerHasItem( "iowaska" ) or
    playerHasItem( "charuto_de_guarma" ) or
    playerHasItem( "cloroformio" ) or
    playerHasItem( "rum_pirata" ) or
    playerHasItem( "finesse" ) or
    playerHasItem( "cannabis_floral" ) or
    playerHasItem( "honey_ocorn_vulture" )
end

function game.start()
  game.registerRadialMenu()
end

function game.stop()
  SetNuiFocus(false, false)
  game.clearRadialItems()
  game.hideRadial()
end

function game.registerRadialMenu()
  game.addRadialItem(game.menuEntries["general"])

  for menuIndex, menu in pairs( game.menuEntries ) do
      if menuIndex ~= "general" then
          game.registerRadial({
              id = menuIndex,
              items = menu,
          })
      end
  end
end

CreateThread(function()
  game.start()
end)

AddEventHandler("onResourceStop", function(resName)
  if resName == GetCurrentResourceName() then
    game.stop()
  end
end)

CreateThread(function()
  while true do
    local idle = 250

    local playerPed = PlayerPedId()

    local entity, entityType, entityCoords = GetEntityPlayerIsLookingAt(3.0, 0.2, 286, playerPed)

    if entity and entityType ~= 0 then
      if entity ~= game.currentEntityTarget then
        game.currentEntityTarget = entity
      end
    elseif game.currentEntityTarget then
      game.currentEntityTarget = nil
    end

    Wait(idle)
  end
end)


function exampleRadialMenu()
  game.registerRadial({
    id = 'police_menu',
    items = {
      {
        label = 'Handcuff',
        icon = 'handcuffs',
        onSelect = 'myMenuHandler'
      },
      {
        label = 'Frisk',
        icon = 'hand'
      },
      {
        label = 'Fingerprint',
        icon = 'fingerprint'
      },
      {
        label = 'Jail',
        icon = 'bus'
      },
      {
        label = 'Search',
        icon = 'magnifying-glass',
      }
    }
  })

  game.addRadialItem({
    {
      id = 'police',
      label = 'Police',
      icon = 'shield-halved',
      menu = 'police_menu'
    },
    {
      id = 'business_stuff',
      label = 'Business',
      icon = 'briefcase',
      -- onSelect = function()
      --   print("Business")
      -- end
    }
  })

  -- local coords = GetEntityCoords(cache.ped)
  -- local point = game.points.new(coords, 5)

  -- function point:onEnter()
  --   game.addRadialItem({
  --     id = 'garage_access',
  --     icon = 'warehouse',
  --     label = 'Garage',
  --     onSelect = function()
  --       print('Garage')
  --     end
  --   })
  -- end

  -- function point:onExit()
  --   game.removeRadialItem('garage_access')
  -- end
end

function _t( string ) 
  return i18n.translate( string )
end