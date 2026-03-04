function LIBRARY:ParseManifest(sContent)
	assert(IsString(sContent),	"[LIBRARY] 'sContent' must be a string")

	local tManifest = {}

	for sLine in sContent:gmatch("[^\r\n]+") do
		if not sLine:match("%S") then
			goto continue
		end

		tManifest[#tManifest + 1] = sLine

		::continue::
	end

	return tManifest
end