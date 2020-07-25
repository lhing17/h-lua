---@class hattribute 属性系统
hattribute = {
    max_move_speed = 522,
    max_life = 999999999,
    max_mana = 999999999,
    min_life = 1,
    min_mana = 1,
    max_attack_range = 9999,
    min_attack_range = 0,
    threeBuff = {
        -- 每一点三围对属性的影响，默认会写一些，可以通过 hattr.setThreeBuff 方法来改变系统构成
        -- 需要注意的是三围只能影响common内的大部分参数，natural及effect是无效的
        primary = 1, -- 每点主属性提升1点白字攻击（默认例子，这是模拟原生平衡性常数，需要设置平衡性常数为0）
        str = {
            life = 19, -- 每点力量提升10生命（默认例子）
            life_back = 0.05 -- 每点力量提升0.05生命恢复（默认例子）
        },
        agi = {
            defend = 0.01 -- 每点敏捷提升0.01护甲（默认例子）
        },
        int = {
            mana = 6, -- 每点智力提升6魔法（默认例子）
            mana_back = 0.05 -- 每点力量提升0.05生命恢复（默认例子）
        }
    },
    DEFAULT_SKILL_ITEM_SLOT = string.char2id("AInv"), -- 默认物品栏技能（英雄6格那个）默认认定这个技能为物品栏
}

--- 为单位添加N个同样的生命魔法技能 1级设0 2级设负 负减法（搜[卡血牌bug]，了解原理）
---@private
hattribute.setLM = function(u, abilityId, qty)
    if (qty <= 0) then
        return
    end
    local i = 1
    while (i <= qty) do
        cj.UnitAddAbility(u, abilityId)
        cj.SetUnitAbilityLevel(u, abilityId, 2)
        cj.UnitRemoveAbility(u, abilityId)
        i = i + 1
    end
end

--- 为单位添加N个同样的攻击之书
---@private
hattribute.setAttackWhite = function(u, itemId, qty)
    if (u == nil or itemId == nil or qty <= 0) then
        return
    end
    if (his.alive(u) == true) then
        local i = 1
        local it
        local hasSlot = (cj.GetUnitAbilityLevel(u, hattribute.DEFAULT_SKILL_ITEM_SLOT) >= 1)
        if (hasSlot == false) then
            cj.UnitAddAbility(u, hattribute.DEFAULT_SKILL_ITEM_SLOT)
        end
        while (i <= qty) do
            it = cj.CreateItem(itemId, 0, 0)
            cj.UnitAddItem(u, it)
            cj.SetWidgetLife(it, 10.00)
            cj.RemoveItem(it)
            i = i + 1
        end
        if (hasSlot == false) then
            cj.UnitRemoveAbility(u, hattribute.DEFAULT_SKILL_ITEM_SLOT)
        end
    else
        local per = 3.00
        local limit = 60.0 / per -- 一般不会超过1分钟复活
        htime.setInterval(
            per,
            function(t)
                limit = limit - 1
                if (limit < 0) then
                    htime.delTimer(t)
                elseif (his.alive(u) == true) then
                    htime.delTimer(t)
                    local i = 1
                    local it
                    local hasSlot = (cj.GetUnitAbilityLevel(u, hattribute.DEFAULT_SKILL_ITEM_SLOT) >= 1)
                    if (hasSlot == false) then
                        cj.UnitAddAbility(u, hattribute.DEFAULT_SKILL_ITEM_SLOT)
                    end
                    while (i <= qty) do
                        it = cj.CreateItem(itemId, 0, 0)
                        cj.UnitAddItem(u, it)
                        cj.SetWidgetLife(it, 10.00)
                        cj.RemoveItem(it)
                        i = i + 1
                    end
                    if (hasSlot == false) then
                        cj.UnitRemoveAbility(u, hattribute.DEFAULT_SKILL_ITEM_SLOT)
                    end
                end
            end
        )
    end
end

--- 设置三围的影响
---@param buff table
hattribute.setThreeBuff = function(buff)
    if (type(buff) == "table") then
        hattribute.threeBuff = buff
    end
end

--- 为单位注册属性系统所需要的基础技能
--- hslk_global.attr
---@private
hattribute.regAllAbility = function(whichUnit)
    for _, v in ipairs(hslk_global.attr.ablis_gradient) do
        -- 生命
        cj.UnitAddAbility(whichUnit, hslk_global.attr.life.add[v])
        cj.UnitRemoveAbility(whichUnit, hslk_global.attr.life.add[v])
        cj.UnitAddAbility(whichUnit, hslk_global.attr.life.sub[v])
        cj.UnitRemoveAbility(whichUnit, hslk_global.attr.life.sub[v])
        -- 魔法
        cj.UnitAddAbility(whichUnit, hslk_global.attr.mana.add[v])
        cj.UnitRemoveAbility(whichUnit, hslk_global.attr.mana.add[v])
        cj.UnitAddAbility(whichUnit, hslk_global.attr.mana.sub[v])
        cj.UnitRemoveAbility(whichUnit, hslk_global.attr.mana.sub[v])
        -- 绿字攻击
        cj.UnitAddAbility(whichUnit, hslk_global.attr.attack_green.add[v])
        cj.UnitRemoveAbility(whichUnit, hslk_global.attr.attack_green.add[v])
        cj.UnitAddAbility(whichUnit, hslk_global.attr.attack_green.sub[v])
        cj.UnitRemoveAbility(whichUnit, hslk_global.attr.attack_green.sub[v])
        -- 绿色属性
        cj.UnitAddAbility(whichUnit, hslk_global.attr.str_green.add[v])
        cj.UnitRemoveAbility(whichUnit, hslk_global.attr.str_green.add[v])
        cj.UnitAddAbility(whichUnit, hslk_global.attr.str_green.sub[v])
        cj.UnitRemoveAbility(whichUnit, hslk_global.attr.str_green.sub[v])
        cj.UnitAddAbility(whichUnit, hslk_global.attr.agi_green.add[v])
        cj.UnitRemoveAbility(whichUnit, hslk_global.attr.agi_green.add[v])
        cj.UnitAddAbility(whichUnit, hslk_global.attr.agi_green.sub[v])
        cj.UnitRemoveAbility(whichUnit, hslk_global.attr.agi_green.sub[v])
        cj.UnitAddAbility(whichUnit, hslk_global.attr.int_green.add[v])
        cj.UnitRemoveAbility(whichUnit, hslk_global.attr.int_green.add[v])
        cj.UnitAddAbility(whichUnit, hslk_global.attr.int_green.sub[v])
        cj.UnitRemoveAbility(whichUnit, hslk_global.attr.int_green.sub[v])
        -- 攻击速度
        cj.UnitAddAbility(whichUnit, hslk_global.attr.attack_speed.add[v])
        cj.UnitRemoveAbility(whichUnit, hslk_global.attr.attack_speed.add[v])
        cj.UnitAddAbility(whichUnit, hslk_global.attr.attack_speed.sub[v])
        cj.UnitRemoveAbility(whichUnit, hslk_global.attr.attack_speed.sub[v])
        -- 防御
        cj.UnitAddAbility(whichUnit, hslk_global.attr.defend.add[v])
        cj.UnitRemoveAbility(whichUnit, hslk_global.attr.defend.add[v])
        cj.UnitAddAbility(whichUnit, hslk_global.attr.defend.sub[v])
        cj.UnitRemoveAbility(whichUnit, hslk_global.attr.defend.sub[v])
    end
    for _, v in ipairs(hslk_global.attr.sight_gradient) do
        -- 视野
        cj.UnitAddAbility(whichUnit, hslk_global.attr.sight.add[v])
        cj.UnitRemoveAbility(whichUnit, hslk_global.attr.sight.add[v])
        cj.UnitAddAbility(whichUnit, hslk_global.attr.sight.sub[v])
        cj.UnitRemoveAbility(whichUnit, hslk_global.attr.sight.sub[v])
    end
end

--- 为单位初始化属性系统的对象数据
--- @private
hattribute.init = function(whichUnit)
    if (whichUnit == nil) then
        return false
    end
    -- init
    local slkData = hunit.getSlk(whichUnit)
    hRuntime.attribute[whichUnit] = {
        primary = slkData.Primary or "STR",
        life = cj.GetUnitState(whichUnit, UNIT_STATE_MAX_LIFE),
        mana = cj.GetUnitState(whichUnit, UNIT_STATE_MAX_MANA),
        move = cj.GetUnitDefaultMoveSpeed(whichUnit),
        defend = slkData.def or 0,
        attack_damage_type = {},
        attack_speed = 0.0,
        attack_speed_space = slkData.cool1 or 1.50,
        attack_white = 0.0,
        attack_green = 0.0,
        attack_range = slkData.rangeN1 or 100,
        sight = slkData.sight or 1800,
        str_green = 0.0,
        agi_green = 0.0,
        int_green = 0.0,
        str_white = 0,
        agi_white = 0,
        int_white = 0,
        life_back = 0.0,
        mana_back = 0.0,
        resistance = 0.0,
        toughness = 0.0,
        avoid = 0.0,
        aim = 0.0,
        punish = 0.0,
        punish_current = 0.0,
        meditative = 0.0,
        help = 0.0,
        hemophagia = 0.0,
        hemophagia_skill = 0.0,
        luck = 0.0,
        invincible = 0.0,
        weight = 0.0,
        weight_current = 0.0,
        damage_extent = 0.0,
        damage_rebound = 0.0,
        cure = 0.0,
        knocking_oppose = 0.0,
        violence_oppose = 0.0,
        hemophagia_oppose = 0.0,
        hemophagia_skill_oppose = 0.0,
        split_oppose = 0.0,
        punish_oppose = 0.0,
        damage_rebound_oppose = 0.0,
        swim_oppose = 0.0,
        heavy_oppose = 0.0,
        broken_oppose = 0.0,
        unluck_oppose = 0.0,
        silent_oppose = 0.0,
        unarm_oppose = 0.0,
        fetter_oppose = 0.0,
        bomb_oppose = 0.0,
        lightning_chain_oppose = 0.0,
        crack_fly_oppose = 0.0,
        natural_fire = 0.0,
        natural_soil = 0.0,
        natural_water = 0.0,
        natural_ice = 0.0,
        natural_wind = 0.0,
        natural_light = 0.0,
        natural_dark = 0.0,
        natural_wood = 0.0,
        natural_thunder = 0.0,
        natural_poison = 0.0,
        natural_ghost = 0.0,
        natural_metal = 0.0,
        natural_dragon = 0.0,
        natural_insect = 0.0,
        natural_god = 0.0,
        natural_fire_oppose = 0.0,
        natural_soil_oppose = 0.0,
        natural_water_oppose = 0.0,
        natural_ice_oppose = 0.0,
        natural_wind_oppose = 0.0,
        natural_light_oppose = 0.0,
        natural_dark_oppose = 0.0,
        natural_wood_oppose = 0.0,
        natural_thunder_oppose = 0.0,
        natural_poison_oppose = 0.0,
        natural_ghost_oppose = 0.0,
        natural_metal_oppose = 0.0,
        natural_dragon_oppose = 0.0,
        natural_insect_oppose = 0.0,
        natural_god_oppose = 0.0,
        attack_buff = {},
        attack_debuff = {},
        skill_buff = {},
        skill_debuff = {},
        -- 特殊特效
        attack_effect = {},
        skill_effect = {}
        --[[
            buff/debuff例子
            attack_buff = {
                攻击伤害时buff=20%几率增加自身 1.5% 的攻击速度 3 秒
                add = { --这个add表示添加这一种效果，而不是数值的增减
                    { attr="attack_speed", odds = 20.0, val = 1.5, during = 3.0, effect = nil },
                },
                sub = { --这个sub表示删除这一种效果，如果效果不存在，而无动作
                    { attr="attack_speed", odds = 20.0, val = 1.5, during = 3.0, effect = nil },
                }
            }
            skill_debuff = {
                技能伤害时buff=13%几率减少目标 3.5% 的攻击速度 4.4 秒，特效是 war3mapImported\\ExplosionBIG.mdl
                add = {
                    { attr="move",odds = 13.0, val = 3.5, during = 4.4, effect = 'war3mapImported\\ExplosionBIG.mdl' },
                },
                sub = { --这个sub表示删除这一种效果，如果效果不存在，而无动作
                    { attr="move",odds = 13.0, val = 3.5, during = 4.4, effect = 'war3mapImported\\ExplosionBIG.mdl' },
                }
            }
            attack_effect / skill_effect同理,effect只能设定下列的值，会在属性系统自动调用：
                {attr="knocking",odds = 0.0, percent = 0.0, effect = nil},
                {attr="violence",odds = 0.0, percent = 0.0, effect = nil},
                {attr="split",odds = 0.0, percent=0.0, range = 0.0, effect = nil},
                {attr="swim",odds = 0.0, val = 0.0, during = 0.0, effect = nil},
                {attr="broken",odds = 0.0, val = 0.0, during = 0.0, effect = nil},
                {attr="silent",odds = 0.0, val = 0.0, during = 0.0, effect = nil},
                {attr="unarm",odds = 0.0, val = 0.0, during = 0.0, effect = nil},
                {attr="fetter",odds = 0.0, val = 0.0, during = 0.0, effect = nil},
                {attr="bomb",odds = 0.0, range = 0.0, val = 0.0, during = 0.0, effect = nil},
                {attr="lightning_chain",odds = 0.0, val = 0.0, effect = nil, qty = 0, reduce = 0.0},
                {attr="crack_fly",odds = 0.0, val = 0.0, during = 0.0, effect = nil, distance = 0, high = 0.0}
            * 至于是否同一种效果，是根据你设定的值自动计算出来的
        ]]
    }
    -- 智力英雄的攻击默认为魔法，力量敏捷为物理
    if (hRuntime.attribute[whichUnit].primary == "INT") then
        hRuntime.attribute[whichUnit].attack_damage_type = { CONST_DAMAGE_TYPE.magic }
    else
        hRuntime.attribute[whichUnit].attack_damage_type = { CONST_DAMAGE_TYPE.physical }
    end
    return true
end

--- @private
hattribute.getAccumuDiff = function(whichUnit, attr)
    if (hRuntime.attributeDiff[whichUnit] == nil) then
        hRuntime.attributeDiff[whichUnit] = {}
    end
    return hRuntime.attributeDiff[whichUnit][attr] or 0
end

--- @private
hattribute.setAccumuDiff = function(whichUnit, attr, value)
    if (hRuntime.attributeDiff[whichUnit] == nil) then
        hRuntime.attributeDiff[whichUnit] = {}
    end
    hRuntime.attributeDiff[whichUnit][attr] = math.round(value)
end

--- @private
hattribute.addAccumuDiff = function(whichUnit, attr, value)
    hattribute.setAccumuDiff(whichUnit, attr, hattribute.getAccumuDiff(whichUnit, attr) + value)
end

--- @private
hattribute.subAccumuDiff = function(whichUnit, attr, value)
    hattribute.setAccumuDiff(whichUnit, attr, hattribute.getAccumuDiff(whichUnit, attr) - value)
end

-- 设定属性
--[[
    白字攻击 绿字攻击
    攻速 视野 射程
    力敏智 力敏智(绿)
    护甲 魔抗
    生命 魔法 +恢复
    硬直
    物暴 术暴 分裂 回避 移动力 力量 敏捷 智力 救助力 吸血 负重 各率
    type(data) == table
    data = { 支持 加/减/乘/除/等
        life = '+100',
        mana = '-100',
        life_back = '*100',
        mana_back = '/100',
        move = '=100',
    }
    during = 0.0 大于0生效；小于等于0时无限持续时间
]]
--- @private
hattribute.setHandle = function(whichUnit, attr, opr, val, dur)
    local valType = type(val)
    local params = hRuntime.attribute[whichUnit]
    if (params == nil) then
        return
    end
    if (valType == "string") then
        -- string类型只有+-=
        if (opr == "+") then
            -- 添加
            local valArr = string.explode(",", val)
            params[attr] = table.merge(params[attr], valArr)
            if (dur > 0) then
                htime.setTimeout(
                    dur,
                    function(t)
                        htime.delTimer(t)
                        hattribute.setHandle(whichUnit, attr, "-", val, 0)
                    end
                )
            end
        elseif (opr == "-") then
            -- 减少
            local valArr = string.explode(",", val)
            for _, v in ipairs(valArr) do
                if (table.includes(v, params[attr])) then
                    table.delete(v, params[attr], 1)
                end
            end
            if (dur > 0) then
                htime.setTimeout(
                    dur,
                    function(t)
                        htime.delTimer(t)
                        hattribute.setHandle(whichUnit, attr, "+", val, 0)
                    end
                )
            end
        elseif (opr == "=") then
            -- 设定
            local old = table.clone(params[attr])
            params[attr] = string.explode(",", val)
            if (dur > 0) then
                htime.setTimeout(
                    dur,
                    function(t)
                        htime.delTimer(t)
                        hattribute.setHandle(whichUnit, attr, "=", string.implode(",", old), 0)
                    end
                )
            end
        end
    elseif (valType == "table") then
        -- table类型只有+-没有别的
        if (opr == "+") then
            -- 添加
            local hkey = string.vkey(val)
            table.insert(params[attr], { hash = hkey, table = val })
            if (dur > 0) then
                htime.setTimeout(
                    dur,
                    function(t)
                        htime.delTimer(t)
                        hattribute.setHandle(whichUnit, attr, "-", val, 0)
                    end
                )
            end
        elseif (opr == "-") then
            -- 减少
            local valx = table.obj2arr(val, CONST_ATTR_BUFF_KEYS)
            local valxx = {}
            for _, xv in ipairs(valx) do
                table.insert(valxx, xv.value)
            end
            valx = nil
            local hkey = string.vkey(valxx)
            local hasKey = false
            for k, v in ipairs(params[attr]) do
                if (v.hash == hkey) then
                    table.remove(params[attr], k)
                    hasKey = true
                    break
                end
            end
            if (hasKey == true) then
                if (dur > 0) then
                    htime.setTimeout(
                        dur,
                        function(t)
                            htime.delTimer(t)
                            hattribute.setHandle(whichUnit, attr, "+", val, 0)
                        end
                    )
                end
            end
        end
    elseif (valType == "number") then
        -- number
        local intAttr = {
            "life",
            "mana",
            "move",
            "attack_white",
            "attack_green",
            "attack_range",
            "sight",
            "defend",
            "str_white",
            "agi_white",
            "int_white",
            "str_green",
            "agi_green",
            "int_green",
            "punish"
        }
        local isInt = false
        if (table.includes(attr, intAttr)) then
            isInt = true
        end
        --
        local diff = 0
        if (opr == "+") then
            diff = val
        elseif (opr == "-") then
            diff = -val
        elseif (opr == "*") then
            diff = params[attr] * val - params[attr]
        elseif (opr == "/" and val ~= 0) then
            diff = params[attr] / val - params[attr]
        elseif (opr == "=") then
            diff = val - params[attr]
        end
        local isAccumuDiff = false
        local accumuDiff = hattribute.getAccumuDiff(whichUnit, attr)
        if (diff * accumuDiff > 0) then
            isAccumuDiff = true
            diff = diff + accumuDiff
        end
        --部分属性取整处理，否则失真
        if (isInt and diff ~= 0) then
            local di, df = math.modf(math.abs(diff))
            if (isAccumuDiff) then
                if (diff >= 0) then
                    hattribute.setAccumuDiff(whichUnit, attr, df)
                else
                    hattribute.setAccumuDiff(whichUnit, attr, -df)
                end
            else
                if (diff >= 0) then
                    hattribute.addAccumuDiff(whichUnit, attr, df)
                else
                    hattribute.subAccumuDiff(whichUnit, attr, df)
                end
            end
            if (diff >= 0) then
                diff = di
            else
                diff = -di
            end
        end
        if (diff ~= 0) then
            local currentVal = params[attr]
            local futureVal = params[attr] + diff
            params[attr] = futureVal
            if (dur > 0) then
                htime.setTimeout(
                    dur,
                    function(t)
                        htime.delTimer(t)
                        hattribute.setHandle(whichUnit, attr, "-", diff, 0)
                    end
                )
            end
            -- ability
            local tempVal = 0
            local level = 0
            if (attr == "life" or attr == "mana") then
                -- 生命 | 魔法
                if (futureVal >= hattribute["max_" .. attr]) then
                    if (currentVal >= hattribute["max_" .. attr]) then
                        diff = 0
                    else
                        diff = hattribute["max_" .. attr] - currentVal
                    end
                elseif (futureVal <= hattribute["min_" .. attr]) then
                    if (currentVal <= hattribute["min_" .. attr]) then
                        diff = 0
                    else
                        diff = hattribute["min_" .. attr] - currentVal
                    end
                end
                tempVal = math.floor(math.abs(diff))
                local max = 100000000
                if (tempVal ~= 0) then
                    while (max >= 1) do
                        level = math.floor(tempVal / max)
                        tempVal = math.floor(tempVal - level * max)
                        if (diff > 0) then
                            hattribute.setLM(whichUnit, hslk_global.attr[attr].add[max], level)
                        else
                            hattribute.setLM(whichUnit, hslk_global.attr[attr].sub[max], level)
                        end
                        max = math.floor(max / 10)
                    end
                end
            elseif (attr == "move") then
                -- 移动
                if (futureVal < 0) then
                    cj.SetUnitMoveSpeed(whichUnit, 0)
                else
                    if (hcamera.getModel(hunit.getOwner(whichUnit)) == "zoomin") then
                        cj.SetUnitMoveSpeed(whichUnit, math.floor(futureVal * 0.5))
                    else
                        cj.SetUnitMoveSpeed(whichUnit, math.floor(futureVal))
                    end
                end
            elseif (attr == "attack_white") then
                -- 白字攻击
                local max = 100000000
                if (futureVal > max or futureVal < -max) then
                    diff = 0
                end
                tempVal = math.floor(math.abs(diff))
                if (tempVal ~= 0) then
                    while (max >= 1) do
                        level = math.floor(tempVal / max)
                        tempVal = math.floor(tempVal - level * max)
                        if (diff > 0) then
                            hattribute.setAttackWhite(whichUnit, hslk_global.attr.item_attack_white.add[max], level)
                        else
                            hattribute.setAttackWhite(whichUnit, hslk_global.attr.item_attack_white.sub[max], level)
                        end
                        max = math.floor(max / 10)
                    end
                end
            elseif (attr == "attack_range") then
                -- 攻击范围(仅仅是自动警示范围)
                if (futureVal < hattribute.min_attack_range) then
                    futureVal = hattribute.min_attack_range
                elseif (futureVal > hattribute.max_attack_range) then
                    futureVal = hattribute.max_attack_range
                end
                if (hcamera.getModel(hunit.getOwner(whichUnit)) == "zoomin") then
                    futureVal = futureVal * 0.5
                end
                cj.SetUnitAcquireRange(whichUnit, futureVal * 1.1)
            elseif (attr == "sight") then
                -- 视野
                for _, gradient in ipairs(hslk_global.attr.sight_gradient) do
                    cj.UnitRemoveAbility(whichUnit, hslk_global.attr.sight.add[gradient])
                    cj.UnitRemoveAbility(whichUnit, hslk_global.attr.sight.sub[gradient])
                end
                tempVal = math.floor(math.abs(futureVal))
                local sight_gradient = table.clone(hslk_global.attr.sight_gradient)
                if (tempVal ~= 0) then
                    while (true) do
                        local isFound = false
                        for _, v in ipairs(sight_gradient) do
                            if (tempVal >= v) then
                                tempVal = math.floor(tempVal - v)
                                table.delete(v, sight_gradient)
                                if (futureVal > 0) then
                                    cj.UnitAddAbility(whichUnit, hslk_global.attr.sight.add[v])
                                else
                                    cj.UnitAddAbility(whichUnit, hslk_global.attr.sight.sub[v])
                                end
                                isFound = true
                                break
                            end
                        end
                        if (isFound == false) then
                            break
                        end
                    end
                end
            elseif (table.includes(attr, { "attack_green", "attack_speed", "defend" })) then
                -- 绿字攻击 攻击速度 护甲
                if (futureVal < -99999999) then
                    futureVal = -99999999
                elseif (futureVal > 99999999) then
                    futureVal = 99999999
                end
                for _, grad in ipairs(hslk_global.attr.ablis_gradient) do
                    local ab = hslk_global.attr[attr].add[grad]
                    if (cj.GetUnitAbilityLevel(whichUnit, ab) > 1) then
                        cj.SetUnitAbilityLevel(whichUnit, ab, 1)
                    end
                    ab = hslk_global.attr[attr].sub[grad]
                    if (cj.GetUnitAbilityLevel(whichUnit, ab) > 1) then
                        cj.SetUnitAbilityLevel(whichUnit, ab, 1)
                    end
                end
                tempVal = math.floor(math.abs(futureVal))
                local max = 100000000
                if (tempVal ~= 0) then
                    while (max >= 1) do
                        level = math.floor(tempVal / max)
                        tempVal = math.floor(tempVal - level * max)
                        if (futureVal > 0) then
                            if (cj.GetUnitAbilityLevel(whichUnit, hslk_global.attr[attr].add[max]) < 1) then
                                cj.UnitAddAbility(whichUnit, hslk_global.attr[attr].add[max])
                            end
                            cj.SetUnitAbilityLevel(whichUnit, hslk_global.attr[attr].add[max], level + 1)
                        else
                            if (cj.GetUnitAbilityLevel(whichUnit, hslk_global.attr[attr].sub[max]) < 1) then
                                cj.UnitAddAbility(whichUnit, hslk_global.attr[attr].sub[max])
                            end
                            cj.SetUnitAbilityLevel(whichUnit, hslk_global.attr[attr].sub[max], level + 1)
                        end
                        max = math.floor(max / 10)
                    end
                end
            elseif (his.hero(whichUnit) and table.includes(attr, { "str_green", "agi_green", "int_green" })) then
                -- 绿字力量 绿字敏捷 绿字智力
                if (futureVal < -99999999) then
                    futureVal = -99999999
                elseif (futureVal > 99999999) then
                    futureVal = 99999999
                end
                for _, grad in ipairs(hslk_global.attr.ablis_gradient) do
                    local ab = hslk_global.attr[attr].add[grad]
                    if (cj.GetUnitAbilityLevel(whichUnit, ab) > 1) then
                        cj.SetUnitAbilityLevel(whichUnit, ab, 1)
                    end
                    ab = hslk_global.attr[attr].sub[grad]
                    if (cj.GetUnitAbilityLevel(whichUnit, ab) > 1) then
                        cj.SetUnitAbilityLevel(whichUnit, ab, 1)
                    end
                end
                tempVal = math.floor(math.abs(futureVal))
                local max = 100000000
                if (tempVal ~= 0) then
                    while (max >= 1) do
                        level = math.floor(tempVal / max)
                        tempVal = math.floor(tempVal - level * max)
                        if (futureVal > 0) then
                            if (cj.GetUnitAbilityLevel(whichUnit, hslk_global.attr[attr].add[max]) < 1) then
                                cj.UnitAddAbility(whichUnit, hslk_global.attr[attr].add[max])
                            end
                            cj.SetUnitAbilityLevel(whichUnit, hslk_global.attr[attr].add[max], level + 1)
                        else
                            if (cj.GetUnitAbilityLevel(whichUnit, hslk_global.attr[attr].sub[max]) < 1) then
                                cj.UnitAddAbility(whichUnit, hslk_global.attr[attr].sub[max])
                            end
                            cj.SetUnitAbilityLevel(whichUnit, hslk_global.attr[attr].sub[max], level + 1)
                        end
                        max = math.floor(max / 10)
                    end
                end
                local subAttr = string.gsub(attr, "_green", "")
                -- 主属性影响(<= 0自动忽略)
                if (hattribute.threeBuff.primary > 0) then
                    if (string.upper(subAttr) == hhero.getPrimary(whichUnit)) then
                        hattribute.set(whichUnit, 0, { attack_white = "+" .. diff * hattribute.threeBuff.primary })
                    end
                end
                -- 三围影响
                local three = table.obj2arr(hattribute.threeBuff[subAttr], CONST_ATTR_KEYS)
                for _, d in ipairs(three) do
                    local tempV = diff * d.value
                    if (tempV < 0) then
                        hattribute.set(whichUnit, 0, { [d.key] = "-" .. math.abs(tempV) })
                    elseif (tempV > 0) then
                        hattribute.set(whichUnit, 0, { [d.key] = "+" .. tempV })
                    end
                end
            elseif (his.hero(whichUnit) and table.includes(attr, { "str_white", "agi_white", "int_white" })) then
                -- 白字力量 敏捷 智力
                if (attr == "str_white") then
                    cj.SetHeroStr(whichUnit, math.floor(futureVal), true)
                elseif (attr == "agi_white") then
                    cj.SetHeroAgi(whichUnit, math.floor(futureVal), true)
                elseif (attr == "int_white") then
                    cj.SetHeroInt(whichUnit, math.floor(futureVal), true)
                end
                local subAttr = string.gsub(attr, "_white", "")
                -- 主属性影响(<= 0自动忽略)
                if (hattribute.threeBuff.primary > 0) then
                    if (string.upper(subAttr) == hhero.getPrimary(whichUnit)) then
                        hattribute.set(whichUnit, 0, { attack_white = "+" .. diff * hattribute.threeBuff.primary })
                    end
                end
                -- 三围影响
                local three = table.obj2arr(hattribute.threeBuff[subAttr], CONST_ATTR_KEYS)
                for _, d in ipairs(three) do
                    local tempV = diff * d.value
                    if (tempV < 0) then
                        hattribute.set(whichUnit, 0, { [d.key] = "-" .. math.abs(tempV) })
                    elseif (tempV > 0) then
                        hattribute.set(whichUnit, 0, { [d.key] = "+" .. tempV })
                    end
                end
            elseif (attr == "life_back" or attr == "mana_back") then
                -- 生命,魔法恢复
                if (math.abs(futureVal) > 0.02 and table.includes(whichUnit, hRuntime.attributeGroup[attr]) == false) then
                    table.insert(hRuntime.attributeGroup[attr], whichUnit)
                elseif (math.abs(futureVal) < 0.02) then
                    table.delete(whichUnit, hRuntime.attributeGroup[attr])
                end
            elseif (attr == "punish" and hunit.isOpenPunish(whichUnit)) then
                -- 硬直
                if (currentVal > 0) then
                    local tempPercent = futureVal / currentVal
                    hRuntime.attribute[whichUnit].punish_current = tempPercent * hRuntime.attribute[whichUnit].punish_current
                else
                    hRuntime.attribute[whichUnit].punish_current = futureVal
                end
            elseif (attr == "punish_current" and hunit.isOpenPunish(whichUnit)) then
                -- 硬直(current)
                if (futureVal > hRuntime.attribute[whichUnit].punish) then
                    hRuntime.attribute[whichUnit].punish_current = hRuntime.attribute[whichUnit].punish
                elseif (futureVal <= 0) then
                    hRuntime.attribute[whichUnit].punish_current = hRuntime.attribute[whichUnit].punish
                end
            end
        end
    end
end

--- 设置单位属性
---@param whichUnit userdata
---@param during number 0表示无限
---@param data any
hattribute.set = function(whichUnit, during, data)
    if (whichUnit == nil) then
        -- 例如有时造成伤害之前把单位删除就捕捉不到这个伤害来源了
        -- 虽然这里直接返回不执行即可，但是提示下可以帮助完善业务的构成~
        print_stack("whichUnit is nil")
        return
    end
    if (hRuntime.attribute[whichUnit] == nil) then
        if (hattribute.init(whichUnit) == false) then
            return
        end
    end
    -- 处理data
    if (type(data) ~= "table") then
        print_err("data must be table")
        return
    end
    for _, arr in ipairs(table.obj2arr(data, CONST_ATTR_KEYS)) do
        local attr = arr.key
        local v = arr.value
        if (hRuntime.attribute[whichUnit] ~= nil and hRuntime.attribute[whichUnit][attr] ~= nil) then
            if (type(v) == "string") then
                local opr = string.sub(v, 1, 1)
                v = string.sub(v, 2, string.len(v))
                local val = tonumber(v)
                if (val == nil) then
                    val = v
                end
                hattribute.setHandle(whichUnit, attr, opr, val, during)
            elseif (type(v) == "table") then
                -- table型，如特效，buff等
                if (v.add ~= nil and type(v.add) == "table") then
                    for _, buff in ipairs(v.add) do
                        if (buff == nil) then
                            print_err("table effect loss[buff]!")
                            print_stack()
                            break
                        end
                        if (type(buff) ~= "table") then
                            print_err("add type(buff) must be a table!")
                            print_stack()
                            break
                        end
                        hattribute.setHandle(whichUnit, attr, "+", buff, during)
                    end
                elseif (v.sub ~= nil and type(v.sub) == "table") then
                    for _, buff in ipairs(v.sub) do
                        if (buff == nil) then
                            print_err("table effect loss[buff]!")
                            print_stack()
                            break
                        end
                        if (type(buff) ~= "table") then
                            print_err("sub type(buff) must be a table!")
                            print_stack()
                            break
                        end
                        hattribute.setHandle(whichUnit, attr, "-", buff, during)
                    end
                end
            end
        end
    end
end

--- 通用get
---@param whichUnit userdata
---@param attr string
---@return any
hattribute.get = function(whichUnit, attr)
    if (whichUnit == nil) then
        return nil
    end
    if (hRuntime.attribute[whichUnit] == nil) then
        if (hattribute.init(whichUnit) == false) then
            return nil
        end
    end
    if (attr == nil) then
        return hRuntime.attribute[whichUnit]
    end
    return hRuntime.attribute[whichUnit][attr]
end

--- 重置注册
---@private
hattribute.reRegister = function(whichUnit)
    local life = hRuntime.attribute[whichUnit].life
    local mana = hRuntime.attribute[whichUnit].mana
    local move = hRuntime.attribute[whichUnit].move
    local strGreen = hRuntime.attribute[whichUnit].str_green
    local agiGreen = hRuntime.attribute[whichUnit].agi_green
    local intGreen = hRuntime.attribute[whichUnit].int_green
    local strWhite = hRuntime.attribute[whichUnit].str_white
    local agiWhite = hRuntime.attribute[whichUnit].agi_white
    local intWhite = hRuntime.attribute[whichUnit].int_white
    local attackWhite = hRuntime.attribute[whichUnit].attack_white
    local attackGreen = hRuntime.attribute[whichUnit].attack_green
    local attackSpeed = hRuntime.attribute[whichUnit].attack_speed
    local defend = hRuntime.attribute[whichUnit].defend
    -- 注册技能
    if (hattribute.init(whichUnit) == false) then
        return
    end
    -- 弥补属性
    cj.SetHeroStr(whichUnit, cj.R2I(strWhite), true)
    cj.SetHeroAgi(whichUnit, cj.R2I(agiWhite), true)
    cj.SetHeroInt(whichUnit, cj.R2I(intWhite), true)
    if (move < 0) then
        cj.SetUnitMoveSpeed(whichUnit, 0)
    else
        if (hcamera.model == "zoomin") then
            cj.SetUnitMoveSpeed(whichUnit, cj.R2I(move * 0.5))
        else
            cj.SetUnitMoveSpeed(whichUnit, cj.R2I(move))
        end
    end
    hRuntime.attribute[whichUnit].life = cj.GetUnitState(whichUnit, UNIT_STATE_MAX_LIFE)
    hRuntime.attribute[whichUnit].mana = cj.GetUnitState(whichUnit, UNIT_STATE_MAX_MANA)
    hRuntime.attribute[whichUnit].defend = hslk_global.id2Value.unit[hunit.getId(whichUnit)].def or 0.0
    hRuntime.attribute[whichUnit].attack_speed = 0
    hRuntime.attribute[whichUnit].attack_white = 0
    hRuntime.attribute[whichUnit].attack_green = 0
    hRuntime.attribute[whichUnit].str_green = 0
    hRuntime.attribute[whichUnit].agi_green = 0
    hRuntime.attribute[whichUnit].int_green = 0
    hattribute.set(
        whichUnit,
        0,
        {
            life = "+" .. (life - cj.GetUnitState(whichUnit, UNIT_STATE_MAX_LIFE)),
            mana = "+" .. (mana - cj.GetUnitState(whichUnit, UNIT_STATE_MAX_LIFE)),
            str_green = "+" .. strGreen,
            agi_green = "+" .. agiGreen,
            int_green = "+" .. intGreen,
            attack_white = "+" .. attackWhite,
            attack_green = "+" .. attackGreen,
            attack_speed = "+" .. attackSpeed,
            defend = "+" .. defend
        }
    )
end
