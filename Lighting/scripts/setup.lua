setMatrices = function()
    local m_view = {0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0}
    local m_proj = {0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, 0, 0}

    getAttr("RENDERER", "CURRENT", "PROJECTION_VIEW", 0, m_proj)
    getAttr("CAMERA", "CURRENT", "VIEW_MATRIX", 0, m_view)
    setAttr("RENDERER", "CURRENT", "m_proj", 0, m_proj)
    setAttr("RENDERER", "CURRENT", "m_view", 0, m_view)
end

calcSunScreenPosition = function()
    local m_view = {}
    local m_proj = {}
    local m_pv = {}

    for i=1,16 do
        m_view[i] = 0
        m_proj[i] = 0
        m_pv[i] = 0
    end

    local light_dir = {0, 0, 0, 0}

    getAttr("RENDERER", "CURRENT", "PROJECTION", 0, m_proj)
    getAttr("CAMERA", "CURRENT", "VIEW_MATRIX", 0, m_view)
    getAttr("RENDERER", "CURRENT", "PROJECTION_VIEW", 0, m_pv)
    getAttr("LIGHT", "Sun", "DIRECTION", 0, light_dir)
    
    local sunpos = {0.2, 0.9}

    for i=1,3 do
        light_dir[i] = -light_dir[i]
    end

    --Normalize light direction
    --light_length =  light_dir[1] * light_dir[1] + 
    --                light_dir[2] * light_dir[2] + 
    --                light_dir[3] * light_dir[3]
    
    --light_length = light_length^0.5
    --light_dir[1] = light_dir[1] / light_length
    --light_dir[2] = light_dir[2] / light_length
    --light_dir[3] = light_dir[3] / light_length
    --light_dir[4] = 0

    local light_screenPos = {0, 0, 0, 0}
    --Multiply projection view matrix with light direction
    tmp = 0
    for j=0,3 do
        for k=0,3 do
            tmp = tmp + m_pv[1 + j + k * 4] * light_dir[1 + k]
        end
        light_screenPos[1 + j] = tmp
    end

    --Normalize position
    --for i=1,3 do
    --    light_screenPos[i] = light_screenPos[i] / light_screenPos[4]
    --end

    sunpos = { light_screenPos[1] * 0.5 + 0.5, light_screenPos[2] * 0.5 + 0.5}
    print(sunpos)
    setAttr("RENDERER", "CURRENT", "m_proj", 0, m_proj)
    setAttr("RENDERER", "CURRENT", "m_view", 0, m_view)
    setAttr("RENDERER", "CURRENT", "m_pv", 0, m_pv)
    setAttr("RENDERER", "CURRENT", "sun_screenPos", 0, sunpos)
end

createViewSizes = function()

end