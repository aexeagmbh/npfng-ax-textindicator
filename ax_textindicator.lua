local config = require('config')

local function start()
    local m = mqtt.Client(node.chipid(), 120, "user", "password")

    m:on("connect", function(con) print ("connected") end)
    m:on("offline", function(con) print ("offline") end)

    -- on publish message receive event
    m:on("message", function(conn, topic, data)
        print("received in "..topic.." => "..data)
        if data ~= nil then
            if data == 't' then
                ws2812.write(config.PIN_RGB_LED, string.char(255, 255, 255))
                tmr.alarm(1, 50, 0, function ()
                    ws2812.write(config.PIN_RGB_LED, string.char(0, 0, 0))
                end)
            end
        end
    end)

    m:connect(config.MQTT_HOST, config.MQTT_PORT, 0, function(conn)
        m:subscribe("/text",0, function(conn) print("subscribe success") end)
    end)
end

return {start = start}
