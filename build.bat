pyinstaller ^
    --name="nishi" ^
    --console ^
    --onefile ^
    --noconfirm ^
    --clean ^
    --hidden-import="NishiParser" ^
    NishiTranspiler.py