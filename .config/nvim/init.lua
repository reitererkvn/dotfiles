-- ====================================================================
-- SYSTEM-OPTIONEN (Nativ & Schnell)
-- ====================================================================
vim.opt.termguicolors = true
vim.opt.number = true
-- vim.opt.relativenumber = true
vim.cmd("colorscheme lunaperche")
vim.opt.clipboard = "unnamedplus"

vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "FocusGained" }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = "*",
})
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  command = "silent! wall",
  pattern = "*",
})


-- ====================================================================
-- KONTRAST-FIX (Transparenz)
-- ====================================================================
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
