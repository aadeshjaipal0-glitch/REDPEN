@echo off
cd /d %~dp0
echo Starting RedPen... open http://localhost:3000 in your browser
node server.js
pause
