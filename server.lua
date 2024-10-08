ESX = exports['es_extended']:getSharedObject()

local resourceName = GetCurrentResourceName() -- Get the name of the current resource
local url = 'https://raw.githubusercontent.com/Save5Bucks/stick_esx/refs/heads/main/fxmanifest.lua'
local localVersion = GetResourceMetadata(resourceName, 'version', 0) -- Read the version from local fxmanifest

-- Function to check the resource version on server start
local function version_check()
    -- Perform HTTP request to get the fxmanifest.lua from the remote GitHub repo
    PerformHttpRequest(
        url,
        function(err, text, headers)
            print('################## SAVE5BUCKS ##################')
            print('[INFO] Performing Update Check for: ' .. resourceName)

            if text ~= nil and err == 200 then
                -- Extract the version from the remote fxmanifest.lua
                local remoteVersion = string.match(text, "version '([%d%.]+)'")

                if remoteVersion then
                    -- Compare the local and remote versions
                    if localVersion == remoteVersion then
                        print('[INFO] ' .. resourceName .. ' is up-to-date (Version: ' .. localVersion .. ').')
                        print('################## SAVE5BUCKS ##################')
                    else
                        print('[WARNING] A newer version of ' .. resourceName .. ' is available!')
                        print('[INFO] Current Version: ' .. localVersion)
                        print('[INFO] Latest Version : ' .. remoteVersion)
                        print('################## SAVE5BUCKS ##################')
                    end
                else
                    print('[ERROR] Unable to find the version number in the remote fxmanifest.lua.')
                    print('################## SAVE5BUCKS ##################')
                end
            else
                print('[ERROR] Unable to retrieve the remote fxmanifest.lua. HTTP Error Code: ' .. tostring(err))
                print('################## SAVE5BUCKS ##################')
            end
        end,
        'GET',
        '',
        ''
    )
end

-- Run the version check when the server starts
AddEventHandler(
    'onResourceStart',
    function(resourceName)
        if GetCurrentResourceName() == resourceName then
            version_check()
        end
    end
)

-- Function to check vehicle transmission type from the database
function checkVehicleTransmission(plate, callback)
    MySQL.Async.fetchAll(
        'SELECT tmission FROM owned_vehicles WHERE plate = @plate',
        {
            ['@plate'] = plate
        },
        function(result)
            if result and #result > 0 then
                local tmissionValue = result[1].tmission
                -- Check if it's manual (1) or automatic (0), or another value
                if tmissionValue == true then
                    callback(true) -- Manual transmission
                elseif tmissionValue == false then
                    callback(false) -- Automatic transmission
                else
                    callback(nil) -- Unknown transmission
                end
            else
                callback(nil) -- No result found
            end
        end
    )
end

-- Export function to set vehicle transmission in the database
-- 0 = automatic, 1 = manual
exports(
    'setVehicleTransmission',
    function(plate, transmissionType)
        MySQL.Async.execute(
            'UPDATE owned_vehicles SET tmission = ? WHERE plate = ?',
            {transmissionType, plate},
            function(affectedRows)
                if affectedRows > 0 then
                    print(
                        'Transmission type for plate ' ..
                            plate .. ' set to ' .. (transmissionType == 1 and 'Manual' or 'Automatic')
                    )
                else
                    print('No vehicle found with plate: ' .. plate)
                end
            end
        )
    end
)

-- Event for checking vehicle transmission
RegisterNetEvent('checkVehicleTransmission')
AddEventHandler(
    'checkVehicleTransmission',
    function(plate)
        local src = source
        checkVehicleTransmission(
            plate,
            function(isManual)
                if isManual ~= nil then
                    -- Trigger the client event with the transmission type
                    TriggerClientEvent('receiveTransmissionType', src, isManual)
                else
                    -- If transmission type is unknown or no result
                    TriggerClientEvent('receiveTransmissionType', src, false)
                end
            end
        )
    end
)
