calcSunScreenPosition = function()
    local view = {0,0,0,0}
    local lightDir = {1,0,0,0}
    local fov = 60
    local aspectRatio = 1

    getAttr("CAMERA", "MainCamera", "VIEW", 0, view)
    getAttr("CAMERA", "MainCamera", "FOV", 0, fov)
    --getAttr("CAMERA", "MainCamera", "", 0, aspectRatio)
    getAttr("Light", "Sun", "DIRECTION", 0, lightDir)
    
    local m_view = {0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0}
    local m_proj = {0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0}
    
    local sunpos = {0.0, 0.9}
    setAttr("RENDERER", "CURRENT", "sun_screenPos", 0, sunpos)
end