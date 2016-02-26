function exec_template(fname)
  file.open(fname, "r")
  local txt = {}
  
  while true do
    ln = file.readline()
    if (ln == nil) then break end

    for w in string.gmatch(ln, "{{$[^}]+}}") do
      f = loadstring("return ".. string.sub(w,4,-3))
      local nw = string.gsub(w, "[^%a%s]", "%%%1")
      ln = string.gsub(ln, nw, f())
    end
    
    txt[#txt+1] = ln
  end
  file.close()
  return table.concat(txt, "")
end

function load_file(fname, ftxt, cmpl)
  file.remove(fname)
  file.open(fname, "w")
  file.write(ftxt)
  file.flush()
  file.close()
  if string.sub(fname, -3, -1) == "lua" and cmpl == true then
    node.compile(fname)
    file.remove(fname)
  end
end


local pl = nil;
local sv=net.createServer(net.TCP, 10) 

sv:listen(80,function(conn)
  conn:on("receive", function(conn, pl) 
    local payload = pl;
    if string.sub(pl, 0, 9) == "**LOAD**\n"  then
      print("HTTP : File received...")
      pl = string.sub(pl,10,-1)
      local idx = string.find(pl,"\n")
      local fname = string.sub(pl, 0, idx-1)
      local ftxt = string.sub(pl, idx+1, -1)
      load_file(fname, ftxt, true)
    elseif string.sub(pl, 0, 12) == "**RESTART**\n" then
      print("HTTP : Restarting")
      node.restart()
    else
      print("HTTP : default page")
      conn:send(exec_template("page.tmpl"))
    end
    conn:close()
    collectgarbage()
  end)
end)
print("Server running...")