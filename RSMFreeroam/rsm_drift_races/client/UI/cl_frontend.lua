Frontend = {}

function Frontend.CallHeaderFunc(theFunction, ...)
	BeginScaleformMovieMethodOnFrontendHeader(theFunction)
  local arg = {...}
  if arg ~= nil then
    for i=1,#arg do
      local sType = type(arg[i])
      if sType == "boolean" then
				PushScaleformMovieMethodParameterBool(arg[i])
			elseif sType == "number" then
				if math.type(arg[i]) == "integer" then
					PushScaleformMovieMethodParameterInt(arg[i])
				else
					PushScaleformMovieMethodParameterFloat(arg[i])
				end
			elseif sType == "string" then
					PushScaleformMovieMethodParameterString(arg[i])
			else
					PushScaleformMovieMethodParameterInt()
			end
		end
	end
	return EndScaleformMovieMethodReturn()
end

function Frontend.CallFunc(theFunction, ...)
	BeginScaleformMovieMethodOnFrontend(theFunction)

  local arg = {...}
  if arg ~= nil then
    for i=1,#arg do
      local sType = type(arg[i])
      if sType == "boolean" then
				PushScaleformMovieMethodParameterBool(arg[i])
			elseif sType == "number" then
				if math.type(arg[i]) == "integer" then
					PushScaleformMovieMethodParameterInt(arg[i])
				else
					PushScaleformMovieMethodParameterFloat(arg[i])
				end
			elseif sType == "string" then
					PushScaleformMovieMethodParameterString(arg[i])
			else
					PushScaleformMovieMethodParameterInt()
			end
		end
	end
	return EndScaleformMovieMethodReturn()
end