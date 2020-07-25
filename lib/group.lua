hgroup = {}

--- 循环group
---@alias GroupLoop fun(enumUnit: userdata):void
---@param whichGroup table
---@param actions GroupLoop | "function(enumUnit) end"
---@param autoDel boolean
hgroup.loop = function(whichGroup, actions, autoDel)
    if (whichGroup == nil) then
        return
    end
    if (#whichGroup > 0) then
        if (type(autoDel) ~= "boolean") then
            autoDel = false
        end
        for idx, eu in ipairs(whichGroup) do
            if (his.deleted(eu) == false) then
                if (type(actions) == "function") then
                    actions(eu)
                end
            else
                table.remove(whichGroup, idx)
                idx = idx - 1
            end
        end
    end
    if (autoDel == true) then
        whichGroup = nil
    end
end

--- 统计单位组当前单位数
---@param whichGroup table
---@return number
hgroup.count = function(whichGroup)
    if (whichGroup == nil) then
        return 0
    end
    return #whichGroup
end

--- 判断单位是否在单位组内
---@param whichGroup table
---@param whichUnit userdata
---@return boolean
hgroup.includes = function(whichGroup, whichUnit)
    if (whichGroup == nil or whichUnit == nil) then
        return false
    end
    return table.includes(whichUnit, whichGroup)
end

--- 判断单位组是否为空
---@param whichGroup table
---@return boolean
hgroup.isEmpty = function(whichGroup)
    if (whichGroup == nil or #whichGroup == 0) then
        return true
    end
    return false
end

--- 单位组添加单位
---@param whichGroup table
---@param whichUnit userdata
hgroup.addUnit = function(whichGroup, whichUnit)
    if (hgroup.includes(whichGroup, whichUnit) == false) then
        table.insert(whichGroup, whichUnit)
    end
end
--- 单位组删除单位
---@param whichGroup table
---@param whichUnit userdata
hgroup.removeUnit = function(whichGroup, whichUnit)
    if (hgroup.includes(whichGroup, whichUnit) == true) then
        table.delete(whichUnit, whichGroup)
    end
end

--- 创建单位组,以(x,y)点为中心radius距离
---@alias GroupFilter fun(filterUnit: userdata):void
---@param x number
---@param y number
---@param radius number
---@param filterFunc GroupFilter | "function(filterUnit) end"
---@return table
hgroup.createByXY = function(x, y, radius, filterFunc)
    if (#hRuntime.group == 0) then
        return {}
    end
    -- 镜头放大模式下，范围缩小一半
    if (hcamera.model == "zoomin") then
        radius = radius * 0.5
    end
    local g = {}
    for idx, filterUnit in ipairs(hRuntime.group) do
        if (his.deleted(filterUnit)) then
            table.remove(hRuntime.group, idx)
            idx = idx - 1
        end
        -- 排除超过距离的单位
        if (radius >= math.getDistanceBetweenXY(x, y, hunit.x(filterUnit), hunit.y(filterUnit))) then
            if (filterFunc ~= nil) then
                if (filterFunc(filterUnit) == true) then
                    table.insert(g, filterUnit)
                end
            else
                table.insert(g, filterUnit)
            end
        end
    end
    return g
end

--- 创建单位组,以某个单位为中心radius距离
---@param u userdata
---@param radius number
---@param filterFunc GroupFilter | "function(filterUnit) end"
---@return userdata
hgroup.createByUnit = function(u, radius, filterFunc)
    return hgroup.createByXY(hunit.x(u), hunit.y(u), radius, filterFunc)
end

--- 创建单位组,以loc点为中心radius距离
---@param loc userdata
---@param radius number
---@param filterFunc GroupFilter | "function(filterUnit) end"
---@return userdata
hgroup.createByLoc = function(loc, radius, filterFunc)
    return hgroup.createByXY(cj.GetLocationX(loc), cj.GetLocationY(loc), radius, filterFunc)
end

--- 创建单位组,以区域为范围选择
---@param r userdata
---@param filterFunc GroupFilter | "function(filterUnit) end"
---@return userdata
hgroup.createByRect = function(r, filterFunc)
    if (#hRuntime.group == 0) then
        return {}
    end
    local g = {}
    for idx, filterUnit in ipairs(hRuntime.group) do
        if (his.deleted(filterUnit)) then
            table.remove(hRuntime.group, idx)
            idx = idx - 1
        end
        -- 排除区域外
        if (his.inRect(r, hunit.x(filterUnit), hunit.y(filterUnit))) then
            if (filterFunc ~= nil) then
                if (filterFunc(filterUnit) == true) then
                    table.insert(g, filterUnit)
                end
            else
                table.insert(g, filterUnit)
            end
        end
    end
    return g
end

--- 获取单位组内离选定的(x,y)最近的单位
---@param whichGroup userdata
---@param x number
---@param y number
---@return userdata 单位
hgroup.getClosest = function(whichGroup, x, y)
    if (whichGroup == nil or x == nil or y == nil) then
        return
    end
    if (hgroup.count(whichGroup) == 0) then
        return
    end
    local closeDist = 99999
    local closeUnit
    hgroup.loop(whichGroup, function(eu)
        local dist = math.getDistanceBetweenXY(x, y, hunit.x(eu), hunit.y(eu))
        if (dist < closeDist) then
            closeUnit = eu
        end
    end)
    return closeUnit
end

--- 瞬间移动单位组
---@param whichGroup userdata
---@param x number
---@param y number
---@param eff string
---@param isFollow boolean
hgroup.portal = function(whichGroup, x, y, eff, isFollow)
    if (whichGroup == nil or x == nil or y == nil) then
        return
    end
    hgroup.loop(whichGroup, function(eu)
        hunit.portal(eu, x, y)
        if (isFollow == true) then
            cj.PanCameraToTimedForPlayer(hunit.getOwner(eu), x, y, 0.00)
        end
        if (eff ~= nil) then
            heffect.toXY(eff, x, y, 0)
        end
    end)
end

--- 指挥单位组所有单位做动作
---@param whichGroup userdata
---@param animate string | number
hgroup.animate = function(whichGroup, animate)
    if (whichGroup == nil or animate == nil) then
        return
    end
    hgroup.loop(whichGroup, function(eu)
        if (his.death(eu) == false) then
            hunit.animate(eu, animate)
        end
    end)
end

--- 清空单位组
---@param whichGroup userdata
---@param isDestroy boolean 是否同时删除单位组
---@param isDestroyUnit boolean 是否同时删除单位组里面的单位
---
hgroup.clear = function(whichGroup, isDestroy, isDestroyUnit)
    if (whichGroup == nil) then
        return
    end
    if (isDestroyUnit == true) then
        hgroup.loop(whichGroup, function(eu)
            hunit.del(eu)
        end)
    end
    if (isDestroy == true) then
        whichGroup = nil
    else
        whichGroup = {}
    end
end
