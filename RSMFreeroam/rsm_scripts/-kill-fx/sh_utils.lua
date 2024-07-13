function EncodeRGB(r, g, b)
  return ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF)
end

function DecodeRGB(int)
  return (int >> 16) & 0xff, (int >> 8) & 0xff, int & 0xff
end