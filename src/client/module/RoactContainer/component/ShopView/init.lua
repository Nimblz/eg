local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local lib = ReplicatedStorage:WaitForChild("lib")
local common = ReplicatedStorage:WaitForChild("common")
local component = script.Parent

local Assets = require(common:WaitForChild("Assets"))
local ShopProducts = require(common:WaitForChild("ShopProducts"))
local ShopCatagories = require(common:WaitForChild("ShopCatagories"))
local Actions = require(common:WaitForChild("Actions"))
local Selectors = require(common:WaitForChild("Selectors"))
local Roact = require(lib:WaitForChild("Roact"))
local RoactRodux = require(lib:WaitForChild("RoactRodux"))

local AssetGrid = require(component:WaitForChild("AssetGrid"))
local ProductButton = require(component:WaitForChild("ProductButton"))
local VerticalNavbar = require(component:WaitForChild("VerticalNavbar"))

local PIXEL_SIZE = 600
local TARGET_AXIS_SCALE = 3/4

local ShopView = Roact.Component:extend("ShopView")

function ShopView:setCatagory(newCatagory)
    self:setState({
        catagory = newCatagory,
    })
end

function ShopView:init()
    self:setState({
        catagory = ShopCatagories.byId["halloween"],
    })
end

function ShopView:render()

    local cataButtons = ShopCatagories.all

    local catagoryProducts = {}

    for _, product in ipairs(ShopProducts.all) do
        local productAsset = Assets.byId[product.id]
        if productAsset then
            if productAsset.shopCatagory == self.state.catagory.id then
                table.insert(catagoryProducts, product.id)
            end
        end
    end

    local content = {}
    content.padding = Roact.createElement("UIPadding", {
        PaddingLeft = UDim.new(0,16),
        PaddingTop = UDim.new(0,16),
        PaddingRight = UDim.new(0,16),
        PaddingBottom = UDim.new(0,16),
    })

    content.assetScrollFrame = Roact.createElement("ScrollingFrame", {
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,1,0),
        CanvasSize = UDim2.new(0,0,0,math.ceil(#catagoryProducts/5)*(160+8) + 24),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        BackgroundColor3 = Color3.fromRGB(245,245,245),
        TopImage = "rbxassetid://38052958",
        BottomImage = "rbxassetid://38052958",
        MidImage = "rbxassetid://38052958",
    }, {
        assetGrid = Roact.createElement(AssetGrid, {
            containerProps = {
                Size = UDim2.new(1,0,1,0),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
            },
            layoutProps = {
                CellSize = UDim2.new(0,128,0,160),
                CellPadding = UDim2.new(0,8,0,8),
            },
            paddingProps = {
                PaddingLeft = UDim.new(0,16),
                PaddingTop = UDim.new(0,16),
            },
            assets = catagoryProducts or {},
            assetElementType = ProductButton,
            assetElementProps = {
                onClick = function(assetId)
                    if not self.props.isOwned(assetId) then
                        self.props.clientApi:buyAsset(assetId)
                    end
                end
            }
        })
    })

    return Roact.createElement("Frame", {
        Size = UDim2.new(0,800,0,600),
        Position = UDim2.new(0.5,0,0.5,0),
        AnchorPoint = Vector2.new(0.5,0.5),

        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255,255,255),

        Visible = self.props.view == "shop"
    }, {
        scale = Roact.createElement("UIScale", {
            Scale = math.min(1,(self.props.viewportSize.Y * TARGET_AXIS_SCALE)/PIXEL_SIZE)
        }),
        layout = Roact.createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Top,
        }),
        catagoriesNavbar = Roact.createElement(VerticalNavbar, {
            BackgroundColor3 = Color3.fromRGB(255, 94, 14),
            hoveredColor3 = Color3.fromRGB(255, 122, 5),
            width = 64,
            catagories = cataButtons,
            ZIndex = 2,
            selectedCatagory = self.state.catagory,
            onCatagorySelect = function(catagory)
                self:setCatagory(catagory)
            end,
        }),
        contentframe = Roact.createElement("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -64, 1, 0),
        }, content)
    })
end

local function mapDispatchToProps(dispatch)
    return {
        close = function()
            dispatch(Actions.UI_VIEW_SET(nil))
        end
    }
end

local function mapStateToProps(state,props)
    local function isOwned(assetId)
        return Selectors.isOwned(state,LocalPlayer,assetId)
    end
    return {
        inventory = Selectors.getInventory(state,LocalPlayer),
        isOwned = isOwned,
        view = Selectors.getUIView(state)
    }
end

ShopView = RoactRodux.connect(mapStateToProps,mapDispatchToProps)(ShopView)

return ShopView