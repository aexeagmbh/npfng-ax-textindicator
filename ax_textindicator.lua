local config = require('config')

local function start()
    ws2812.write(config.PIN_RGB_LED, string.char(0, 255, 0))
    local m = mqtt.Client(node.chipid(), 120, "user", "password")

    m:on("connect", function(con) print ("connected") end)
    m:on("offline", function(con) print ("offline") end)

    -- on publish message receive event
    m:on("message", function(conn, topic, data)
        print("received in "..topic.." => "..data)
        if data ~= nil then
            local valid_json = false
            if string.sub(data, 0, 1) == '{' then
                local colors = cjson.decode(data)
                if colors.r and colors.g and colors.b then
                    ws2812.write(config.PIN_RGB_LED, string.char(colors.g, colors.r, colors.b))
                    valid_json = true
                end
            end
            if not valid_json then
                ws2812.write(config.PIN_RGB_LED, string.char(255, 255, 255))
            end
            tmr.alarm(1, 50, 0, function ()
                ws2812.write(config.PIN_RGB_LED, string.char(0, 0, 0))
            end)
        end
    end)

    m:connect(config.MQTT_HOST, config.MQTT_PORT, 0, function(conn)
        m:subscribe("/text",0, function(conn) 
            ws2812.write(config.PIN_RGB_LED, string.char(255, 0, 0))
            tmr.alarm(1, 100, 0, function ()
                ws2812.write(config.PIN_RGB_LED, string.char(0, 0, 0))
            end)
            print("subscribe success")
        end)
    end)
end

return {start = start}
