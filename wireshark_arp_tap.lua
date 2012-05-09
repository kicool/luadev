-- Wireshark
-- This program will register a menu that will open a window with a count of occurrences
-- of every hw address in the capture
function menuable_arp_tap()
		-- Declare the window we will use
		local tw = TextWindow.new("HW Address Counter")

		-- This will contain a hash of counters of appearances of a certain address
		local ips = {}
		
		local srcHwAddrCounts = 0		
		local dstHwAddrCounts = 0		
		local totalHwAddrCounts = 0
		local srcHwAddr = 0		
		local dstHwAddr = 0		
		local totalHwAddr = 0
		
		-- this is our tap
		local tap = Listener.new();

		function remove()
			-- this way we remove the listener than otherwise will remain running indifinitelly
			tap:remove();
		end

		-- we tell the window to call the remove() function when closed
		tw:set_atclose(remove)

		-- this function will be called once for each packet
		function tap.packet(pinfo,tvb)
			local src = ips[tostring(pinfo.dl_src)] or 0
			local dst = ips[tostring(pinfo.dl_dst)] or 0
			
			if src == 0 then 
				srcHwAddr = srcHwAddr + 1
			end

			if dst == 0 then 
				dstHwAddr = dstHwAddr + 1
			end
		
			totalHwAddrCounts = totalHwAddrCounts + 1
			
			ips[tostring(pinfo.dl_src)] = src + 1
			ips[tostring(pinfo.dl_dst)] = dst + 1
		end
		
		function pairsBy (t, f)
		    local a = {}
		    for n in pairs(t) do table.insert(a, n) end
		    table.sort(a, f)
		    local i = 0                 -- iterator variable
		    local iter = function ()    -- iterator function
		       i = i + 1
		       if a[i] == nil then return nil
		       else return a[i], t[a[i]]
		       end
		    end
		    return iter
		end
		
		function pairsByKeys (t)
			pairsBy(t)
		end
		
		function pairsByValues (t)
			function compDec(obj1, obj2)
				return t[obj1] > t[obj2]
			end
		    
			return pairsBy(t, compDec)
		end
		
		-- this function will be called once every few seconds to update our window
		function tap.draw(t)
			tw:clear()
			
			for ip,num in pairsByValues(ips) do
				tw:append(ip .. "\t" .. num .. "\n");
				totalHwAddr = totalHwAddr + 1
			end
			
			tw:append("Counts:=" .. "\t\t" .. totalHwAddr .. "\n");
		end

		-- this function will be called whenever a reset is needed
		-- e.g. when reloading the capture file
		function tap.reset()
			tw:clear()
			ips = {}
		end
	end
