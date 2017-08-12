--------------------------------------------------------------------------------
-- Function to split a string.
-- Source: http://www.wellho.net/resources/ex.php4?item=u108/split

function string:split(delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end

--------------------------------------------------------------------------------
-- Function to split a string.
-- Source: http://lua-users.org/wiki/StringTrim

function string:trim()
  return self:match'^()%s*$' and '' or self:match'^%s*(.*%S)'
end
