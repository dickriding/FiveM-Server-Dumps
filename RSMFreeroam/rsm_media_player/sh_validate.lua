--? Make it shared so the client can also be aware if their url isnt allowed
--? Doesnt matter if it gets memed, server will stop it reaching others

local permittedDomains = {
  "youtube.com",
  "youtu.be",
  --"twitch.tv" --need external site to host it!
}

local permittedString = table.concat(permittedDomains, ", ")

function isDomainPermitted(url)
  -- get the domain from the url
  local uDomain = string.match(url, "https?://([^/]+)")
  
  if not uDomain then return false end

  if string.sub(uDomain, 1, 4) == "www." then
    uDomain = string.sub(uDomain, 5)
  end

  for i=0, #permittedDomains do
    local domain = permittedDomains[i]

    --? is domains not matching the host? get lost
    if domain == uDomain then
      return true
    end
  end

  return false
end

function getPermittedDomainString()
  return permittedString
end