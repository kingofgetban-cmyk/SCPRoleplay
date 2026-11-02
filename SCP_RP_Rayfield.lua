-- ==============================================================================
-- MINTRAZERX SECURITY GATEWAY — GITHUB DEPRECATION NOTICE
-- Target: SCP: Roleplay Rayfield Edition
-- ==============================================================================
-- [!] Direct raw script execution from GitHub has been permanently disabled
--     for security integrity and anti-tamper compliance.
--
-- All official game suites are now securely encrypted, authenticated, and 
-- distributed exclusively through the official MintraZERX Server Loader:
-- Server: https://mintrazerx-keysystem-wf4n.onrender.com/
-- Key Portal: https://mintrazerx-keysystem-wf4n.onrender.com/redeem
-- ==============================================================================

local SERVER_LOADER_URL = "https://mintrazerx-keysystem-wf4n.onrender.com/mintrazerx.lua"

pcall(function()
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCore("SendNotification", {
        Title = "MintraZERX Hub",
        Text = "Direct GitHub script execution is disabled! Redirecting to official loader...",
        Duration = 6
    })
end)

warn("[MintraZERX Security] Notice: Raw GitHub scripts are deprecated.")
warn("[MintraZERX Security] Please update your executor to load: " .. SERVER_LOADER_URL)

-- Automatically chain-load the official secured server loader
loadstring(game:HttpGet(SERVER_LOADER_URL))()
