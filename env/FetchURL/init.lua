return (function()
	local _, socket_http	= pcall(require, "socket.http")
	local _, http			= pcall(require, "http")
	local SafeCallback		= function(fCallback, sBody) local bOk, sErr=pcall(fCallback, sBody); return bOk or MsgC("Callback error: ", sErr) end
	local tBackends			=
	{
		lovr	= lovr and http and http.request and
		{
			fRequest	= function(sUrl, fCallback)
				local bOk, iStatus, sBody, tHeaders = pcall(http.request, sUrl)
				if not bOk then
					return MsgC("LOVR request failed")
				end
				return iStatus == 200 and SafeCallback(fCallback, sBody) or MsgC("HTTP code: ", tostring(iStatus))
			end,
		},
		glua	= http and http.Fetch and
		{
			fRequest	= function(sUrl, fCallback)
				http.Fetch(
					sUrl,
					function(sBody)
						SafeCallback(fCallback, sBody)
					end,
					function(sErr)
						MsgC("HTTP error: ", sErr)
					end
				)
			end,
		},
		other	= (not lovr) and socket_http and
		{
			fRequest	= function(sUrl, fCallback)
				local sBody, iCode = socket_http.request(sUrl)
				return iCode == 200 and SafeCallback(fCallback, sBody) or MsgC("HTTP code: ", tostring(iCode))
			end,
		},
	}

	local tHTTP		= tBackends.lovr or tBackends.glua or tBackends.other
	if not tHTTP then
		return MsgC(Color(231, 76, 60), "ERROR : No suitable HTTP backend found")
	end

	return function(sUrl, fCallback)
		assert(IsString(sUrl), "URL must be a string")
		assert(IsFunction(fCallback), "Callback must be a function")

		local bOk, sErr = pcall(tHTTP.fRequest, sUrl, fCallback)
		return bOk or MsgC("Request error: ", sErr)
	end
end)()