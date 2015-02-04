
uart.setup(0,9600,8,0,1,1)

lastval = 0

gpio.mode(6,gpio.OUTPUT)
gpio.mode(7,gpio.OUTPUT)
gpio.write(7,gpio.LOW)
gpio.write(6,gpio.LOW)

uart.on("data", 2, function(data)
	if data == "q\r" then
		uart.on("data")
	else
		if bit.bor(bit.lshift(data:byte(1),8),data:byte(2)) ~= 257 then 
			lastval = data
		end
		uart.write(0,data)
    end        
end, 0)
    
srv=net.createServer(net.TCP) 
srv:listen(80,function(conn) 
	  conn:on("receive",function(conn,payload) 
		local g = string.sub(payload, 5, 7)

		if g == "/up" then
			gpio.write(7,gpio.HIGH)
			tmr.delay(200000)
			gpio.write(7,gpio.LOW)
    		conn:send("receive('up');")
  		elseif g == "/dn" then
			gpio.write(6,gpio.HIGH)
			tmr.delay(200000)
			gpio.write(6,gpio.LOW)
  			conn:send("receive('down');")
  		elseif g == "/st" then
			local d = bit.bor(bit.lshift(lastval:byte(1),8),lastval:byte(2))
  			conn:send("receive('state','" .. d .. "');")
  		else
  			conn:send(g)
  		end

	end) 
	
	conn:on("sent",function(conn) 
		conn:close() 
	end)
end)