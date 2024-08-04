require('auto-session').setup {
  auto_session_create_enabled = false,
  log_level = "error",
  auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
}
