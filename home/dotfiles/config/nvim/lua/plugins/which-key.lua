local present, whichkey = pcall(require, "which-key")

if not present then
  return
end

whichkey.setup {
	-- your configuration comes here
	-- or leave it empty to use the default settings
}

