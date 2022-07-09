local lualine_ok, lualine = pcall(require, "lualine")

if not lualine_ok then
   return
end

lualine.setup({
   options = {
      theme = "seoul256",
   },
   sections = {
      lualine_c = {
         {
            'filename',
            path = 1,
         }
      }
   }
})
