hcamera = {}

--- 重置镜头
---@param whichPlayer userdata
---@param during number
hcamera.reset = function(whichPlayer, during)
    if (whichPlayer == nil or cj.GetLocalPlayer() == whichPlayer) then
        cj.ResetToGameCamera(during)
    end
end
--- 应用镜头
---@param whichPlayer userdata
---@param during number
---@param camerasetup userdata
hcamera.apply = function(whichPlayer, during, camerasetup)
    if (whichPlayer == nil or cj.GetLocalPlayer() == whichPlayer) then
        cj.CameraSetupApplyForceDuration(camerasetup, true, during)
    end
end
--- 移动到XY
---@param whichPlayer userdata
---@param during number
---@param x number
---@param y number
hcamera.toXY = function(whichPlayer, during, x, y)
    if (whichPlayer == nil or cj.GetLocalPlayer() == whichPlayer) then
        cj.PanCameraToTimed(x, y, during)
    end
end
--- 移动到点
---@param whichPlayer userdata
---@param during number
---@param loc userdata
hcamera.toLoc = function(whichPlayer, during, loc)
    hcamera.toXY(whichPlayer, during, cj.GetLocationX(loc), cj.GetLocationY(loc))
end
--- 移动到单位位置
---@param whichPlayer userdata
---@param during number
---@param whichUnit userdata
hcamera.toUnit = function(whichPlayer, during, whichUnit)
    if (whichUnit == nil) then
        return
    end
    if (whichPlayer == nil or cj.GetLocalPlayer() == whichPlayer) then
        cj.PanCameraToTimed(hunit.x(whichUnit), hunit.y(whichUnit), during)
    end
end
--- 锁定镜头
---@param whichPlayer userdata
---@param whichUnit userdata
hcamera.lock = function(whichPlayer, whichUnit)
    if (whichPlayer ~= nil or cj.GetLocalPlayer() == whichPlayer) then
        if (his.alive(whichUnit) == true) then
            cj.SetCameraTargetController(whichUnit, 0, 0, false)
        else
            hcamera.reset(whichPlayer, 0)
        end
    end
end
--- 更改镜头距离
---@param whichPlayer userdata
---@param diffDistance number
hcamera.changeDistance = function(whichPlayer, diffDistance)
    if (type(diffDistance) ~= "number") then
        diffDistance = 0
    end
    if (diffDistance ~= 0 and whichPlayer ~= nil and cj.GetLocalPlayer() == whichPlayer) then
        local oldDistance = cj.GetCameraField(CAMERA_FIELD_TARGET_DISTANCE)
        local toDistance = math.floor(oldDistance + diffDistance)
        if (toDistance < 500) then
            toDistance = 500
        elseif (toDistance > 5000) then
            toDistance = 5000
        end
        echo("视距已设定为：" .. toDistance, whichPlayer)
        if (oldDistance == toDistance) then
            return
        else
            cj.SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, toDistance, 0)
        end
    end
end

--- 玩家镜头震动，震动包括两种
---@param whichPlayer userdata 玩家
---@param whichType string | "'shake'" | "'quake'"
---@param during number 持续时间
---@param scale number 振幅
hcamera.shock = function(whichPlayer, whichType, during, scale)
    if (whichPlayer == nil) then
        return
    end
    if (whichType ~= "shake" or whichType ~= "quake") then
        return
    end
    if (during == nil) then
        during = 0.10 -- 假如没有设置时间，默认0.10秒意思意思一下
    end
    if (scale == nil) then
        scale = 5.00 -- 假如没有振幅，默认5.00意思意思一下
    end
    -- 镜头动作降噪
    local index = hplayer.index(whichPlayer)
    if (hRuntime.camera[index].isShocking == true) then
        return
    end
    hRuntime.camera[index].isShocking = true
    if (whichType == "shake") then
        cj.CameraSetTargetNoiseForPlayer(whichPlayer, scale, 1.00)
        htime.setTimeout(
            during,
            function(t)
                htime.delTimer(t)
                hRuntime.camera[index].isShocking = false
                if (cj.GetLocalPlayer() == whichPlayer) then
                    cj.CameraSetTargetNoise(0, 0)
                end
            end
        )
    elseif (whichType == "quake") then
        cj.CameraSetEQNoiseForPlayer(whichPlayer, scale)
        htime.setTimeout(
            during,
            function(t)
                htime.delTimer(t)
                hRuntime.camera[index].isShocking = false
                if (cj.GetLocalPlayer() == whichPlayer) then
                    cj.CameraClearNoiseForPlayer(0, 0)
                end
            end
        )
    end
end

--- 获取镜头模型
---@param whichPlayer userdata 玩家
hcamera.getModel = function(whichPlayer)
    local index = hplayer.index(whichPlayer)
    if (hRuntime.camera[index] == nil) then
        return "normal"
    elseif (hRuntime.camera[index].model == nil) then
        return "normal"
    end
    return hRuntime.camera[index].model
end
--- 设置镜头模式
--[[
 bean = {
    model = "normal" | "lock",
    whichPlayer = player, -- 锁定单位的玩家
    lockUnit = unit, -- 锁定单位的绑定单位,与玩家对应
 }
]]
hcamera.setModel = function(bean)
    if (bean.model == nil) then
        return
    end
    if (bean.model == "normal") then
        hcamera.reset(bean.whichPlayer, 0)
    elseif (bean.model == "lock") then
        if (bean.lockUnit == nil or bean.whichPlayer == nil) then
            return
        end
        htime.setInterval(
            0.1,
            function()
                hcamera.lock(bean.whichPlayer, bean.lockUnit)
            end
        )
    elseif (bean.model == "zoomin") then
        -- hattr.max_move_speed = hattr.max_move_speed * 2
        htime.setInterval(
            0.1,
            function()
                hcamera.distance(bean.whichPlayer, 825)
            end
        )
    elseif (bean.model == "zoomout") then
        htime.setInterval(
            0.1,
            function()
                hcamera.distance(bean.whichPlayer, 3000)
            end
        )
    else
        return
    end
    if (bean.whichPlayer ~= nil) then
        local index = hplayer.index(bean.whichPlayer)
        hRuntime.camera[index].model = bean.model
    else
        for i = 1, 12, 1 do
            hRuntime.camera[i].model = bean.model
        end
    end
end
