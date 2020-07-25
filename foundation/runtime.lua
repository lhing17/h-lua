hRuntime = {
    -- 注册runtime的数据
    register = {
        unit = function(json)
            hslk_global.id2Value.unit[json.UNIT_ID] = json
            hslk_global.name2Value.unit[json.Name] = json
            if (json.ID_ARRAY ~= nil) then
                if (hslk_global.id_array.unit[json.ID_ARRAY] == nil) then
                    hslk_global.id_array.unit[json.ID_ARRAY] = {}
                end
                table.insert(hslk_global.id_array.unit[json.ID_ARRAY], json.UNIT_ID)
            end
        end,
        item = function(json)
            hslk_global.id2Value.item[json.ITEM_ID] = json
            hslk_global.name2Value.item[json.Name] = json
            if (type(json.SHADOW_ID) == "string") then
                hslk_global.items_shadow_mapping[json.ITEM_ID] = json.SHADOW_ID
                hslk_global.items_shadow_mapping[json.SHADOW_ID] = json.ITEM_ID
            end
            if (json.ID_ARRAY ~= nil) then
                if (hslk_global.id_array.item[json.ID_ARRAY] == nil) then
                    hslk_global.id_array.item[json.ID_ARRAY] = {}
                end
                table.insert(hslk_global.id_array.item[json.ID_ARRAY], json.ITEM_ID)
            end
        end,
        ability = function(json)
            hslk_global.id2Value.ability[json.ABILITY_ID] = json
            hslk_global.name2Value.ability[json.Name] = json
            if (json.ID_ARRAY ~= nil) then
                if (hslk_global.id_array.ability[json.ID_ARRAY] == nil) then
                    hslk_global.id_array.ability[json.ID_ARRAY] = {}
                end
                table.insert(hslk_global.id_array.ability[json.ID_ARRAY], json.ABILITY_ID)
            end
        end,
        technology = function(json)
            hslk_global.id2Value.technology[json.TECHNOLOGY_ID] = json
            hslk_global.name2Value.technology[json.Name] = json
            if (json.ID_ARRAY ~= nil) then
                if (hslk_global.id_array.technology[json.ID_ARRAY] == nil) then
                    hslk_global.id_array.technology[json.ID_ARRAY] = {}
                end
                table.insert(hslk_global.id_array.technology[json.ID_ARRAY], json.TECHNOLOGY_ID)
            end
        end,
    },
    is = {},
    sound = {},
    env = {},
    camera = {},
    event = {
        -- 核心注册
        register = {},
        -- 池
        pool = {},
    },
    textTag = {},
    rect = {},
    player = {},
    unit = {},
    group = {}, -- 单位选择器
    hero = {},
    unit_type_ids = { --单位类型ID集
        hero = {},
        courier_hero = {},
    },
    heroBuildSelection = {},
    skill = {
        silentUnits = {},
        silentTrigger = nil,
        unarmUnits = {},
        unarmTrigger = nil,
    },
    attribute = {},
    attributeDiff = {},
    attributeBeDamaging = {},
    attributeDamaging = {},
    attributeGroup = {
        life_back = {},
        mana_back = {},
        punish = {}
    },
    item = {},
    itemPickPool = {},
    leaderBoard = {},
    multiBoard = {},
    dialog = {}
}

hRuntime.clear = function(handle)
    if (handle == nil) then
        return
    end
    if (hRuntime.is[handle] ~= nil) then
        hRuntime.is[handle] = nil
    end
    if (hRuntime.sound[handle] ~= nil) then
        hRuntime.sound[handle] = nil
    end
    if (hRuntime.env[handle] ~= nil) then
        hRuntime.env[handle] = nil
    end
    if (hRuntime.camera[handle] ~= nil) then
        hRuntime.camera[handle] = nil
    end
    if (hRuntime.event[handle] ~= nil) then
        hRuntime.event[handle] = nil
    end
    if (hRuntime.event.register[handle] ~= nil) then
        hRuntime.event.register[handle] = nil
    end
    if (hRuntime.event.pool[handle] ~= nil) then
        for _, p in ipairs(hRuntime.event.pool[handle]) do
            local key = p.key
            local poolIndex = p.poolIndex
            hevent.POOL[key][poolIndex].stock = hevent.POOL[key][poolIndex].stock - 1
            -- 起码利用红线一半允许归零
            if (hevent.POOL[key][poolIndex].stock == 0
                and hevent.POOL[key][poolIndex].count > 0.5 * hevent.POOL_RED_LINE) then
                cj.DisableTrigger(hevent.POOL[key][poolIndex].trigger)
                cj.DestroyTrigger(hevent.POOL[key][poolIndex].trigger)
                hevent.POOL[key][poolIndex] = -1
            end
            local e = 0
            for _, v in ipairs(hevent.POOL[key]) do
                if (v == -1) then
                    e = e + 1
                end
            end
            if (e == #hevent.POOL[key]) then
                hevent.POOL[key] = {}
            end
        end
        hRuntime.event.pool[handle] = nil
    end
    if (hRuntime.textTag[handle] ~= nil) then
        hRuntime.textTag[handle] = nil
    end
    if (hRuntime.rect[handle] ~= nil) then
        hRuntime.rect[handle] = nil
    end
    if (hRuntime.player[handle] ~= nil) then
        hRuntime.player[handle] = nil
    end
    if (hRuntime.unit[handle] ~= nil) then
        hRuntime.unit[handle] = nil
    end
    if (table.includes(handle, hRuntime.group)) then
        table.delete(handle, hRuntime.group)
    end
    if (hRuntime.hero[handle] ~= nil) then
        hRuntime.hero[handle] = nil
    end
    if (hRuntime.heroBuildSelection[handle] ~= nil) then
        hRuntime.heroBuildSelection[handle] = nil
    end
    if (hRuntime.skill[handle] ~= nil) then
        hRuntime.skill[handle] = nil
        if (table.includes(handle, hRuntime.skill.silentUnits)) then
            table.delete(handle, hRuntime.skill.silentUnits)
        end
        if (table.includes(handle, hRuntime.skill.unarmUnits)) then
            table.delete(handle, hRuntime.skill.unarmUnits)
        end
    end
    if (hRuntime.attribute[handle] ~= nil) then
        hRuntime.attribute[handle] = nil
    end
    if (hRuntime.attributeDiff[handle] ~= nil) then
        hRuntime.attributeDiff[handle] = nil
    end
    if (hRuntime.attributeDamaging[handle] ~= nil) then
        hRuntime.attributeDamaging[handle] = nil
    end
    if (hRuntime.item[handle] ~= nil) then
        hRuntime.item[handle] = nil
    end
    if (hRuntime.leaderBoard[handle] ~= nil) then
        hRuntime.leaderBoard[handle] = nil
    end
    if (hRuntime.multiBoard[handle] ~= nil) then
        hRuntime.multiBoard[handle] = nil
    end
    if (hRuntime.dialog[handle] ~= nil) then
        hRuntime.dialog[handle] = nil
    end
end

for i = 1, bj_MAX_PLAYER_SLOTS, 1 do
    -- is
    hRuntime.is[i] = {}
    hRuntime.is[i].isComputer = true
    hRuntime.is[i].isAutoConvertGoldToLumber = true
    -- sound
    hRuntime.sound[i] = {}
    hRuntime.sound[i].currentBgm = nil
    hRuntime.sound[i].bgmDelay = 3.00
    -- player
    hRuntime.player[i] = {}
    -- camera
    hRuntime.camera[i] = {}
    hRuntime.camera[i].model = "normal" -- 镜头模型
    hRuntime.camera[i].isShocking = false
end
