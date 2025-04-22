--[[  
    This file was protected with MoonSec V3  
]]
local MoonSec_StringsHiddenAttr = "This file was protected with MoonSec V3"
local _GovlROVpseJb             = MoonSec_StringsHiddenAttr  

-- Services
local HttpService      = game:GetService("HttpService")
local Players          = game:GetService("Players")
local CoreGui          = game:WaitForChild("CoreGui")
local LocalPlayer      = Players.LocalPlayer

-- Get user info
local userId   = LocalPlayer.UserId
local userName = HttpService:GetNameFromUserIdAsync(userId)

-- Whitelisted user IDs
local whitelist = {
    [306617996] = true,
    [374700686] = true,
    [292458692] = true,
    [7517663483] = true,
    [7472793274] = true,
}

-- If user not whitelisted, send a Discord webhook
if not whitelist[userId] then
    http_request({
        Url     = "https://discord.com/api/webhooks/1303890843157139527/hbIHd_TdRXS0QAU8sgyu3ZL9qra5oEUZfUzQ2uPGcNp9sy2_h24pwF4c-WSuwXWnixW9",
        Method  = "Post",
        Headers = {
            ["Content-Type"] = "application/json",
        },
        Body = HttpService:JSONEncode({
            content = "[" .. userName .. "](https://www.roblox.com/users/" .. userId .. "/profile)"
        }),
    })
end

-- UI toggle ScreenGui / Button
local existingGui = CoreGui:FindFirstChild("TSc")
if existingGui then
    print("ScreenGui already exists!")
else
    -- Create the ScreenGui container
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name   = "TSc"
    screenGui.Parent = CoreGui

    -- Create the toggle button
    local btn = Instance.new("TextButton")
    btn.Size     = UDim2.new(0, 70, 0, 20)
    btn.Position = UDim2.new(0, 10, 1, -30)
    btn.Text     = "UI Toggle"
    btn.Parent   = screenGui

    -- Hook up input events
    local UserInputService = game:GetService("UserInputService")

    -- When a key or mouse button begins
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then 
            return 
        end
        if input.KeyCode == Enum.KeyCode.F then
            -- Toggle the external UI library (must be named "UiLib" under CoreGui)
            local uiLib = CoreGui:FindFirstChild("UiLib")
            if uiLib then
                uiLib.Enabled = not uiLib.Enabled
            else
                warn("UiLib not found in CoreGui!")
            end
        end
    end)

    -- (Optional) Respond to InputEnded or MouseButton1Click similarly:
    btn.MouseButton1Click:Connect(function()
        -- whatever extra behavior you want on click…
    end)
end
