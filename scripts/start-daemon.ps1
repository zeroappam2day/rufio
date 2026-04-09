# Ruflo MCP Server — Persistent Background Process (PowerShell)
# The MCP server is the long-running process (not daemon start, which is one-shot).
#
# Usage:
#   pm2 resurrect                          # restore saved process list (auto-starts ruflo-mcp)
#   pm2 list                               # check status
#   pm2 logs ruflo-mcp                     # view logs
#   pm2 restart ruflo-mcp                  # restart
#
# First-time setup (already done):
#   pm2 start "C:/Users/anujd/AppData/Local/npm-cache/_npx/2ed56890c96f58f7/node_modules/@claude-flow/cli/bin/cli.js" --name ruflo-mcp -- mcp start
#   pm2 save
#
# To auto-start on Windows login, add this to Task Scheduler:
#   Action: powershell.exe
#   Arguments: -Command "pm2 resurrect"
#   Trigger: At log on

Write-Host "Restoring Ruflo MCP server via pm2..." -ForegroundColor Cyan
pm2 resurrect
pm2 list
