-- 物品系统

--[[
    每个英雄最大支持使用6件物品
    支持满背包合成
    物品存在重量，背包有负重，超过负重即使存在合成关系，也会被暂时禁止合成
]]
hitem = {
    DEFAULT_SKILL_ITEM_SLOT = string.char2id("AInv"), -- 默认物品栏技能（英雄6格那个）默认全部认定这个技能为物品栏，如有需要自行更改
    DEFAULT_SKILL_ITEM_SEPARATE = hslk_global.skill_item_separate, -- 默认拆分物品技能
    POSITION_TYPE = {
        --物品位置类型
        COORDINATE = "coordinate", --坐标
        UNIT = "unit" --单位
    },
    FLEETING_IDS = {
        GOLD = hslk_global.item_fleeting[1], -- 默认金币（模型）
        LUMBER = hslk_global.item_fleeting[2], -- 默认木头
        BOOK_YELLOW = hslk_global.item_fleeting[3], -- 技能书系列
        BOOK_GREEN = hslk_global.item_fleeting[4],
        BOOK_PURPLE = hslk_global.item_fleeting[5],
        BOOK_BLUE = hslk_global.item_fleeting[6],
        BOOK_RED = hslk_global.item_fleeting[7],
        RUNE = hslk_global.item_fleeting[8], -- 神符（紫色符文）
        RELIEF = hslk_global.item_fleeting[9], -- 浮雕（橙色像块炭）
        EGG = hslk_global.item_fleeting[10], -- 蛋
        FRAGMENT = hslk_global.item_fleeting[11], -- 碎片（蓝色石头）
        QUESTION = hslk_global.item_fleeting[12], -- 问号
        GRASS = hslk_global.item_fleeting[13], -- 荧光草
        DOTA2_GOLD = hslk_global.item_fleeting[14], -- Dota2赏金符
        DOTA2_DAMAGE = hslk_global.item_fleeting[15], -- Dota2伤害符
        DOTA2_CURE = hslk_global.item_fleeting[16], -- Dota2恢复符
        DOTA2_SPEED = hslk_global.item_fleeting[17], -- Dota2极速符
        DOTA2_VISION = hslk_global.item_fleeting[18], -- Dota2幻象符
        DOTA2_INVISIBLE = hslk_global.item_fleeting[19], -- Dota2隐身符
    },
    -- 全局使用注册
    MATCH_ITEM_USED = {},
}

-- 单位注册物品
---@protected
hitem.register = function(u)
    if (hRuntime.unit[u] == nil) then
        -- 未注册unit直接跳过
        return
    end
    -- 拾取
    hevent.pool(u, hevent_default_actions.item.pickup, function(tgr)
        cj.TriggerRegisterUnitEvent(tgr, u, EVENT_UNIT_PICKUP_ITEM)
    end)
    -- 丢弃
    hevent.pool(u, hevent_default_actions.item.drop, function(tgr)
        cj.TriggerRegisterUnitEvent(tgr, u, EVENT_UNIT_DROP_ITEM)
    end)
    -- 抵押
    hevent.pool(u, hevent_default_actions.item.pawn, function(tgr)
        cj.TriggerRegisterUnitEvent(tgr, u, EVENT_UNIT_PAWN_ITEM)
    end)
    -- 使用
    hevent.pool(u, hevent_default_actions.item.use, function(tgr)
        cj.TriggerRegisterUnitEvent(tgr, u, EVENT_UNIT_USE_ITEM)
    end)
end

--- 令单位的物品在runtime内存中释放
---@protected
hitem.clearUnitCache = function(whichUnit)
    if (hRuntime.unit[whichUnit] ~= nil) then
        for i = 0, 5, 1 do
            local it = cj.UnitItemInSlot(whichUnit, i)
            if (it ~= nil) then
                hRuntime.clear(it)
            end
        end
    end
end

--- 注册一些物品的方法，在物品被使用时自动回调
--- 可以简化onItemUsed的使用，协助管理物品
--- 适用于大众物品调用,支持正则匹配
--- evtData 同 hevent.onItemUsed
---@param options table
hitem.matchUsed = function(options)
    --[[
        options = {
            {"匹配的物品名1", function(evtData) end},
            {"匹配的物品名2", function(evtData) end},
            ...
        }
    ]]
    if (#options <= 0) then
        return
    end
    for _, v in ipairs(options) do
        if (type(v[1]) == "string" and type(v[2]) == "function") then
            table.insert(hitem.MATCH_ITEM_USED, v)
        end
    end
end

--- 删除物品，可延时
---@param it userdata
---@param delay number
hitem.del = function(it, delay)
    delay = delay or 0
    if (delay <= 0 and it ~= nil) then
        hitem.setPositionType(it, nil)
        cj.SetWidgetLife(it, 1.00)
        cj.RemoveItem(it)
        hRuntime.clear(it)
    else
        htime.setTimeout(
            delay,
            function(t)
                htime.delTimer(t)
                hitem.setPositionType(it, nil)
                hRuntime.clear(it)
                cj.SetWidgetLife(it, 1.00)
                cj.RemoveItem(it)
            end
        )
    end
end

--- 获取物品ID字符串
---@param it userdata
---@return string
hitem.getId = function(it)
    return string.id2char(cj.GetItemTypeId(it))
end

--- 获取物品名称
---@param it userdata
---@return string
hitem.getName = function(it)
    return cj.GetItemName(it)
end

-- 获取物品位置类型
---@param it userdata
---@return string
hitem.getPositionType = function(it)
    if (hRuntime.item[it] == nil) then
        return
    end
    return hRuntime.item[it].positionType
end

-- 设置物品位置类型
---@param it userdata
---@param type string
hitem.setPositionType = function(it, type)
    if (type == nil) then
        table.delete(it, hRuntime.itemPickPool)
        return
    end
    if (hRuntime.item[it] == nil) then
        hRuntime.item[it] = {}
    end
    hRuntime.item[it].positionType = type
    --如果位置是在坐标轴上，将物品加入拾取池
    if (type == hitem.POSITION_TYPE.COORDINATE) then
        table.insert(hRuntime.itemPickPool, it)
    end
end

--- 获取物品SLK数据集,需要注册
---@param itOrId userdata|string|number
---@return any
hitem.getSlk = function(itOrId)
    local slk
    local itId
    if (itOrId == nil) then
        return
    end
    if (type(itOrId) == "string") then
        itId = itOrId
    elseif (type(itOrId) == "number") then
        itId = string.id2char(itOrId)
    else
        itId = hitem.getId(itOrId)
    end
    if (hslk_global.id2Value.item[itId] ~= nil) then
        slk = hslk_global.id2Value.item[itId]
    end
    return slk
end
-- 获取物品的图标路径,需要注册
---@param itOrId userdata|string|number
---@return string
hitem.getArt = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.Art
    else
        return ""
    end
end
--- 获取物品的模型路径,需要注册
---@param itOrId userdata|string|number
---@return string
hitem.getFile = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.file
    else
        return ""
    end
end
--- 获取物品的分类,需要注册
---@param itOrId userdata|string|number
---@return string
hitem.getClass = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.class
    else
        return "Permanent"
    end
end
--- 获取物品所需的金币,需要注册
---@param itOrId userdata|string|number
---@return number
hitem.getGoldCost = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return math.floor(slk.goldcost)
    else
        return 0
    end
end
--- 获取物品所需的木头,需要注册
---@param itOrId userdata|string|number
---@return number
hitem.getLumberCost = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return math.floor(slk.lumbercost)
    else
        return 0
    end
end
--- 获取物品是否可以使用,需要注册
---@param itOrId userdata|string|number
---@return boolean
hitem.getIsUsable = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.usable == 1
    else
        return false
    end
end
--- 获取物品是否自动使用,需要注册
---@param itOrId userdata|string|number
---@return boolean
hitem.getIsPowerUp = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.powerup == 1
    else
        return false
    end
end
--- 获取物品是否使用后自动消失,需要注册
---@param itOrId userdata|string|number
---@return boolean
hitem.getIsPerishable = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.perishable == 1
    else
        return nil
    end
end
--- 获取物品是否可卖,需要注册
---@param itOrId userdata|string|number
---@return boolean
hitem.getIsSellAble = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.sellable == 1
    else
        return false
    end
end
--- 获取物品的(表面/影子)ID（实现神符满格购物的关键，会自动获得相对ID）,需要注册
---@param itOrId userdata|string|number
---@return string
hitem.getShadowMappingId = function(itOrId)
    local itId
    if (type(itOrId == "string")) then
        itId = itOrId
    else
        itId = hitem.getId(itOrId)
    end
    return hslk_global.items_shadow_mapping[itId]
end
--- 获取物品的最大叠加数(默认是1个,此系统以使用次数作为数量使用),需要注册
---@param itOrId userdata|string|number
---@return number
hitem.getOverlie = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.OVERLIE or 1
    else
        return 1
    end
end
--- 获取物品的重量（默认为0）,需要注册
---@param itOrId userdata|string|number
---@return number
hitem.getWeight = function(itOrId, charges)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        if (charges == nil and type(itOrId) == "userdata") then
            -- 如果没有传次数，这里会直接获取物品的次数，请注意
            charges = hitem.getCharges(itOrId)
        end
        return (slk.WEIGHT or 0) * charges
    else
        return 0
    end
end
--- 获取物品的属性加成,需要注册
---@param itOrId userdata|string|number
---@return table
hitem.getAttribute = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.ATTR or {}
    else
        return {}
    end
end

--- 获取物品的SLK自定义数据CUSTOM_DATA
---@param itOrId any
---@return table
hitem.getCustomData = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.CUSTOM_DATA or {}
    else
        return {}
    end
end

--- 获取物品的等级
---@param it userdata
---@return number
hitem.getLevel = function(it)
    if (it ~= nil) then
        return cj.GetItemLevel(it)
    end
    return 0
end

--- 获取物品的使用次数
---@param it userdata
---@return number
hitem.getCharges = function(it)
    if (it ~= nil) then
        return cj.GetItemCharges(it)
    else
        return 0
    end
end
--- 设置物品的使用次数
---@param it userdata
---@param charges number
hitem.setCharges = function(it, charges)
    if (it ~= nil and charges > 0) then
        cj.SetItemCharges(it, charges)
    end
end

--- 获取某单位身上某种物品的使用总次数
---@param itemId string|number
---@param whichUnit userdata
---@return number
hitem.getTotalCharges = function(itemId, whichUnit)
    local charges = 0
    local it
    if (type(itemId) == "string") then
        itemId = string.char2id(itemId)
    end
    for i = 0, 5, 1 do
        it = cj.UnitItemInSlot(whichUnit, i)
        if (it ~= nil and cj.GetItemTypeId(it) == itemId) then
            charges = charges + hitem.getCharges(it)
        end
    end
    return charges
end

--- 获取某单位身上空格物品栏数量
---@param whichUnit userdata
---@return number
hitem.getEmptySlot = function(whichUnit)
    local qty = cj.UnitInventorySize(whichUnit)
    local it
    for i = 0, 5, 1 do
        it = cj.UnitItemInSlot(whichUnit, i)
        if (it ~= nil) then
            qty = qty - 1
        end
    end
    return qty
end

--- 循环获取某单位6格物品
---@alias SlotLoop fun(enumUnit: userdata):void
---@param whichUnit userdata
---@param action SlotLoop | "function(slotItem, slotIndex) end"
---@return number
hitem.slotLoop = function(whichUnit, action)
    local it
    for i = 0, 5, 1 do
        it = cj.UnitItemInSlot(whichUnit, i)
        action(it, i)
    end
end

--- 使得单位拥有拆分物品的技能
---@param whichUnit userdata
hitem.setAllowSeparate = function(whichUnit)
    -- 物品拆分
    cj.UnitAddAbility(whichUnit, hitem.DEFAULT_SKILL_ITEM_SEPARATE)
    cj.UnitMakeAbilityPermanent(whichUnit, true, hitem.DEFAULT_SKILL_ITEM_SEPARATE)
    cj.SetUnitAbilityLevel(whichUnit, hitem.DEFAULT_SKILL_ITEM_SEPARATE, 1)
    -- 事件池注册
    hevent.pool(whichUnit, hevent_default_actions.item.separate, function(tgr)
        cj.TriggerRegisterUnitEvent(tgr, whichUnit, EVENT_UNIT_SPELL_EFFECT)
    end)
end

--- 计算单位得失物品的属性影响
---@private
hitem.caleAttribute = function(isAdd, whichUnit, itId, charges)
    if (isAdd == nil) then
        isAdd = true
    end
    charges = charges or 1
    local weight = hitem.getWeight(itId, charges)
    local attr = hitem.getAttribute(itId)
    local diff = {}
    local diffPlayer = {}
    for _, arr in ipairs(table.obj2arr(attr, CONST_ATTR_KEYS)) do
        local k = arr.key
        local v = arr.value
        local typev = type(v)
        local tempDiff
        if (k == "attack_damage_type") then
            local opt = "+"
            if (isAdd == false) then
                opt = "-"
            end
            local nv
            if (typev == "string") then
                opt = string.sub(v, 1, 1) or "+"
                nv = string.sub(v, 2)
            elseif (typev == "table") then
                nv = string.implode(",", v)
            end
            local nvs = {}
            for _ = 1, charges do
                table.insert(nvs, nv)
            end
            tempDiff = opt .. string.implode(",", nvs)
        elseif (typev == "string") then
            local opt = string.sub(v, 1, 1)
            local nv = charges * tonumber(string.sub(v, 2))
            if (isAdd == false) then
                if (opt == "+") then
                    opt = "-"
                else
                    opt = "+"
                end
            end
            tempDiff = opt .. nv
        elseif (typev == "number") then
            if ((v > 0 and isAdd == true) or (v < 0 and isAdd == false)) then
                tempDiff = "+" .. (v * charges)
            elseif (v < 0) then
                tempDiff = "-" .. (v * charges)
            end
        elseif (typev == "table") then
            local tempTable = {}
            for _ = 1, charges do
                for _, vv in ipairs(v) do
                    table.insert(tempTable, vv)
                end
            end
            local opt = "add"
            if (isAdd == false) then
                opt = "sub"
            end
            tempDiff = {
                [opt] = tempTable
            }
        end
        if
        (table.includes(
            k,
            {
                "gold_ratio",
                "lumber_ratio",
                "exp_ratio",
                "sell_ratio"
            }
        ))
        then
            table.insert(diffPlayer, { k, tonumber(tempDiff) })
        else
            diff[k] = tempDiff
        end
    end
    if (weight ~= 0) then
        local opt = "+"
        if (isAdd == false) then
            opt = "-"
        end
        diff.weight_current = opt .. weight
    end
    hattr.set(whichUnit, 0, diff)
    if (#diffPlayer > 0) then
        local p = hunit.getOwner(whichUnit)
        for _, dp in ipairs(diffPlayer) do
            local pk = dp[1]
            local pv = dp[2]
            if (pv ~= 0) then
                if (pk == "gold_ratio") then
                    hplayer.addGoldRatio(p, pv, 0)
                elseif (pk == "lumber_ratio") then
                    hplayer.addLumberRatio(p, pv, 0)
                elseif (pk == "exp_ratio") then
                    hplayer.addExpRatio(p, pv, 0)
                elseif (pk == "sell_ratio") then
                    hplayer.addSellRatio(p, pv, 0)
                end
            end
        end
    end
end
--- 附加单位获得物品后的属性
---@protected
hitem.addAttribute = function(whichUnit, itId, charges)
    hitem.caleAttribute(true, whichUnit, itId, charges)
end
--- 削减单位获得物品后的属性
---@protected
hitem.subAttribute = function(whichUnit, itId, charges)
    hitem.caleAttribute(false, whichUnit, itId, charges)
end

--[[
 1 检查单位的负重是否可以承受新的物品
 2 可以承受的话，物品是否有叠加，不能叠加检查是否还有多余的格子
 3 物品数量是否支持合成
 4 根据情况执行原物品叠加、合成等操作
]]
---@private
hitem.detector = function(whichUnit, it)
    if (whichUnit == nil or it == nil) then
        print_err("detector params nil")
    end
    local newWeight = hattr.get(whichUnit, "weight_current") + hitem.getWeight(it)
    if (newWeight > hattr.get(whichUnit, "weight")) then
        local exWeight = newWeight - hattr.get(whichUnit, "weight")
        htextTag.style(
            htextTag.create2Unit(whichUnit, "负重超出" .. exWeight .. "kg", 8.00, "ffffff", 1, 1.1, 50.00),
            "scale",
            0,
            0.05
        )
        -- 触发超重事件
        hevent.triggerEvent(
            whichUnit,
            CONST_EVENT.itemOverWeight,
            {
                triggerUnit = whichUnit,
                triggerItem = it,
                value = exWeight
            }
        )
        hitem.setPositionType(it, hitem.POSITION_TYPE.COORDINATE)
        return false
    end
    local overlie = hitem.getOverlie(it)
    local isFullSlot = false
    if (overlie > 1) then
        local isOverlieOver = false
        -- 可能可叠加的情况，先检查单位的各个物品是否还有叠加空位
        local tempIt
        local currentItId = cj.GetItemTypeId(it)
        local currentCharges = hitem.getCharges(it)
        for si = 0, 5, 1 do
            tempIt = cj.UnitItemInSlot(whichUnit, si)
            if (tempIt ~= nil and currentItId == cj.GetItemTypeId(tempIt)) then
                -- 如果第i格物品和获得的一致
                -- 如果有极限值,并且原有的物品未达上限
                local tempCharges = hitem.getCharges(tempIt)
                if (tempCharges < overlie) then
                    if ((currentCharges + tempCharges) <= overlie) then
                        -- 条件：如果旧物品足以容纳所有的新物品个数
                        -- 使旧物品使用次数增加，新物品删掉
                        cj.SetItemCharges(tempIt, currentCharges + tempCharges)
                        hitem.del(it, 0)
                        isOverlieOver = true
                        hitem.addAttribute(whichUnit, currentItId, currentCharges)
                        break
                    else
                        -- 否则，如果使用次数大于极限值,旧物品次数满载，新物品数量减少
                        cj.SetItemCharges(tempIt, overlie)
                        cj.SetItemCharges(it, currentCharges - (overlie - tempCharges))
                        hitem.addAttribute(whichUnit, currentItId, overlie - tempCharges)
                    end
                end
            end
        end
        -- 如果叠加已经全部消化，这里就把物品it设置为null
        if (isOverlieOver == true) then
            it = nil
        end
    end
    -- 如果物品还在~~
    if (it ~= nil) then
        -- 检查物品是否自动使用，不做处理（这种情况不应该存在，一般不会为自动物品构建shadow）
        if (hitem.getIsPowerUp(it) == true) then
            return true
        end
        -- 检查身上是否还有格子
        if (hitem.getEmptySlot(whichUnit) > 0) then
            -- 都满足了，把物品给单位
            hitem.setPositionType(it, hitem.POSITION_TYPE.UNIT)
            cj.UnitAddItem(whichUnit, it)
            -- 触发获得物品
            hevent.triggerEvent(
                whichUnit,
                CONST_EVENT.itemGet,
                {
                    triggerUnit = whichUnit,
                    triggerItem = it
                }
            )
            local currentItId = cj.GetItemTypeId(it)
            local currentCharges = hitem.getCharges(it)
            hitem.addAttribute(whichUnit, currentItId, currentCharges)
            it = nil
        else
            isFullSlot = true
        end
    end
    if (isFullSlot == true) then
        -- todo 满格了，检查是否可以合成（合成就相当于跳过了满格，所以之前的满格是个标志位，等待合成无效才会触发满格事件）
        if (false) then
            -- 7物品合成检测，如果真的有合成，把满格的标志位设置为false
            isFullSlot = false
        end
    else
        -- todo 没有满格，也检查身上的物品是否可以合成
        if (false) then
            -- 6物品合成检测
        end
    end
    if (isFullSlot) then
        --触发满格事件
        hevent.triggerEvent(
            whichUnit,
            CONST_EVENT.itemOverWeight,
            {
                triggerUnit = whichUnit,
                triggerItem = it
            }
        )
        hitem.setPositionType(it, hitem.POSITION_TYPE.COORDINATE)
        return false
    end
    return true
end

--[[
    创建物品
    bean = {
        itemId = 'I001', --物品ID
        charges = 1, --物品可使用次数（可选，默认为1）
        whichUnit = nil, --哪个单位（可选）
        whichUnitPosition = nil, --哪个单位的位置（可选，填单位）
        x = nil, --哪个坐标X（可选）
        y = nil, --哪个坐标Y（可选）
        whichLoc = nil, --哪个点（可选，不推荐）
        during = 0, --持续时间（可选，创建给单位要注意powerUp物品的问题）
        slotIndex = 0-5, -- 如果创建给单位，可以同时设置物品栏的位置（可选）
    }
    !单位模式下，during持续时间是无效的
]]
hitem.create = function(bean)
    if (bean.itemId == nil) then
        print_err("hitem create -it-id")
        return
    end
    if (bean.charges == nil) then
        bean.charges = 1
    end
    if (bean.charges < 1) then
        return
    end
    local charges = bean.charges
    local during = bean.during or 0
    if (type(bean.itemId) == "string") then
        bean.itemId = string.char2id(bean.itemId)
    end
    -- 优先级 坐标 > 单位 > 点
    local it
    local type
    if (bean.x ~= nil and bean.y ~= nil) then
        it = cj.CreateItem(bean.itemId, bean.x, bean.y)
        type = hitem.POSITION_TYPE.COORDINATE
    elseif (bean.whichUnitPosition ~= nil) then
        it = cj.CreateItem(bean.itemId, hunit.x(bean.whichUnit), hunit.y(bean.whichUnit))
        type = hitem.POSITION_TYPE.COORDINATE
    elseif (bean.whichUnit ~= nil) then
        it = cj.CreateItem(bean.itemId, hunit.x(bean.whichUnit), hunit.y(bean.whichUnit))
        type = hitem.POSITION_TYPE.UNIT
    elseif (bean.whichLoc ~= nil) then
        it = cj.CreateItem(bean.itemId, cj.GetLocationX(bean.whichLoc), cj.GetLocationY(bean.whichLoc))
        type = hitem.POSITION_TYPE.COORDINATE
    else
        print_err("hitem create -site")
        return
    end
    cj.SetItemCharges(it, charges)
    hRuntime.item[it] = {
        name = hitem.getName(it),
        itemId = bean.itemId,
        during = bean.during
    }
    hitem.setPositionType(it, type)
    if (type == hitem.POSITION_TYPE.UNIT) then
        hitem.detector(bean.whichUnit, it)
        if (bean.slotIndex ~= nil and bean.slotIndex >= 0 and bean.slotIndex <= 5) then
            cj.UnitDropItemSlot(bean.whichUnit, it, bean.slotIndex)
        end
    else
        if (during > 0) then
            htime.setTimeout(
                during,
                function(t)
                    htime.delTimer(t)
                    hitem.del(it, 0)
                end
            )
        end
    end
    return it
end

--- 创建[瞬逝物]物品
--- 是以单位模拟的物品，进入范围瞬间消失并生效
--- 可以增加玩家的反馈刺激感
--- [type]金币,木材,黄色书,绿色书,紫色书,蓝色书,红色书,神符,浮雕,蛋",碎片,问号,荧光草Dota2赏金符,Dota2伤害符,Dota2恢复符,Dota2极速符,Dota2幻象符,Dota2隐身符
---@param fleetingType number hitem.FLEETING_IDS[n]
---@param x number 坐标X
---@param y number 坐标Y
---@param during number 持续时间（可选，默认30秒）
---@param yourFunc onEnterUnitRange | "function(evtData) end"
---@return userdata item-unit
hitem.fleeting = function(fleetingType, x, y, during, yourFunc)
    if (fleetingType == nil) then
        print_err("hitem fleeting -type")
        return
    end
    if (x == nil or y == nil) then
        return
    end
    during = during or 30
    if (during < 0) then
        return
    end
    local it = hunit.create({
        register = false,
        whichPlayer = hplayer.player_passive,
        unitId = fleetingType,
        x = x,
        y = y,
        during = during,
    })
    if (type(yourFunc) == "function") then
        hevent.onEnterUnitRange(it, 127, yourFunc)
    end
    return it
end

--- 使一个单位的所有物品给另一个单位
---@param origin userdata
---@param target userdata
hitem.give = function(origin, target)
    if (origin == nil or target == nil) then
        return
    end
    for i = 0, 5, 1 do
        local it = cj.UnitItemInSlot(origin, i)
        if (it ~= nil) then
            hitem.create(
                {
                    itemId = hitem.getId(it),
                    charges = hitem.getCharges(it),
                    whichUnit = target
                }
            )
        end
        hitem.del(it, 0)
    end
end

--- 操作物品给一个单位
---@param it userdata
---@param targetUnit userdata
hitem.pick = function(it, targetUnit)
    if (it == nil or targetUnit == nil) then
        return
    end
    cj.UnitAddItem(targetUnit, it)
end

--- 复制一个单位的所有物品给另一个单位
---@param origin userdata
---@param target userdata
hitem.copy = function(origin, target)
    if (origin == nil or target == nil) then
        return
    end
    for i = 0, 5, 1 do
        local it = cj.UnitItemInSlot(origin, i)
        if (it ~= nil) then
            hitem.create(
                {
                    itemId = hitem.getId(it),
                    charges = hitem.getCharges(it),
                    whichUnit = target,
                    slotIndex = i
                }
            )
        end
    end
end

--- 令一个单位把物品全部仍在地上
---@param origin userdata
hitem.drop = function(origin)
    if (origin == nil) then
        return
    end
    for i = 0, 5, 1 do
        local it = cj.nitItemInSlot(origin, i)
        if (it ~= nil) then
            hitem.create(
                {
                    itemId = hitem.getId(it),
                    charges = hitem.getCharges(it),
                    x = hunit.x(origin),
                    x = hunit.y(origin)
                }
            )
            htime.del(it, 0)
        end
    end
end

--- 一键拾取区域(x,y)长宽(w,h)
---@param u userdata
---@param x number
---@param y number
---@param w number
---@param h number
hitem.pickRect = function(u, x, y, w, h)
    for k = #hRuntime.itemPickPool, 1, -1 do
        local xi = cj.GetItemX(hRuntime.itemPickPool[k])
        local yi = cj.GetItemY(hRuntime.itemPickPool[k])
        if (hitem.getEmptySlot(u) > 0) then
            local d = math.getDistanceBetweenXY(x, y, xi, yi)
            local deg = math.getDegBetweenXY(x, y, xi, yi)
            local distance = math.getMaxDistanceInRect(w, h, deg)
            if (d <= distance) then
                hitem.pick(hRuntime.itemPickPool[k], u)
            end
        else
            break
        end
    end
end

-- 一键拾取圆(x,y)半径(r)
---@param u userdata
---@param x number
---@param y number
---@param r number
hitem.pickRound = function(u, x, y, r)
    for k = #hRuntime.itemPickPool, 1, -1 do
        local xi = cj.GetItemX(hRuntime.itemPickPool[k])
        local yi = cj.GetItemY(hRuntime.itemPickPool[k])
        local d = math.getDistanceBetweenXY(x, y, xi, yi)
        if (d <= r and hitem.getEmptySlot(u) > 0) then
            hitem.pick(hRuntime.itemPickPool[k], u)
        else
            break
        end
    end
end