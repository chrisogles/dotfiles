-- SQL client: browse connections, run queries, results in a split
return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
  },
  cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
  keys = {
    { "<leader>db", "<cmd>DBUIToggle<CR>", desc = "Toggle DB UI" },
  },
  init = function()
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui_queries"
    -- connection list lives outside this file — see db_connections.lua (gitignored, not this repo's concern)
    local ok, dbs = pcall(require, "db_connections")
    if ok then
      vim.g.dbs = dbs
    end
  end,
}
