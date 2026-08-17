return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "none",
      ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      ["<C-e>"] = { "cancel", "fallback" },
      ["<CR>"] = { "fallback" },
    },
    completion = {
      list = {
        selection = { preselect = false, auto_insert = false },
      },
    },
  },
}
