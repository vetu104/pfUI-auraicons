pfUI:RegisterModule("auraicons", "vanilla", function()
    local watcher = pfAuraiconsWatcherFrame
    local strgsub = string.gsub

    --{{
    -- Init gui config
    pfUI.gui.CreateGUIEntry(T["Thirdparty"], T["Auraicons"], function()
        pfUI.gui.CreateConfig(nil, T["Own buffs to track"],     C.auraicons.pbuff,   "enabled",    "list"      )
        pfUI.gui.CreateConfig(nil, T["Enemy debuffs to track"], C.auraicons.edebuff, "enabled",    "list"      )
        pfUI.gui.CreateConfig(nil, T["Font size"],              C.auraicons,         "fontsize"                )
        pfUI.gui.CreateConfig(nil, T["Icon size"],              C.auraicons,         "iconsize"                )
        pfUI.gui.CreateConfig(nil, T["Greyscale on inactive"],  C.auraicons,         "greyscale",  "checkbox"  )
    end)

    pfUI:UpdateConfig("auraicons",   "pbuff",     "enabled",      "")
    pfUI:UpdateConfig("auraicons",   "edebuff",   "enabled",      "")
    pfUI:UpdateConfig("auraicons",   nil,         "fontsize",     "20")
    pfUI:UpdateConfig("auraicons",   nil,         "iconsize",     "48")
    pfUI:UpdateConfig("auraicons",   nil,         "greyscale",    "1")
    --}}

    -- {{ Class for creating new icons
    local function Newicon(args)
        args = args or {}

        args.font       = pfUI.font_default or "Fonts\\FRITZQT__.TTF"
        args.fontsize   = tonumber(C.auraicons.fontsize) or 20
        args.sfontsize  = 11
        args.greyscale  = C.auraicons.greyscale
        args.name       = args.name or ""
        args.size       = C.auraicons.iconsize or 48
        args.unit       = args.unit or "player"

        local br, bg, bb, ba = GetStringColor(pfUI_config.appearance.border.color)
        local backdrop_highlight = { edgeFile = pfUI.media["img:glow"] ,edgeSize = 8 }

        local texture
        if L["icons"][args.name] then
            texture = "Interface\\Icons\\" .. L["icons"][args.name]
        else
            texture = "Interface\\Icons\\Temp"
        end

        local framename = strgsub("pfAuraicons"  .. args.name .. "Frame", "%s+", "" )
        local f = CreateFrame("Frame", framename, UIParent)
        f.name = framename -- Just for good measure
        f:SetWidth(args.size)
        f:SetHeight(args.size)
        f:SetPoint("CENTER", UIParent)

        f.texture = f:CreateTexture()
        f.texture:SetTexCoord(.08, .92, .08, .92) -- Zooms the texture in to hide borders
        f.texture:SetAllPoints(f)
        f.texture:SetTexture(texture)

        f.text = f:CreateFontString()
        f.text:SetPoint("CENTER", f)
        f.text:SetFont(args.font, args.fontsize, "OUTLINE")

        f.smalltext = f:CreateFontString()
        f.smalltext:SetPoint("BOTTOMRIGHT", f)
        f.smalltext:SetFont(args.font, args.sfontsize, "OUTLINE")

        f.backdrop = CreateFrame("Frame", nil, f)
        f.backdrop:SetBackdrop(backdrop_highlight)
        f.backdrop:SetBackdropBorderColor(br,bg,bb,ba)
        f.backdrop:SetAllPoints()
        f:SetScript("OnUpdate", function()
            -- Throttle this too
            if ( this.tick or 1 ) > GetTime() then return end
            this.tick = GetTime() + 0.4

            local auratable = watcher:fetch(args.name, args.unit)
            if not auratable then
                this.text:SetText(nil)
                this.smalltext:SetText(nil)
                if args.greyscale == "1" then
                    this.texture:SetDesaturated(true)
                end
            else
                this.text:SetText(strsplit(".", auratable[1]))
                if auratable[5] > 1 then
                    this.smalltext:SetText(strsplit(".", auratable[5]))
                end
                this.texture:SetDesaturated(false)
            end
        end)

        return f
    end
    --}}

    --{{
    -- Spawn icons
    local pbuffs = { strsplit("#", C.auraicons.pbuff.enabled) }
    local edebuffs = { strsplit("#", C.auraicons.edebuff.enabled) }

    for _,v in ipairs(pbuffs) do
        local f = Newicon({ name = v, unit = "player", })
        pfUI.api.UpdateMovable(f) -- Adds the frame to unlock/move mode
    end

    for _,v in ipairs(edebuffs) do
        local f = Newicon({ name = v, unit = "target",  })
        pfUI.api.UpdateMovable(f) -- Adds the frame to unlock/move mode
    end
    --}}
end)
