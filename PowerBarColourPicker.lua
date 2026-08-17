--------------------------------------------------
-- Power Bar Colour Picker
-- WoW Classic Anniversary
-- Version 6.2
--------------------------------------------------

--------------------------------------------------
-- PRESET COLOURS
--------------------------------------------------

local COLOURS = {
    { name = "Pink",       r = 1.00, g = 0.00, b = 0.55 },
    { name = "Magenta",    r = 1.00, g = 0.00, b = 1.00 },
    { name = "Red",        r = 1.00, g = 0.00, b = 0.00 },
    { name = "Orange",     r = 1.00, g = 0.45, b = 0.00 },
    { name = "Yellow",     r = 1.00, g = 1.00, b = 0.00 },
    { name = "Green",      r = 0.00, g = 1.00, b = 0.00 },
    { name = "Lime",       r = 0.50, g = 1.00, b = 0.00 },
    { name = "Cyan",       r = 0.00, g = 1.00, b = 1.00 },
    { name = "Blue",       r = 0.00, g = 0.45, b = 1.00 },
    { name = "Purple",     r = 0.60, g = 0.10, b = 1.00 },
    { name = "White",      r = 1.00, g = 1.00, b = 1.00 },
    { name = "Grey",       r = 0.55, g = 0.55, b = 0.55 },
}


--------------------------------------------------
-- POWER TYPES
--------------------------------------------------

local POWER_TYPES = {
    {
        token = "MANA",
        name = "Mana",
        width = 68,
        default = {
            r = 0.00,
            g = 0.50,
            b = 1.00
        }
    },

    {
        token = "RAGE",
        name = "Rage",
        width = 68,
        default = {
            r = 1.00,
            g = 0.00,
            b = 0.00
        }
    },

    {
        token = "ENERGY",
        name = "Energy",
        width = 76,
        default = {
            r = 1.00,
            g = 1.00,
            b = 0.00
        }
    },

    {
        token = "FOCUS",
        name = "Focus",
        width = 72,
        default = {
            r = 1.00,
            g = 0.50,
            b = 0.25
        }
    },

    {
        token = "RUNIC_POWER",
        name = "Runic Power",
        width = 100,
        default = {
            r = 0.00,
            g = 0.82,
            b = 1.00
        }
    },
}


--------------------------------------------------
-- DATABASE
--------------------------------------------------

local function EnsureDB()

    if not PowerBarColourDB then
        PowerBarColourDB = {}
    end

    for _, power in ipairs(POWER_TYPES) do

        if not PowerBarColourDB[power.token] then

            PowerBarColourDB[power.token] = {
                r = power.default.r,
                g = power.default.g,
                b = power.default.b
            }

        end

    end
end


--------------------------------------------------
-- APPLY SAVED COLOURS TO BLIZZARD
--------------------------------------------------

local function ApplyAllPowerColours()

    EnsureDB()

    for _, power in ipairs(POWER_TYPES) do

        local colour =
            PowerBarColourDB[power.token]

        if PowerBarColor
            and PowerBarColor[power.token]
            and colour then

            PowerBarColor[power.token].r =
                colour.r

            PowerBarColor[power.token].g =
                colour.g

            PowerBarColor[power.token].b =
                colour.b

        end

    end
end


--------------------------------------------------
-- APPLY CURRENT PLAYER POWER BAR
--------------------------------------------------

local function ApplyCurrentPowerColour()

    EnsureDB()
    ApplyAllPowerColours()

    if not PlayerFrameManaBar then
        return
    end

    local powerTypeID, powerToken =
        UnitPowerType("player")

    if not powerToken then
        return
    end

    local colour =
        PowerBarColourDB[powerToken]

    if not colour then
        return
    end

    PlayerFrameManaBar:SetStatusBarColor(
        colour.r,
        colour.g,
        colour.b,
        1
    )
end


--------------------------------------------------
-- MAIN WINDOW
--------------------------------------------------

local window = CreateFrame(
    "Frame",
    "PowerBarColourPickerWindow",
    UIParent,
    "BasicFrameTemplateWithInset"
)

window:SetSize(
    450,
    410
)

window:SetPoint(
    "CENTER"
)

window:SetMovable(
    true
)

window:EnableMouse(
    true
)

window:RegisterForDrag(
    "LeftButton"
)

window:SetScript(
    "OnDragStart",
    function(self)
        self:StartMoving()
    end
)

window:SetScript(
    "OnDragStop",
    function(self)
        self:StopMovingOrSizing()
    end
)

window:Hide()


--------------------------------------------------
-- WINDOW TITLE
--------------------------------------------------

window.title = window:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlight"
)

window.title:SetPoint(
    "LEFT",
    window.TitleBg,
    "LEFT",
    5,
    0
)

window.title:SetText(
    "Power Bar Colour Picker"
)


--------------------------------------------------
-- DESCRIPTION
--------------------------------------------------

local description = window:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)

description:SetPoint(
    "TOP",
    window,
    "TOP",
    0,
    -42
)

description:SetText(
    "Choose a power type, then choose its colour."
)


--------------------------------------------------
-- SELECTED POWER
--------------------------------------------------

local selectedPower =
    "MANA"


--------------------------------------------------
-- POWER BUTTONS
--------------------------------------------------

local powerButtons = {}

local function UpdatePowerButtons()

    for token, button in pairs(powerButtons) do

        if token == selectedPower then
            button:LockHighlight()
        else
            button:UnlockHighlight()
        end

    end
end


--------------------------------------------------
-- CALCULATE TOTAL POWER BUTTON WIDTH
--------------------------------------------------

local POWER_BUTTON_GAP = 6
local totalPowerWidth = 0

for _, power in ipairs(POWER_TYPES) do

    totalPowerWidth =
        totalPowerWidth + power.width

end

totalPowerWidth =
    totalPowerWidth
    + ((#POWER_TYPES - 1) * POWER_BUTTON_GAP)

local currentX =
    -(totalPowerWidth / 2)


--------------------------------------------------
-- CREATE POWER BUTTONS
--------------------------------------------------

for _, power in ipairs(POWER_TYPES) do

    local button = CreateFrame(
        "Button",
        nil,
        window,
        "UIPanelButtonTemplate"
    )

    button:SetSize(
        power.width,
        26
    )

    button:SetPoint(
        "TOPLEFT",
        window,
        "TOP",
        currentX,
        -78
    )

    button:SetText(
        power.name
    )

    button:SetScript(
        "OnClick",
        function()

            selectedPower =
                power.token

            UpdatePowerButtons()

        end
    )

    powerButtons[power.token] =
        button

    currentX =
        currentX
        + power.width
        + POWER_BUTTON_GAP
end


--------------------------------------------------
-- SET POWER COLOUR
--------------------------------------------------

local function SetPowerColour(colour)

    EnsureDB()

    PowerBarColourDB[selectedPower] = {
        r = colour.r,
        g = colour.g,
        b = colour.b
    }

    ApplyAllPowerColours()
    ApplyCurrentPowerColour()
end


--------------------------------------------------
-- COLOUR BUTTONS
--------------------------------------------------

local COLOUR_BUTTON_WIDTH = 160
local COLOUR_BUTTON_HEIGHT = 32

local COLOUR_COLUMN_LEFT = 45
local COLOUR_COLUMN_GAP = 40
local COLOUR_ROW_GAP = 6

local startY =
    -125


for index, colour in ipairs(COLOURS) do

    local column =
        (index - 1) % 2

    local row =
        math.floor(
            (index - 1) / 2
        )

    local button = CreateFrame(
        "Button",
        nil,
        window,
        "UIPanelButtonTemplate"
    )

    button:SetSize(
        COLOUR_BUTTON_WIDTH,
        COLOUR_BUTTON_HEIGHT
    )

    button:SetPoint(
        "TOPLEFT",
        window,
        "TOPLEFT",

        COLOUR_COLUMN_LEFT
            + (
                column
                * (
                    COLOUR_BUTTON_WIDTH
                    + COLOUR_COLUMN_GAP
                )
            ),

        startY
            - (
                row
                * (
                    COLOUR_BUTTON_HEIGHT
                    + COLOUR_ROW_GAP
                )
            )
    )


    --------------------------------------------------
    -- COLOUR SWATCH
    --------------------------------------------------

    local swatch =
        button:CreateTexture(
            nil,
            "OVERLAY"
        )

    swatch:SetSize(
        20,
        20
    )

    swatch:SetPoint(
        "LEFT",
        button,
        "LEFT",
        8,
        0
    )

    swatch:SetColorTexture(
        colour.r,
        colour.g,
        colour.b,
        1
    )


    --------------------------------------------------
    -- COLOUR NAME
    --------------------------------------------------

    local label =
        button:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    label:SetPoint(
        "LEFT",
        swatch,
        "RIGHT",
        8,
        0
    )

    label:SetText(
        colour.name
    )


    --------------------------------------------------
    -- CLICK
    --------------------------------------------------

    button:SetScript(
        "OnClick",
        function()

            SetPowerColour(
                colour
            )

        end
    )
end


--------------------------------------------------
-- RESET SELECTED
--------------------------------------------------

local resetSelected = CreateFrame(
    "Button",
    nil,
    window,
    "UIPanelButtonTemplate"
)

resetSelected:SetSize(
    COLOUR_BUTTON_WIDTH,
    COLOUR_BUTTON_HEIGHT
)

resetSelected:SetPoint(
    "BOTTOMLEFT",
    window,
    "BOTTOMLEFT",
    COLOUR_COLUMN_LEFT,
    20
)

resetSelected:SetText(
    "Reset Selected"
)

resetSelected:SetScript(
    "OnClick",
    function()

        EnsureDB()

        for _, power in ipairs(POWER_TYPES) do

            if power.token ==
                selectedPower then

                PowerBarColourDB[selectedPower] = {
                    r = power.default.r,
                    g = power.default.g,
                    b = power.default.b
                }

                break
            end
        end

        ApplyAllPowerColours()
        ApplyCurrentPowerColour()

    end
)


--------------------------------------------------
-- RESET ALL
--------------------------------------------------

local resetAll = CreateFrame(
    "Button",
    nil,
    window,
    "UIPanelButtonTemplate"
)

resetAll:SetSize(
    COLOUR_BUTTON_WIDTH,
    COLOUR_BUTTON_HEIGHT
)

resetAll:SetPoint(
    "BOTTOMRIGHT",
    window,
    "BOTTOMRIGHT",
    -COLOUR_COLUMN_LEFT,
    20
)

resetAll:SetText(
    "Reset All"
)

resetAll:SetScript(
    "OnClick",
    function()

        EnsureDB()

        for _, power in ipairs(POWER_TYPES) do

            PowerBarColourDB[power.token] = {
                r = power.default.r,
                g = power.default.g,
                b = power.default.b
            }

        end

        ApplyAllPowerColours()
        ApplyCurrentPowerColour()

    end
)


--------------------------------------------------
-- SLASH COMMAND
--------------------------------------------------

SLASH_POWERBARCOLOUR1 =
    "/pbcp"

SlashCmdList["POWERBARCOLOUR"] =
    function()

        EnsureDB()

        UpdatePowerButtons()
        ApplyCurrentPowerColour()

        if window:IsShown() then
            window:Hide()
        else
            window:Show()
        end

    end


--------------------------------------------------
-- EVENTS
--------------------------------------------------

local events =
    CreateFrame(
        "Frame"
    )

events:RegisterEvent(
    "PLAYER_LOGIN"
)

events:RegisterEvent(
    "PLAYER_ENTERING_WORLD"
)

events:RegisterEvent(
    "UNIT_DISPLAYPOWER"
)

events:RegisterEvent(
    "UNIT_POWER_UPDATE"
)

events:RegisterEvent(
    "UNIT_MAXPOWER"
)


events:SetScript(
    "OnEvent",
    function(self, event, unit)

        if unit
            and unit ~= "player" then

            return

        end

        EnsureDB()

        ApplyAllPowerColours()
        ApplyCurrentPowerColour()


        --------------------------------------------------
        -- CLASSIC MAY REPAINT THE BAR
        --------------------------------------------------

        C_Timer.After(
            0.1,
            ApplyCurrentPowerColour
        )

        C_Timer.After(
            0.5,
            ApplyCurrentPowerColour
        )

        C_Timer.After(
            1.0,
            ApplyCurrentPowerColour
        )

    end
)


--------------------------------------------------
-- PERIODIC SAFEGUARD
--------------------------------------------------

local updateTimer =
    0

events:SetScript(
    "OnUpdate",
    function(self, elapsed)

        updateTimer =
            updateTimer + elapsed

        if updateTimer >= 1 then

            updateTimer =
                0

            ApplyCurrentPowerColour()

        end

    end
)


--------------------------------------------------
-- INITIAL BUTTON STATE
--------------------------------------------------

UpdatePowerButtons()


--------------------------------------------------
-- LOADED MESSAGE
--------------------------------------------------

print("")
print("|cffffffff------------------------------------------------------|r")
print("|cffffff00Power Bar Colour Picker Loaded|r")
print("|cffffffffType /pbcp to select a different colour|r")
print("|cffffffff------------------------------------------------------|r")