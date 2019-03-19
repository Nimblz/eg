local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lib = ReplicatedStorage:WaitForChild("lib")
local common = ReplicatedStorage:WaitForChild("common")

local Roact = require(lib:WaitForChild("Roact"))
local RoactRodux = require(lib:WaitForChild("RoactRodux"))

local component = script.Parent
local common_util = common:WaitForChild("util")

local getTextSize = require(common_util:WaitForChild("getTextSize"))

local StatCounter = require(component:WaitForChild("StatCounter"))
local ShadowedTextLabel = require(component:WaitForChild("ShadowedTextLabel"))
local VersionLabel = require(component:WaitForChild("VersionLabel"))

local App = Roact.Component:extend("App")

function App:init(props)

end

function App:didMount()

end

function App:render()
    return Roact.createElement("ScreenGui", {Name = "gameGui", ResetOnSpawn = false}, {
        statframe = Roact.createElement("Frame", {
            Name = "StatFrame",
            Position = UDim2.new(0,32,0.5,0),
            Size = UDim2.new(0,400,0,200),
            AnchorPoint = Vector2.new(0,0.5),
            BackgroundTransparency = 1,
        }, {
            layout = Roact.createElement("UIListLayout",{
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),

            coinCounter = Roact.createElement(StatCounter,{
                iconImage = "rbxassetid://1025945542",
                statName = "Coins: ",
                value = self.props.coins
            }),
        }),

        versionlabel = VersionLabel(),
    })
end

local function mapStateToProps(state,props)
    return {
        coins = state.stats.coins
    }
end

local function mapDispatchToProps(dispatch)
    return {}
end

return RoactRodux.connect(mapStateToProps,mapDispatchToProps)(App)