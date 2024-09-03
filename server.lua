local webhookURL = ""

RegisterNetEvent('vehLog:sendToWebhook')
AddEventHandler('vehLog:sendToWebhook', function(playerServerId, playerName, vehicleName, vehiclePlate, vehicleNetId)
    local message = {
 {colour = "16711680", source = source, title = "Vehicle Spawned", message = vehiclePlate.. ..playerServerId}
        }},
        ["components"] = {{
            ["type"] = 1,
            ["components"] = {{
                ["type"] = 2,
                ["style"] = 4,
                ["label"] = "Delete Vehicle",
                ["custom_id"] = "delete_vehicle:" .. vehicleNetId
            }}
        }}
    }

    PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode(message), { ['Content-Type'] = 'application/json' })
end)

CreateThread(function()
    local serverPort = 3000

    SetHttpHandler(function(req, res)
        local content = ""
        req.onData(function(data)
            content = content .. data
        end)

        req.onEnd(function()
            local data = json.decode(content)
            if data and data.type == 3 and data.data and data.data.custom_id then
                local split = stringsplit(data.data.custom_id, ":")
                if split[1] == "delete_vehicle" then
                    local vehicleNetId = tonumber(split[2])
                    TriggerClientEvent('vehLog:deleteVehicle', -1, vehicleNetId)

                    PerformHttpRequest(data.token_url, function() end, 'POST', json.encode({
                        type = 4,
                        data = {
                            content = "Vehicle deleted.",
                            flags = 64
                        }
                    }), { ['Content-Type'] = 'application/json' })
                end
            end

            res.writeHead(200)
            res.send('')
        end)
    end)

    StartHttpServer(serverPort)
end)

function stringsplit(input, separator)
    if separator == nil then
        separator = "%s"
    end
    local t={}
    for str in string.gmatch(input, "([^"..separator.."]+)") do
        table.insert(t, str)
    end
    return t
end
