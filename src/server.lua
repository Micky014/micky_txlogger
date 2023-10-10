-------- @../src/server.lua --------

-- functions --
local logcmd = {
    error = function(msg)
        print('[^1ERROR^7] '..msg)
    end,

    success = function(msg)
        print('[^2SUCCESS^7] '..msg)
    end,

    info = function(msg)
        print('[^5INFO^7] '..msg)
    end,
}

local function SendDiscordWebhook(url, embed)
    if not url:find('https://') or not url:find('discord') then
        return logcmd.error('invalid discord webhook url: '..url)
    end

    if embed.color then
        embed.color = tonumber(embed.color:gsub('#', ''), 16)
    end

    embed.footer = { ['text'] = 'micky_txlogger © 2023' }
    embed.timestamp = os.date("!%Y%m%dT%H%M%S")

    PerformHttpRequest(url, function(code, data)
        if code ~= 204 then
            logcmd.error('error sending webhook: '..code)
        end
    end, 'POST', json.encode({ 
        embeds = { embed }
    }), { 
        ['Content-Type'] = 'application/json' 
    })
end

-- players events --
AddEventHandler('txAdmin:events:playerWarned', function(eventData)
    SendDiscordWebhook(Config.WebHooks['Players'], {
        title = 'Player warned',
        description = '**Event: `txAdmin:events:playerWarned`**',
        color = '#DFFF00',
        fields = {
            { name = 'Player', value = '**`['..eventData.target..'] '..GetPlayerName(eventData.target)..'`**', inline = true },
            { name = 'Author', value = '**`'..eventData.author..'`**', inline = true },
            { name = 'Reason', value = '**`'..eventData.reason..'`**', inline = true },
            { name = 'Action Id', value = '**`'..eventData.actionId..'`**', inline = true }
        }
    })
end)

AddEventHandler('txAdmin:events:playerKicked', function(eventData)
    SendDiscordWebhook(Config.WebHooks['Players'], {
        title = 'Player kicked',
        description = '**Event: `txAdmin:events:playerKicked`**',
        color = '#FFBF00',
        fields = {
            { name = 'Player', value = '**`['..eventData.target..'] '..GetPlayerName(eventData.target)..'`**', inline = true },
            { name = 'Author', value = '**`'..eventData.author..'`**', inline = true },
            { name = 'Reason', value = '**`'..eventData.reason..'`**', inline = true }
        }
    })
end)

AddEventHandler('txAdmin:events:playerBanned', function(eventData)
    if eventData.durationTranslated == nil then
        eventData.durationTranslated = 'Permanent'
    end

    SendDiscordWebhook(Config.WebHooks['Players'], {
        title = 'Player banned',
        description = '**Event: `txAdmin:events:playerBanned`**',
        color = '#FF0000',
        fields = {
            { name = 'Player', value = '**`'..eventData.targetName..'`**', inline = true },
            { name = 'Author', value = '**`'..eventData.author..'`**', inline = true },
            { name = 'Reason', value = '**`'..eventData.reason..'`**', inline = true },
            { name = 'Duration', value = '**`'..eventData.durationTranslated..'`**', inline = true },
            { name = 'Action Id', value = '**`'..eventData.actionId..'`**', inline = true }
        }
    })
end)

AddEventHandler('txAdmin:events:healedPlayer', function(eventData)
    if eventData.id ~= -1 then
        playerName = '**`['..eventData.id..'] '..GetPlayerName(eventData.id)..'`**'
    else
        playerName = '**`Everyone`**'
    end

    SendDiscordWebhook(Config.WebHooks['Players'], {
        title = 'Player healed',
        description = '**Event: `txAdmin:events:healedPlayer`**',
        color = '#9FE2BF',
        fields = {
            { name = 'Player', value = playerName, inline = true }
        }
    })
end)

AddEventHandler('txAdmin:events:actionRevoked', function(eventData)
    SendDiscordWebhook(Config.WebHooks['Players'], {
        title = 'Action revoked',
        description = '**Event: `txAdmin:events:actionRevoked`**',
        color = '#DE3163',
        fields = {
            { name = 'Player', value = '**`'..eventData.playerName..'`**', inline = true },
            { name = 'Action Id', value = '**`'..eventData.actionId..'`**', inline = true },
            { name = 'Action type', value = '**`'..eventData.actionType..'`**', inline = true },
            { name = 'Action reason', value = '**`'..eventData.actionReason..'`**', inline = true },
            { name = 'Revoked by', value = '**`'..eventData.revokedBy..'`**', inline = true }
        }
    })
end)

AddEventHandler('txAdmin:events:whitelistPlayer', function(eventData)
    SendDiscordWebhook(Config.WebHooks['Players'], {
        title = 'Whitelist player',
        description = '**Event: `txAdmin:events:whitelistPlayer`**',
        color = '#9FE2BF',
        fields = {
            { name = 'Player', value = '**`'..eventData.playerName..'`**', inline = true },
            { name = 'Action', value = '**`'..eventData.action..'`**', inline = true },
            { name = 'Admin', value = '**`'..eventData.adminName..'`**', inline = true }
        }
    })
end)

AddEventHandler('txAdmin:events:whitelistRequest', function(eventData)
    SendDiscordWebhook(Config.WebHooks['Players'], {
        title = 'Whitelist request',
        description = '**Event: `txAdmin:events:whitelistRequest`**',
        color = '#6495ED',
        fields = {
            { name = 'Player', value = '**`'..eventData.playerName..'`**', inline = true },
            { name = 'Action', value = '**`'..eventData.action..'`**', inline = true },
            { name = 'Request Id', value = '**`'..eventData.requestId..'`**', inline = true }
        }
    })
end)

AddEventHandler('txAdmin:events:whitelistPreApproval', function(eventData)
    local player = eventData.playerName or eventData.identifier

    SendDiscordWebhook(Config.WebHooks['Players'], {
        title = 'Whitelist pre approval',
        description = '**Event: `txAdmin:events:whitelistPreApproval`**',
        color = '#DFFF00',
        fields = {
            { name = 'Player', value = '**`'..player..'`**', inline = true },
            { name = 'Action', value = '**`'..eventData.action..'`**', inline = true },
            { name = 'Admin', value = '**`'..eventData.adminName..'`**', inline = true }
        }
    })
end)

-- server events --
RegisterServerEvent('txAdmin:events:announcement', function(eventData)
    SendDiscordWebhook(Config.WebHooks['Server'], {
        title = 'Announcement',
        description = '**Event: `txAdmin:events:announcement`**',
        color = '#40E0D0',
        fields = {
            { name = 'Author', value = '**`'..eventData.author..'`**', inline = true },
            { name = 'Message', value = '**`'..eventData.message..'`**', inline = true }
        }
    })
end)

AddEventHandler('txAdmin:events:serverShuttingDown', function(eventData)
    SendDiscordWebhook(Config.WebHooks['Server'], {
        title = 'Server shutting down',
        description = '**Event: `txAdmin:events:serverShuttingDown`**',
        color = '#DFFF00',
        fields = {
            { name = 'Author', value = '**`'..eventData.author..'`**', inline = true },
            { name = 'Message', value = '**`'..eventData.message..'`**', inline = true }
        }
    })
end)